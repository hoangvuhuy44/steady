-- Additive: no existing profile, journal, Auth or reminder data is changed.
-- Profiles, feedback and daily menus commit together under an optimistic lock.
create table public.food_personalization (
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 1 check (revision > 0),
  data jsonb not null check (coalesce(
    jsonb_typeof(data) = 'object'
    and data ?& array['schemaVersion', 'profile', 'plans', 'rejected']
    and data->>'schemaVersion' = '1'
    and jsonb_typeof(data->'profile') = 'object'
    and jsonb_typeof(data->'plans') = 'object'
    and jsonb_typeof(data->'rejected') = 'array'
    and octet_length(data::text) <= 131072
  , false)),
  updated_at timestamptz not null default now()
);

alter table public.food_personalization enable row level security;
revoke all on public.food_personalization from anon, authenticated;
grant select, insert, update on public.food_personalization to authenticated;

create policy food_read_own on public.food_personalization for select
  to authenticated using ((select auth.uid()) = user_id);
create policy food_insert_own on public.food_personalization for insert
  to authenticated with check ((select auth.uid()) = user_id);
create policy food_update_own on public.food_personalization for update
  to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create function public.food_personalization_save(document jsonb, expected_revision bigint, expected_owner uuid)
returns bigint language plpgsql security invoker set search_path = '' as $$
declare
  owner uuid := auth.uid();
  next_revision bigint;
begin
  if owner is null then raise exception 'Authentication required' using errcode = '28000'; end if;
  -- Pin the intended identity: the shared SDK can switch access tokens while
  -- an asynchronous request is waiting for a token refresh.
  if expected_owner is distinct from owner then
    raise exception 'Session changed' using errcode = '42501';
  end if;
  if expected_revision is null or expected_revision < 0 then
    raise exception 'Invalid revision' using errcode = '22023';
  end if;
  if expected_revision = 0 then
    insert into public.food_personalization(user_id, data) values (owner, document)
      on conflict (user_id) do nothing returning revision into next_revision;
  else
    update public.food_personalization
      set data = document, revision = revision + 1, updated_at = now()
      where user_id = owner and revision = expected_revision
      returning revision into next_revision;
  end if;
  if next_revision is null then
    raise exception 'Food preferences changed; reload before saving' using errcode = '40001';
  end if;
  return next_revision;
end;
$$;
revoke all on function public.food_personalization_save(jsonb, bigint, uuid) from public, anon;
grant execute on function public.food_personalization_save(jsonb, bigint, uuid) to authenticated;
