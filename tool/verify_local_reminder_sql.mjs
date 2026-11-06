// Standalone PostgreSQL verification without touching a connected Supabase project.
// npm.cmd install --prefix .dart_tool/reminder-sql --no-save --package-lock=false @electric-sql/pglite@0.3.14
// node tool/verify_local_reminder_sql.mjs
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
import { PGlite } from '../.dart_tool/reminder-sql/node_modules/@electric-sql/pglite/dist/index.js';

const db = new PGlite();
const a = '11111111-1111-4111-8111-111111111111';
const b = '22222222-2222-4222-8222-222222222222';
const c = '33333333-3333-4333-8333-333333333333';
let checks = 0;
const check = (value, expected) => { assert.deepEqual(value, expected); checks++; };
const scalar = async sql => Object.values((await db.query(sql)).rows[0])[0];
async function asUser(owner, action) {
  await db.exec('begin; set local role authenticated;');
  await db.query("select set_config('request.jwt.claim.sub', $1, true)", [owner]);
  try { return await action(); } finally { await db.exec('rollback'); }
}
async function rejected(owner, sql) {
  await assert.rejects(() => asUser(owner, () => db.exec(sql)));
  checks++;
}
try {
  await db.exec(`
    create role anon; create role authenticated; create role service_role bypassrls;
    create schema auth;
    create table auth.users(id uuid primary key);
    create function auth.uid() returns uuid language sql stable as
      $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    grant usage on schema auth to authenticated, anon;
    grant execute on function auth.uid() to authenticated, anon;
    insert into auth.users values ('${a}'), ('${b}'), ('${c}');
  `);
  await db.exec(await readFile(new URL('../supabase/migrations/20261022042606_workout_reminders.sql', import.meta.url), 'utf8'));
  await db.exec(`
    insert into reminder_private.preferences(user_id, enabled, morning) values
      ('${a}', true, '08:00'), ('${b}', true, '09:00');
    insert into reminder_private.devices(id,user_id,token,platform) values
      ('${a}', '${a}', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'android'),
      ('${b}', '${b}', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 'android');
    insert into reminder_private.events(id,user_id,local_date,slot,kind,logical_key,revision,due_at,expires_at)
      values('${a}','${a}',current_date,'morning','daily','a',0,now(),now()+interval '10 minutes');
    insert into reminder_private.deliveries(event_id,device_id) values('${a}','${a}');
  `);
  await db.exec(await readFile(new URL('../supabase/migrations/20261025094420_local_workout_notifications.sql', import.meta.url), 'utf8'));
  check(await scalar('select count(*)::int from public.workout_reminders'), 2);
  check(await scalar(`select enabled from reminder_private.preferences where user_id='${a}'`), true);
  await asUser(a, async () => {
    check((await db.query('select user_id from public.workout_reminders')).rows, [{ user_id: a }]);
    const settings = await scalar('select public.local_reminder_settings()');
    check(settings.morning, '08:00:00'); check(settings.enabled, true);
    check(await scalar(`select enabled from reminder_private.preferences where user_id='${a}'`)
      .catch(() => 'private'), 'private'); // Private tables remain inaccessible.
  });
  // asUser rolls back intentionally; repeat a successful cutover and commit it.
  await db.exec('begin; set local role authenticated;');
  await db.query("select set_config('request.jwt.claim.sub', $1, true)", [a]);
  await db.exec('select public.local_reminder_settings(); commit;');
  check(await scalar(`select enabled from reminder_private.preferences where user_id='${a}'`), false);
  check(await scalar(`select active from reminder_private.devices where user_id='${a}'`), false);
  check(await scalar(`select state from reminder_private.deliveries where event_id='${a}'`), 'cancelled');
  check(await scalar(`select enabled from reminder_private.preferences where user_id='${b}'`), true);
  check(await scalar(`select active from reminder_private.devices where user_id='${b}'`), true);
  // Saving directly through the table also retires push atomically.
  await db.exec('begin; set local role authenticated;');
  await db.query("select set_config('request.jwt.claim.sub', $1, true)", [b]);
  await db.exec(`insert into public.workout_reminders(user_id, morning) values('${b}', '09:45')
    on conflict(user_id) do update set morning=excluded.morning; commit;`);
  check(await scalar(`select enabled from reminder_private.preferences where user_id='${b}'`), false);
  check(await scalar(`select active from reminder_private.devices where user_id='${b}'`), false);
  check(await scalar(`select morning::text from public.workout_reminders where user_id='${b}'`), '09:45:00');
  await asUser(a, async () => {
    await db.exec(`update public.workout_reminders set morning='10:15', timezone='Europe/London' where user_id='${a}'`);
    check(await scalar('select morning::text from public.workout_reminders'), '10:15:00');
    check((await db.query(`update public.workout_reminders set enabled=false where user_id='${b}' returning user_id`)).rows, []);
  });
  await rejected(a, `insert into public.workout_reminders(user_id) values('${c}')`);
  await rejected(a, `update public.workout_reminders set user_id='${c}'`);
  for (const assignment of ["morning='24:00'", "morning='07:00:01'", "morning=evening", "timezone='Invalid/Nowhere'"]) {
    await rejected(a, `update public.workout_reminders set ${assignment} where user_id='${a}'`);
  }
  // Verify WITH CHECK independently from the trigger's owner guard.
  await db.exec('begin; alter table public.workout_reminders disable trigger validate_local_reminder; set local role authenticated;');
  await db.query("select set_config('request.jwt.claim.sub', $1, true)", [a]);
  await assert.rejects(() => db.exec(`update public.workout_reminders set user_id='${c}' where user_id='${a}'`), e => e.code === '42501');
  checks++; await db.exec('rollback');
  await db.exec('begin; set local role anon;');
  await assert.rejects(() => db.exec('select * from public.workout_reminders'), e => e.code === '42501');
  checks++; await db.exec('rollback');
  await db.exec('begin; set local role anon;');
  await assert.rejects(() => db.exec('select public.local_reminder_settings()'), e => e.code === '42501');
  checks++; await db.exec('rollback');
  console.log(`PASS: ${checks} migration/RLS/cutover checks (embedded PostgreSQL; not a remote Supabase deployment).`);
} finally {
  await db.close();
}
