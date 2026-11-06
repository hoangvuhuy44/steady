import { classify, type Delivery, messageFor } from "./fcm.ts";
import { handle } from "./worker.ts";

function equal(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`${actual} != ${expected}`);
  }
}
const job: Delivery = {
  event_id: "event-1",
  device_id: "device-1",
  claim_id: "claim-1",
  slot: "demo-evening",
  expires_at: "2026-10-22T11:40:00Z",
};
Deno.test("payload targets only registered device, with route, identity and remaining TTL", () => {
  const payload = messageFor(
    job,
    "one-token",
    "user-a",
    Date.parse("2026-10-22T11:35:00Z"),
  );
  equal(payload.message.token, "one-token");
  equal(payload.message.android.ttl, "300s");
  equal(payload.message.data, {
    screen: "check-in",
    reminder_id: "event-1",
    user_id: "user-a",
  });
  equal(
    payload.message.notification.body,
    "Tan làm rồi, đến giờ dành thời gian cho buổi tập.",
  );
  let expired = false;
  try {
    messageFor(job, "one-token", "user-a", Date.parse(job.expires_at));
  } catch {
    expired = true;
  }
  equal(expired, true);
});
Deno.test("provider accepted, expired token, retry and permanent failure are distinct", () => {
  equal(classify(200, {}), "accepted");
  equal(
    classify(404, { error: { details: [{ errorCode: "UNREGISTERED" }] } }),
    "unregistered",
  );
  equal(classify(404, {}), "rejected");
  equal(
    classify(400, { error: { details: [{ errorCode: "INVALID_ARGUMENT" }] } }),
    "rejected",
  );
  equal(classify(429, {}), "retry");
  equal(classify(503, {}), "retry");
});
Deno.test("scheduler endpoint rejects unauthenticated callers before touching credentials or jobs", async () => {
  equal(
    (await handle(new Request("http://localhost", { method: "POST" }))).status,
    401,
  );
});
