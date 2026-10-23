-- Run manually ONLY on your development project after deploying the worker.
-- Enable pg_cron and pg_net in Supabase first. Put actual values in Vault
-- through the dashboard, not in committed SQL:
--   reminder_project_url = https://YOUR-PROJECT.supabase.co
--   reminder_worker_secret = the same REMINDER_WORKER_SECRET as the function
select cron.schedule('steady-workout-reminders', '* * * * *', $$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name='reminder_project_url')
      || '/functions/v1/reminder-worker',
    headers := jsonb_build_object('Content-Type','application/json','x-reminder-secret',
      (select decrypted_secret from vault.decrypted_secrets where name='reminder_worker_secret')),
    body := '{}'::jsonb,
    timeout_milliseconds := 50000
  );
$$);
-- Stop: select cron.unschedule('steady-workout-reminders');
