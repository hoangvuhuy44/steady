// Retired entry point. Deploy only after reviewing the target project's rollout.
// Archived worker.ts/fcm.ts remain for auditing older deployments and tests.
Deno.serve(() => new Response("Workout reminders use local notifications", { status: 410 }));
