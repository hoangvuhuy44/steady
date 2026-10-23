-- Apply once to a development project. No cron or remote send is enabled here.
create schema if not exists reminder_private;
revoke all on schema reminder_private from public, anon, authenticated;

create table reminder_private.preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  enabled boolean not null default false,
  morning time not null default '07:00',
  evening time not null default '18:30',
  timezone text not null default 'Asia/Ho_Chi_Minh',
  revision bigint not null default 0,
  updated_at timestamptz not null default now(),
  check (morning <> evening)
);
create table reminder_private.devices (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  token text unique not null check (length(token) between 20 and 4096),
  platform text not null check (platform in ('android','ios')),
  active boolean not null default true,
  updated_at timestamptz not null default now()
);
create index on reminder_private.devices(user_id) where active;
create table reminder_private.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_date date not null,
  slot text not null check (slot in ('morning','evening','test','demo-morning','demo-evening')),
  kind text not null check (kind in ('daily','test','demo')),
  -- daily key deliberately excludes revision, time and timezone.
  logical_key text not null unique,
  revision bigint not null,
  due_at timestamptz not null,
  expires_at timestamptz not null,
  cancelled boolean not null default false,
  attempted boolean not null default false
);
create index on reminder_private.events(due_at) where not cancelled;
create index on reminder_private.events(user_id);
create table reminder_private.deliveries (
  event_id uuid not null references reminder_private.events(id) on delete cascade,
  device_id uuid not null references reminder_private.devices(id) on delete cascade,
  state text not null default 'pending' check (state in ('pending','claimed','accepted','failed','expired','cancelled')),
  attempts int not null default 0,
  next_attempt timestamptz not null default now(),
  lease_until timestamptz,
  claim_id uuid,
  provider_id text,
  error_code text,
  primary key (event_id, device_id)
);
create unique index on reminder_private.deliveries(claim_id) where claim_id is not null;
create index on reminder_private.deliveries(device_id);
create index on reminder_private.deliveries(next_attempt) where state='pending';
create index on reminder_private.deliveries(lease_until) where state='claimed';
create table reminder_private.test_limits (
  user_id uuid primary key references auth.users(id) on delete cascade,
  last_at timestamptz not null
);
alter table reminder_private.preferences enable row level security;
alter table reminder_private.devices enable row level security;
alter table reminder_private.events enable row level security;
alter table reminder_private.deliveries enable row level security;
alter table reminder_private.test_limits enable row level security;

-- Narrow RPC API: no user_id accepted from clients. Definer is needed because
-- the private schema and job tables are deliberately not exposed to Data API.
create function public.reminder_settings() returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  return coalesce((select to_jsonb(p) from reminder_private.preferences p where user_id = auth.uid()),
    '{"enabled":false,"morning":"07:00:00","evening":"18:30:00","timezone":"Asia/Ho_Chi_Minh"}'::jsonb);
end $$;

create function public.reminder_save(p_enabled boolean, p_morning time, p_evening time, p_timezone text)
returns void language plpgsql security definer set search_path = '' as $$
declare p reminder_private.preferences;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_enabled is null or p_morning is null or p_evening is null or p_timezone is null
    or p_morning = p_evening or not exists(select 1 from pg_timezone_names where name = p_timezone)
    then raise exception 'Invalid times or IANA timezone'; end if;
  insert into reminder_private.preferences(user_id) values(auth.uid()) on conflict do nothing;
  -- Serialize with planner, test creation and send authorization.
  select * into p from reminder_private.preferences where user_id = auth.uid() for update;
  if p.enabled=p_enabled and p.morning=p_morning and p.evening=p_evening and p.timezone=p_timezone then
    return; -- Registering another device must not invalidate unchanged schedules.
  end if;
  update reminder_private.preferences set enabled = p_enabled, morning = p_morning,
    evening = p_evening, timezone = p_timezone, revision = revision + 1, updated_at = now()
    where user_id = auth.uid();
  update reminder_private.deliveries d set state = 'cancelled', claim_id = null
    from reminder_private.events e where e.id = d.event_id and e.user_id = auth.uid()
    and d.state in ('pending','claimed');
  update reminder_private.events set cancelled = true where user_id = auth.uid();
end $$;

create function public.reminder_device(p_id uuid, p_token text, p_platform text, p_active boolean default true)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_active then
    -- Do not allow device-ID or token takeover from another account.
    if exists(select 1 from reminder_private.devices where (id = p_id or token = p_token) and user_id <> auth.uid())
      then raise exception 'Device belongs to another session; unregister before switching'; end if;
    insert into reminder_private.devices(id,user_id,token,platform)
      values(p_id,auth.uid(),p_token,p_platform)
      on conflict(id) do update set token=excluded.token, platform=excluded.platform, active=true, updated_at=now()
      where reminder_private.devices.user_id=auth.uid();
  else
    delete from reminder_private.devices where id=p_id and user_id=auth.uid();
  end if;
end $$;

create function public.reminder_test(p_device uuid, p_demo boolean default false)
returns void language plpgsql security definer set search_path = '' as $$
declare p reminder_private.preferences; batch uuid := gen_random_uuid();
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into p from reminder_private.preferences where user_id=auth.uid() for update;
  if not found or not p.enabled then raise exception 'Enable reminders first'; end if;
  if not exists(select 1 from reminder_private.devices where id=p_device and user_id=auth.uid() and active)
    then raise exception 'Register this device first'; end if;
  insert into reminder_private.test_limits values(auth.uid(),now()) on conflict(user_id)
    do update set last_at=now() where reminder_private.test_limits.last_at <= now()-interval '60 seconds';
  if not found then raise exception 'Wait 60 seconds before another test'; end if;
  with added as (
    insert into reminder_private.events(user_id,local_date,slot,kind,logical_key,revision,due_at,expires_at)
    select auth.uid(), (now() at time zone p.timezone)::date,
      case when not p_demo then 'test' when n=1 then 'demo-morning' else 'demo-evening' end,
      case when p_demo then 'demo' else 'test' end, batch::text || ':' || n,
      p.revision, now()+delay, now()+delay+interval '10 minutes'
    from (values(1,case when p_demo then interval '1 minute' else interval '0' end),
                (2,interval '3 minutes')) s(n,delay) where p_demo or n=1 returning id
  ) insert into reminder_private.deliveries(event_id,device_id) select id,p_device from added;
end $$;

create function public.reminder_plan(p_now timestamptz default now()) returns void
language plpgsql security definer set search_path = '' as $$
declare p reminder_private.preferences; s record; d date; due timestamptz;
begin
  for p in select * from reminder_private.preferences where enabled for update skip locked loop
    -- Previous local date covers a reminder shortly before midnight.
    for d in select (p_now at time zone p.timezone)::date - n from generate_series(0,1) n loop
      for s in select 'morning' slot,p.morning at_time union all select 'evening',p.evening loop
        due := (d + s.at_time) at time zone p.timezone;
        if due <= p_now and due > p_now-interval '10 minutes' and due >= p.updated_at then
          insert into reminder_private.events(user_id,local_date,slot,kind,logical_key,revision,due_at,expires_at)
          values(p.user_id,d,s.slot,'daily',p.user_id::text||':'||d||':'||s.slot,p.revision,due,due+interval '10 minutes')
          on conflict(logical_key) do update set revision=excluded.revision, due_at=excluded.due_at,
            expires_at=excluded.expires_at,cancelled=false
            where not reminder_private.events.attempted;
        end if;
      end loop;
    end loop;
    insert into reminder_private.deliveries(event_id,device_id,next_attempt)
      select e.id,v.id,e.due_at from reminder_private.events e join reminder_private.devices v on v.user_id=e.user_id
      where e.user_id=p.user_id and e.kind='daily' and not e.cancelled and e.revision=p.revision
        and e.expires_at>p_now and v.active on conflict do nothing;
    update reminder_private.deliveries d set state='pending', next_attempt=p_now, claim_id=null
      from reminder_private.events e where e.id=d.event_id and e.user_id=p.user_id
      and not e.cancelled and not e.attempted and e.revision=p.revision and d.state='cancelled';
  end loop;
end $$;

create function public.reminder_claim(p_now timestamptz default now()) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare result jsonb;
begin
  update reminder_private.deliveries d set state='expired',claim_id=null
    from reminder_private.events e where e.id=d.event_id and e.expires_at<=p_now and d.state in ('pending','claimed');
  update reminder_private.deliveries set state='failed', claim_id=null
    where state='claimed' and lease_until<=p_now and attempts>=3;
  with picked as (
    select d.event_id,d.device_id from reminder_private.deliveries d
    join reminder_private.events e on e.id=d.event_id
    join reminder_private.preferences p on p.user_id=e.user_id
    join reminder_private.devices v on v.id=d.device_id
    where p.enabled and p.revision=e.revision and not e.cancelled and v.active
      and e.due_at<=p_now and e.expires_at>p_now and d.attempts<3
      and ((d.state='pending' and d.next_attempt<=p_now) or (d.state='claimed' and d.lease_until<=p_now))
    order by e.due_at limit 20 for update of d skip locked
  ), claimed as (
    update reminder_private.deliveries d set state='claimed',attempts=attempts+1,
      claim_id=gen_random_uuid(),lease_until=p_now+interval '2 minutes'
    from picked x where d.event_id=x.event_id and d.device_id=x.device_id returning d.*
  ) select coalesce(jsonb_agg(to_jsonb(c)||jsonb_build_object('slot',e.slot,'expires_at',e.expires_at)), '[]'::jsonb)
      into result from claimed c join reminder_private.events e on e.id=c.event_id;
  return result;
end $$;

-- Recheck immediately before network dispatch; stale claim cannot send or finish.
create function public.reminder_authorize(p_claim uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare result jsonb; event uuid;
begin
  select jsonb_build_object('token',v.token,'user_id',e.user_id), e.id into result,event
    from reminder_private.deliveries d join reminder_private.events e on e.id=d.event_id
    join reminder_private.preferences p on p.user_id=e.user_id
    join reminder_private.devices v on v.id=d.device_id
    where d.claim_id=p_claim and d.state='claimed' and d.lease_until>now()
      and p.enabled and p.revision=e.revision and not e.cancelled and v.active and e.expires_at>now()
    for share of p,v;
  if result is not null then
    update reminder_private.events set attempted=true where id=event;
  end if;
  return result;
end $$;

create function public.reminder_finish(p_claim uuid, p_result text, p_provider text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare d reminder_private.deliveries;
begin
  select * into d from reminder_private.deliveries where claim_id=p_claim and state='claimed' for update;
  if not found then return; end if;
  if p_result='unregistered' then
    update reminder_private.devices set active=false where id=d.device_id;
  end if;
  update reminder_private.deliveries set
    state=case when p_result='accepted' then 'accepted'
      when p_result='expired' then 'expired'
      when p_result='retry' and attempts<3 then 'pending' else 'failed' end,
    next_attempt=now()+make_interval(secs=>30*attempts),claim_id=null,lease_until=null,
    provider_id=p_provider,error_code=case when p_result='accepted' then null else p_result end
    where event_id=d.event_id and device_id=d.device_id;
end $$;

revoke all on function public.reminder_settings() from public,anon,authenticated;
revoke all on function public.reminder_save(boolean,time,time,text) from public,anon,authenticated;
revoke all on function public.reminder_device(uuid,text,text,boolean) from public,anon,authenticated;
revoke all on function public.reminder_test(uuid,boolean) from public,anon,authenticated;
grant execute on function public.reminder_settings(), public.reminder_save(boolean,time,time,text),
  public.reminder_device(uuid,text,text,boolean), public.reminder_test(uuid,boolean) to authenticated;
revoke all on function public.reminder_plan(timestamptz),public.reminder_claim(timestamptz),
  public.reminder_authorize(uuid),public.reminder_finish(uuid,text,text) from public,anon,authenticated;
grant execute on function public.reminder_plan(timestamptz),public.reminder_claim(timestamptz),
  public.reminder_authorize(uuid),public.reminder_finish(uuid,text,text) to service_role;
