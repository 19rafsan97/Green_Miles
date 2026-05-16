alter table public.profiles
  add column if not exists profile_visible boolean not null default true;

create table if not exists public.notifications (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null default 'general',
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  push_enabled boolean not null default true,
  email_enabled boolean not null default true,
  weekly_summary_enabled boolean not null default true,
  profile_visible boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.notifications enable row level security;
alter table public.user_settings enable row level security;

drop policy if exists "notifications_select_own" on public.notifications;
create policy "notifications_select_own"
  on public.notifications for select
  using (auth.uid() = user_id);

drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own"
  on public.notifications for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "user_settings_select_own" on public.user_settings;
create policy "user_settings_select_own"
  on public.user_settings for select
  using (auth.uid() = user_id);

drop policy if exists "user_settings_insert_own" on public.user_settings;
create policy "user_settings_insert_own"
  on public.user_settings for insert
  with check (auth.uid() = user_id);

drop policy if exists "user_settings_update_own" on public.user_settings;
create policy "user_settings_update_own"
  on public.user_settings for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

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

  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create or replace function public.trips_create_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (user_id, title, message, type)
  values (
    new.user_id,
    'Trip recorded',
    format('Great job! You saved %s kg CO2 on your latest %s trip.', round(new.co2_saved_kg::numeric, 2), new.transport_mode),
    'trip'
  );

  return new;
end;
$$;

drop trigger if exists trips_notification_trigger on public.trips;
create trigger trips_notification_trigger
  after insert on public.trips
  for each row execute function public.trips_create_notification();

create or replace function public.get_leaderboard(
  p_period text default 'weekly',
  p_limit integer default 50
)
returns table (
  id uuid,
  full_name text,
  avatar_url text,
  points integer,
  total_co2_saved double precision,
  total_distance double precision,
  total_trips integer,
  profile_visible boolean
)
language sql
security definer
set search_path = public
as $$
  with filtered as (
    select
      p.id,
      p.full_name,
      p.avatar_url,
      p.points,
      p.total_distance,
      p.total_trips,
      p.profile_visible,
      case
        when p_period = 'all_time' then p.total_co2_saved
        else coalesce(sum(t.co2_saved_kg), 0)
      end as score
    from public.profiles p
    left join public.trips t
      on t.user_id = p.id
      and (
        p_period = 'all_time'
        or (
          p_period = 'weekly' and t.start_time >= now() - interval '7 days'
        )
        or (
          p_period = 'monthly' and t.start_time >= now() - interval '30 days'
        )
      )
    group by
      p.id,
      p.full_name,
      p.avatar_url,
      p.points,
      p.total_distance,
      p.total_trips,
      p.total_co2_saved,
      p.profile_visible
  )
  select
    filtered.id,
    filtered.full_name,
    filtered.avatar_url,
    filtered.points,
    filtered.score as total_co2_saved,
    filtered.total_distance,
    filtered.total_trips,
    filtered.profile_visible
  from filtered
  where filtered.score > 0
  order by filtered.score desc
  limit greatest(1, coalesce(p_limit, 50));
$$;

grant execute on function public.get_leaderboard(text, integer) to authenticated;

