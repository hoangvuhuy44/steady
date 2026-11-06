import {
  classify,
  type Delivery,
  googleAccessToken,
  messageFor,
} from "./fcm.ts";

function required(name: string) {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing ${name}`);
  return value;
}

async function rpc(name: string, args: Record<string, unknown> = {}) {
  const key = required("SUPABASE_SERVICE_ROLE_KEY");
  const response = await fetch(
    `${required("SUPABASE_URL")}/rest/v1/rpc/${name}`,
    {
      method: "POST",
      headers: {
        apikey: key,
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(args),
      signal: AbortSignal.timeout(12000),
    },
  );
  if (!response.ok) {
    throw new Error(`Database RPC failed: ${name} (${response.status})`);
  }
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

export async function run() {
  const account = JSON.parse(required("FCM_SERVICE_ACCOUNT"));
  // Fail before claiming jobs if credentials cannot authenticate.
  const accessToken = await googleAccessToken(account);
  await rpc("reminder_plan");
  const jobs: Delivery[] = await rpc("reminder_claim");
  const results = await Promise.all(jobs.map(async (job) => {
    const device = await rpc("reminder_authorize", { p_claim: job.claim_id });
    if (!device) return "cancelled";
    let result = "retry";
    let provider: string | null = null;
    try {
      const payload = messageFor(job, device.token, device.user_id);
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${
          encodeURIComponent(account.project_id)
        }/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(payload),
          signal: AbortSignal.timeout(12000),
        },
      );
      const body = await response.json();
      result = classify(response.status, body);
      if (result === "accepted") provider = body.name;
    } catch (error) {
      if (error instanceof Error && error.message === "expired") {
        result = "expired";
      }
      // Timeouts are ambiguous: a retry can produce a duplicate. Never log tokens.
    }
    await rpc("reminder_finish", {
      p_claim: job.claim_id,
      p_result: result,
      p_provider: provider,
    });
    return result;
  }));
  return {
    claimed: jobs.length,
    providerAccepted: results.filter((s) => s === "accepted").length,
  };
}

export async function handle(request: Request): Promise<Response> {
  const expected = Deno.env.get("REMINDER_WORKER_SECRET");
  if (!expected || request.headers.get("x-reminder-secret") !== expected) {
    return new Response("Unauthorized", { status: 401 });
  }
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }
  try {
    return Response.json(await run());
  } catch {
    return Response.json({
      error: "Worker failed; inspect configuration and database health",
    }, { status: 500 });
  }
}
