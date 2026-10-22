// Real PostgreSQL engine in WASM; no Supabase project, Docker or push credentials.
import { PGlite } from "npm:@electric-sql/pglite@0.5.10";

const A = "11111111-1111-4111-8111-111111111111";
const B = "22222222-2222-4222-8222-222222222222";
const D1 = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1";
const D2 = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2";
function equal(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`${JSON.stringify(actual)} != ${JSON.stringify(expected)}`);
  }
}

Deno.test("reminder database behavior", async (t) => {
  const db = new PGlite();
  const exec = (sql: string) => db.exec(sql);
  async function value(sql: string) {
    return (await db.query<Record<string, unknown>>(sql)).rows[0]?.v;
  }
  async function rejects(sql: string) {
    let failed = false;
    try {
      await exec(sql);
    } catch {
      failed = true;
    }
    equal(failed, true);
  }
  await exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth; grant usage on schema auth to authenticated;
    create table auth.users(id uuid primary key);
    create function auth.uid() returns uuid language sql stable as
      $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
    insert into auth.users values('${A}'),('${B}');
  `);
  const migrations = [
    ...Deno.readDirSync(new URL("../migrations", import.meta.url)),
  ].filter((f) => f.name.endsWith("_workout_reminders.sql"));
  equal(migrations.length, 1);
  await exec(
    await Deno.readTextFile(
      new URL(`../migrations/${migrations[0].name}`, import.meta.url),
    ),
  );
  async function fixture(
    zone = "Asia/Ho_Chi_Minh",
    morning = "07:00",
    evening = "18:30",
  ) {
    await exec(
      `reset role; truncate reminder_private.preferences, reminder_private.devices,
      reminder_private.events, reminder_private.deliveries,reminder_private.test_limits cascade;
      set request.jwt.claim.sub='${A}';
      select public.reminder_save(true,'${morning}','${evening}','${zone}');
      select public.reminder_device('${D1}','token-device-one-000000000','android');
      select public.reminder_device('${D2}','token-device-two-000000000','ios');
      update reminder_private.preferences set updated_at='2025-01-01';`,
    );
  }
  try {
    await t.step(
      "defaults, validation and authentication are enforced",
      async () => {
        await exec(`set request.jwt.claim.sub='${A}'`);
        equal(
          await value("select public.reminder_settings()->>'timezone' v"),
          "Asia/Ho_Chi_Minh",
        );
        await rejects(
          "select public.reminder_save(true,'07:00','07:00','Asia/Ho_Chi_Minh')",
        );
        await rejects(
          "select public.reminder_save(true,'07:00','18:30','Not/AZone')",
        );
        await exec("set request.jwt.claim.sub=''");
        await rejects("select public.reminder_settings()");
      },
    );
    await t.step(
      "IANA local day and one logical event distributed to two devices",
      async () => {
        await fixture("Pacific/Auckland");
        await exec("select public.reminder_plan('2026-01-01T18:02:00Z')");
        equal(
          await value("select local_date::text v from reminder_private.events"),
          "2026-01-02",
        );
        equal(
          await value(
            "select count(*)::int v from reminder_private.deliveries",
          ),
          2,
        );
        await exec("select public.reminder_plan('2026-01-01T18:03:00Z')");
        equal(
          await value("select count(*)::int v from reminder_private.events"),
          1,
        );
        const jobs = await value(
          "select public.reminder_claim('2026-01-01T18:03:00Z') v",
        ) as unknown[];
        equal(jobs.length, 2);
        equal(
          await value("select public.reminder_claim('2026-01-01T18:03:00Z') v"),
          [],
        );
      },
    );
    await t.step("morning and evening daily slots are separate", async () => {
      await fixture();
      await exec(
        "select public.reminder_plan('2026-10-22T00:01:00Z'); select public.reminder_plan('2026-10-22T11:31:00Z')",
      );
      equal(
        await value("select count(*)::int v from reminder_private.events"),
        2,
      );
      equal(
        await value("select count(*)::int v from reminder_private.deliveries"),
        4,
      );
      await exec(
        "select public.reminder_save(true,'07:00','18:30','Asia/Ho_Chi_Minh')",
      );
      equal(
        await value(
          "select count(*)::int v from reminder_private.events where cancelled",
        ),
        0,
      );
    });
    await t.step(
      "previous local date across midnight, and stale reminders are skipped",
      async () => {
        await fixture("Asia/Ho_Chi_Minh", "23:58", "18:30");
        await exec("select public.reminder_plan('2026-10-22T17:02:00Z')");
        equal(
          await value("select local_date::text v from reminder_private.events"),
          "2026-10-22",
        );
        await fixture();
        await exec("select public.reminder_plan('2026-10-22T00:11:00Z')");
        equal(
          await value("select count(*)::int v from reminder_private.events"),
          0,
        );
      },
    );
    await t.step(
      "DST spring gap follows PostgreSQL shift; fall overlap sends once",
      async () => {
        await fixture("America/New_York", "02:30", "18:30");
        await exec("select public.reminder_plan('2026-03-08T07:31:00Z')");
        equal(
          await value("select count(*)::int v from reminder_private.events"),
          1,
        );
        await fixture("America/New_York", "01:30", "18:30");
        await exec(
          "select public.reminder_plan('2026-11-01T05:31:00Z'); select public.reminder_plan('2026-11-01T06:31:00Z'); select public.reminder_plan('2026-11-01T06:32:00Z')",
        );
        equal(
          await value("select count(*)::int v from reminder_private.events"),
          1,
        );
      },
    );
    await t.step(
      "changing an unsent time reschedules; an attempted slot never reopens",
      async () => {
        await fixture();
        await exec(
          "select public.reminder_plan('2026-10-22T00:01:00Z'); select public.reminder_save(true,'08:00','18:30','Asia/Ho_Chi_Minh'); update reminder_private.preferences set updated_at='2025-01-01'; select public.reminder_plan('2026-10-22T01:01:00Z')",
        );
        equal(
          await value(
            "select count(*)::int v from reminder_private.events where not cancelled and revision=2",
          ),
          1,
        );
        await exec(
          "update reminder_private.events set attempted=true; update reminder_private.deliveries set state='accepted'; select public.reminder_save(true,'09:00','18:30','Asia/Ho_Chi_Minh'); update reminder_private.preferences set updated_at='2025-01-01'; select public.reminder_plan('2026-10-22T02:01:00Z')",
        );
        equal(
          await value("select count(*)::int v from reminder_private.events"),
          1,
        );
        equal(
          await value("select public.reminder_claim('2026-10-22T02:01:00Z') v"),
          [],
        );
      },
    );
    await t.step(
      "disable cancels pending/demo/claimed jobs and invalidates old claim",
      async () => {
        await fixture();
        await exec(`select public.reminder_test('${D1}',true)`);
        equal(
          await value("select count(*)::int v from reminder_private.events"),
          2,
        );
        equal(
          await value(
            "select extract(epoch from max(due_at)-min(due_at))::int v from reminder_private.events",
          ),
          120,
        );
        await exec(
          "select public.reminder_plan(now()); select public.reminder_save(false,'07:00','18:30','Asia/Ho_Chi_Minh')",
        );
        equal(
          await value(
            "select public.reminder_claim(now()+interval '4 minutes') v",
          ),
          [],
        );
      },
    );
    await t.step(
      "test belongs to current user/device and has a durable rate limit",
      async () => {
        await fixture();
        await exec(`select public.reminder_test('${D1}',false)`);
        equal(
          await value(
            "select count(*)::int v from reminder_private.deliveries",
          ),
          1,
        );
        await rejects(`select public.reminder_test('${D1}',false)`);
        await exec(
          `set request.jwt.claim.sub='${B}'; select public.reminder_save(true,'07:00','18:30','UTC')`,
        );
        await rejects(`select public.reminder_test('${D1}',false)`);
        await rejects(
          `select public.reminder_device('${D1}','token-device-one-000000000','android')`,
        );
        await exec(`select public.reminder_device('${D1}','','android',false)`);
        equal(
          await value("select count(*)::int v from reminder_private.devices"),
          2,
        );
      },
    );
    await t.step(
      "token expiry, bounded retries and stale claim fencing",
      async () => {
        await fixture();
        await exec(`select public.reminder_test('${D1}',false)`);
        const jobs = await value("select public.reminder_claim() v") as {
          claim_id: string;
        }[];
        const claim = jobs[0].claim_id;
        equal(
          typeof await value(`select public.reminder_authorize('${claim}') v`),
          "object",
        );
        equal(
          await value("select attempted v from reminder_private.events"),
          true,
        );
        await exec(`select public.reminder_finish('${claim}','unregistered')`);
        equal(
          await value(
            `select active v from reminder_private.devices where id='${D1}'`,
          ),
          false,
        );
        await fixture();
        await exec(`select public.reminder_test('${D1}',false)`);
        const first = await value("select public.reminder_claim() v") as {
          claim_id: string;
        }[];
        for (let n = 0; n < 3; n++) {
          const next = n === 0
            ? first
            : await value("select public.reminder_claim() v") as {
              claim_id: string;
            }[];
          equal(next.length, 1);
          await exec(
            `select public.reminder_finish('${
              next[0].claim_id
            }','retry'); update reminder_private.deliveries set next_attempt=now()`,
          );
        }
        equal(await value("select public.reminder_claim() v"), []);
        equal(
          await value("select state v from reminder_private.deliveries"),
          "failed",
        );
        equal(
          await value(
            `select public.reminder_authorize('${first[0].claim_id}') v`,
          ),
          null,
        );
      },
    );
    await t.step(
      "expired lease can be reclaimed but old worker cannot finish new claim",
      async () => {
        await fixture();
        await exec(`select public.reminder_test('${D1}',false)`);
        const first = await value("select public.reminder_claim() v") as {
          claim_id: string;
        }[];
        await exec(
          "update reminder_private.deliveries set lease_until=now()-interval '1 second'",
        );
        const second = await value("select public.reminder_claim() v") as {
          claim_id: string;
        }[];
        equal(second.length, 1);
        await exec(
          `select public.reminder_finish('${
            first[0].claim_id
          }','accepted','old-message')`,
        );
        equal(
          await value(
            "select claim_id::text v from reminder_private.deliveries",
          ),
          second[0].claim_id,
        );
        await exec(
          "select public.reminder_save(false,'07:00','18:30','Asia/Ho_Chi_Minh')",
        );
        equal(
          await value(
            `select public.reminder_authorize('${second[0].claim_id}') v`,
          ),
          null,
        );
      },
    );
    await t.step(
      "permissions deny anonymous and prevent clients accessing jobs",
      async () => {
        equal(
          await value(
            "select has_function_privilege('anon','public.reminder_settings()','execute') v",
          ),
          false,
        );
        equal(
          await value(
            "select has_function_privilege('authenticated','public.reminder_plan(timestamptz)','execute') v",
          ),
          false,
        );
        equal(
          await value(
            "select has_schema_privilege('authenticated','reminder_private','usage') v",
          ),
          false,
        );
        await exec(`set request.jwt.claim.sub='${B}'; set role authenticated`);
        equal(
          await value("select public.reminder_settings()->>'timezone' v"),
          "Asia/Ho_Chi_Minh",
        );
        await rejects("select * from reminder_private.events");
        await exec("reset role");
      },
    );
  } finally {
    await db.close();
  }
});
