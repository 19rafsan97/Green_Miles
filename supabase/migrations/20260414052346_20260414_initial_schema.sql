create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  avatar_url text,
  points integer not null default 0,
  total_co2_saved double precision not null default 0,
  total_distance double precision not null default 0,
  total_trips integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.trips (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  transport_mode text not null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  distance_km double precision not null default 0,
  co2_saved_kg double precision not null default 0,
  created_at timestamptz not null default now(),
  constraint trips_nonnegative_distance check (distance_km >= 0),
  constraint trips_nonnegative_co2 check (co2_saved_kg >= 0),
  constraint trips_valid_time_window check (end_time >= start_time)
);

create table if not exists public.rewards (
  id bigint generated always as identity primary key,
  title text not null,
  description text not null,
  points integer not null,
  image_url text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint rewards_nonnegative_points check (points >= 0)
);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'rewards_title_key'
      and conrelid = 'public.rewards'::regclass
  ) then
    alter table public.rewards
      add constraint rewards_title_key unique (title);
  end if;
end
$$;

alter table public.profiles enable row level security;
alter table public.trips enable row level security;
alter table public.rewards enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "trips_select_own" on public.trips;
create policy "trips_select_own"
  on public.trips for select
  using (auth.uid() = user_id);

drop policy if exists "trips_insert_own" on public.trips;
create policy "trips_insert_own"
  on public.trips for insert
  with check (auth.uid() = user_id);

drop policy if exists "trips_update_own" on public.trips;
create policy "trips_update_own"
  on public.trips for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "trips_delete_own" on public.trips;
create policy "trips_delete_own"
  on public.trips for delete
  using (auth.uid() = user_id);

drop policy if exists "rewards_select_authenticated" on public.rewards;
create policy "rewards_select_authenticated"
  on public.rewards for select
  using (auth.role() = 'authenticated');

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, updated_at)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(coalesce(new.email, ''), '@', 1), 'Green Miles User'),
    now()
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = coalesce(excluded.full_name, public.profiles.full_name),
        updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.refresh_profile_totals(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles p
  set
    total_distance = coalesce(agg.total_distance, 0),
    total_co2_saved = coalesce(agg.total_co2_saved, 0),
    total_trips = coalesce(agg.total_trips, 0),
    updated_at = now()
  from (
    select
      user_id,
      sum(distance_km)::double precision as total_distance,
      sum(co2_saved_kg)::double precision as total_co2_saved,
      count(*)::integer as total_trips
    from public.trips
    where user_id = p_user_id
    group by user_id
  ) agg
  where p.id = p_user_id;

  if not exists (select 1 from public.trips where user_id = p_user_id) then
    update public.profiles
    set total_distance = 0,
        total_co2_saved = 0,
        total_trips = 0,
        updated_at = now()
    where id = p_user_id;
  end if;
end;
$$;

create or replace function public.trips_sync_profile_totals()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.refresh_profile_totals(old.user_id);
    return old;
  end if;

  perform public.refresh_profile_totals(new.user_id);

  if tg_op = 'UPDATE' and old.user_id is distinct from new.user_id then
    perform public.refresh_profile_totals(old.user_id);
  end if;

  return new;
end;
$$;

drop trigger if exists trips_profile_totals_trigger on public.trips;
create trigger trips_profile_totals_trigger
  after insert or update or delete on public.trips
  for each row execute function public.trips_sync_profile_totals();
