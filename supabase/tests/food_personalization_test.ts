// Same PostgreSQL test engine already used by the reminder suite.
import { PGlite } from "npm:@electric-sql/pglite@0.5.10";

const A = "11111111-1111-4111-8111-111111111111";
const B = "22222222-2222-4222-8222-222222222222";
function equal(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`${JSON.stringify(actual)} != ${JSON.stringify(expected)}`);
  }
}

Deno.test("food profiles and menus: ownership, atomic writes and conflicts", async () => {
  const db = new PGlite();
  const exec = (sql: string) => db.exec(sql);
  const value = async (sql: string) =>
    (await db.query<Record<string, unknown>>(sql)).rows[0]?.v;
  async function rejects(sql: string) {
    let failed = false;
    try {
      await exec(sql);
    } catch {
      failed = true;
    }
    equal(failed, true);
  }
  const doc = JSON.stringify({
    schemaVersion: 1,
    profile: {
      allergies: ["soy"],
      diet: "unrestricted",
      goal: "maintain",
    },
    plans: { "offset:420/2026-10-22": [null, null, null] },
    rejected: [],
  });
  try {
    await exec(`
      create role anon; create role authenticated;
      create schema auth; grant usage on schema auth to authenticated;
      create table auth.users(id uuid primary key);
      create function auth.uid() returns uuid language sql stable as
        $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
      insert into auth.users values('${A}'),('${B}');
    `);
    const file = [
      ...Deno.readDirSync(new URL("../migrations", import.meta.url)),
    ]
      .find((f) => f.name.endsWith("_food_personalization.sql"))!;
    await exec(
      await Deno.readTextFile(
        new URL(`../migrations/${file.name}`, import.meta.url),
      ),
    );
    await exec(`set role anon`);
    await rejects(`select * from public.food_personalization`);
    await rejects(`select public.food_personalization_save('${doc}',0,'${A}')`);
    await exec(
      `reset role; set role authenticated; set request.jwt.claim.sub='${A}'`,
    );
    equal(
      await value(
        `select public.food_personalization_save('${doc}',0,'${A}') v`,
      ),
      1,
    );
    equal(
      await value(`select count(*)::int v from public.food_personalization`),
      1,
    );
    await rejects(`select public.food_personalization_save('${doc}',0,'${A}')`);
    await rejects(
      `insert into public.food_personalization(user_id,data) values('${B}','${doc}')`,
    );
    await rejects(
      `update public.food_personalization set user_id='${B}' where user_id='${A}'`,
    );
    await exec(`set request.jwt.claim.sub='${B}'`);
    await rejects(`select public.food_personalization_save('${doc}',0,'${A}')`);
    equal(
      await value(`select count(*)::int v from public.food_personalization`),
      0,
    );
    await exec(
      `update public.food_personalization set data='${doc}' where user_id='${A}'`,
    );
    await rejects(
      `delete from public.food_personalization where user_id='${A}'`,
    );
    equal(
      await value(
        `select public.food_personalization_save('${doc}',0,'${B}') v`,
      ),
      1,
    );
    await exec(`set request.jwt.claim.sub='${A}'`);
    equal(
      await value(
        `select public.food_personalization_save('${doc}',1,'${A}') v`,
      ),
      2,
    );
    await rejects(`select public.food_personalization_save('${doc}',1,'${A}')`);
    equal(
      await value(`select revision::int v from public.food_personalization`),
      2,
    );
    await rejects(`select public.food_personalization_save('{}',2,'${A}')`);
    await rejects(
      `select public.food_personalization_save('${
        JSON.stringify({
          schemaVersion: null,
          profile: {},
          plans: {},
          rejected: [],
        })
      }',2,'${A}')`,
    );
    await rejects(
      `select public.food_personalization_save('${doc}',-1,'${A}')`,
    );
    await exec(`set request.jwt.claim.sub=''`);
    equal(
      await value(`select count(*)::int v from public.food_personalization`),
      0,
    );
    await rejects(`select public.food_personalization_save('${doc}',0,'${A}')`);
    await exec(`reset role`);
    equal(
      await value(`select count(*)::int v from public.food_personalization`),
      2,
    );
  } finally {
    await db.close();
  }
});
