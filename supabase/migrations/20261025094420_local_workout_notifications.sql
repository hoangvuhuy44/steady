-- Local scheduling cutover. Does not disable any production cron job globally.
create table public.workout_reminders (
  user_id uuid primary key references auth.users(id) on delete cascade,
  enabled boolean not null default false,
  morning time not null default '07:00',
  evening time not null default '18:30',
  timezone text not null default 'Asia/Ho_Chi_Minh',
  updated_at timestamptz not null default now(),
  check (morning <> evening),
  check (morning < time '24:00' and evening < time '24:00'),
  check (extract(second from morning) = 0 and extract(second from evening) = 0)
);
alter table public.workout_reminders enable row level security;
revoke all on public.workout_reminders from anon, authenticated;
grant select, insert, update on public.workout_reminders to authenticated;
create policy reminders_read on public.workout_reminders for select to authenticated
  using ((select auth.uid()) = user_id);
create policy reminders_insert on public.workout_reminders for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy reminders_update on public.workout_reminders for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- Preserve account times/enabled state. Push remains active for old app users
-- until their first successful local-reminder sync, or an operator retires it.
insert into public.workout_reminders(user_id, enabled, morning, evening, timezone, updated_at)
select user_id, enabled, morning, evening, timezone, updated_at
from reminder_private.preferences;

-- The legacy schema is not exposed. Definer access is confined to this helper;
-- callers below always verify auth.uid(). No user ID supplied by the client.
create function reminder_private.retire_owner_push(p_owner uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or auth.uid() <> p_owner then
    raise exception 'Authentication required for owner';
  end if;
  update reminder_private.preferences set enabled = false, revision = revision + 1,
    updated_at = now() where user_id = p_owner and enabled;
  update reminder_private.devices set active = false where user_id = p_owner and active;
  update reminder_private.events set cancelled = true where user_id = p_owner and not cancelled;
  update reminder_private.deliveries d set state = 'cancelled', claim_id = null
    from reminder_private.events e where e.id = d.event_id and e.user_id = p_owner
      and d.state in ('pending', 'claimed');
end $$;
revoke all on function reminder_private.retire_owner_push(uuid) from public, anon, authenticated;

create function reminder_private.validate_local_reminder() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or auth.uid() <> new.user_id then raise exception 'Owner required'; end if;
  if not exists(select 1 from pg_catalog.pg_timezone_names where name = new.timezone) then
    raise exception 'Invalid IANA timezone';
  end if;
  new.updated_at := now();
  perform reminder_private.retire_owner_push(new.user_id);
  return new;
end $$;
revoke all on function reminder_private.validate_local_reminder() from public, anon, authenticated;
create trigger validate_local_reminder before insert or update on public.workout_reminders
  for each row execute function reminder_private.validate_local_reminder();

-- Used on every pull, including existing migrated rows with no pending edits.
-- Retirement and reading the account settings are one transaction.
create function public.local_reminder_settings() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare owner_id uuid := auth.uid();
begin
  if owner_id is null then raise exception 'Authentication required'; end if;
  perform reminder_private.retire_owner_push(owner_id);
  return coalesce((select to_jsonb(p) from public.workout_reminders p where p.user_id = owner_id),
    '{"enabled":false,"morning":"07:00","evening":"18:30","timezone":"Asia/Ho_Chi_Minh"}'::jsonb);
end $$;
revoke all on function public.local_reminder_settings() from public, anon, authenticated;
grant execute on function public.local_reminder_settings() to authenticated;
