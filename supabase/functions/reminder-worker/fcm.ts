export type Delivery = {
  event_id: string;
  device_id: string;
  claim_id: string;
  slot: string;
  expires_at: string;
};

export function messageFor(
  job: Delivery,
  token: string,
  userId: string,
  now = Date.now(),
) {
  const ttl = Math.max(
    0,
    Math.floor((Date.parse(job.expires_at) - now) / 1000),
  );
  if (!ttl) throw new Error("expired");
  const evening = job.slot === "evening" || job.slot === "demo-evening";
  return {
    message: {
      token,
      notification: {
        title: "Steady · Nhắc tập",
        body: evening
          ? "Tan làm rồi, đến giờ dành thời gian cho buổi tập."
          : "Dành chút thời gian vận động sáng nay nhé.",
      },
      data: { screen: "check-in", reminder_id: job.event_id, user_id: userId },
      android: {
        priority: "high",
        ttl: `${ttl}s`,
        collapse_key: evening
          ? "steady-workout-evening"
          : "steady-workout-morning",
        notification: { tag: job.event_id, icon: "ic_stat_workout" },
      },
      apns: {
        headers: {
          "apns-expiration": `${Math.floor(Date.parse(job.expires_at) / 1000)}`,
          "apns-collapse-id": job.event_id,
          "apns-push-type": "alert",
          "apns-priority": "10",
        },
        payload: { aps: { sound: "default" } },
      },
    },
  };
}

export function classify(
  status: number,
  body: { error?: { details?: { errorCode?: string }[] } },
) {
  if (status >= 200 && status < 300) return "accepted";
  if (body.error?.details?.some((d) => d.errorCode === "UNREGISTERED")) {
    return "unregistered";
  }
  if (status === 429 || status >= 500) return "retry";
  return "rejected";
}

const encode = (value: Uint8Array) =>
  btoa(String.fromCharCode(...value))
    .replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
const utf8 = (value: string) => new TextEncoder().encode(value);

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

export async function googleAccessToken(
  account: ServiceAccount,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const part = (data: unknown) => encode(utf8(JSON.stringify(data)));
  const unsigned = `${part({ alg: "RS256", typ: "JWT" })}.${
    part({
      iss: account.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  }`;
  const pem = account.private_key.replace(/-----[^-]+-----/g, "").replace(
    /\s/g,
    "",
  );
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signed = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    utf8(unsigned),
  );
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${encode(new Uint8Array(signed))}`,
    }),
    signal: AbortSignal.timeout(12000),
  });
  if (!response.ok) throw new Error("FCM OAuth failed");
  const result = await response.json();
  if (typeof result.access_token !== "string") {
    throw new Error("FCM OAuth missing token");
  }
  return result.access_token;
}
