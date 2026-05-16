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
        or (p_period = 'weekly' and t.start_time >= now() - interval '7 days')
        or (p_period = 'monthly' and t.start_time >= now() - interval '30 days')
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
  order by filtered.score desc
  limit greatest(1, coalesce(p_limit, 50));
$$;

