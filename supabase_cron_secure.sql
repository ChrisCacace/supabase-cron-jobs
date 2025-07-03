-- Enable the required extensions
CREATE EXTENSION IF NOT EXISTS "pg_cron";
CREATE EXTENSION IF NOT EXISTS "http";

-- First, let's store the service role key in the vault (you'll need to do this in Supabase dashboard)
-- Go to Settings > Database > Vault and add a secret named 'service_role_key' with your service role key

-- Create a cron job that triggers the fetch-dutchie-inventory edge function every minute
-- This version uses vault secrets for better security
SELECT
  cron.schedule(
    'fetch-dutchie-inventory-every-minute',
    '* * * * *', -- every minute
    $$
    SELECT
      net.http_post(
        url := 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'service_role_key')
        ),
        body := '{}'::jsonb
      ) as request_id;
    $$
  );

-- Check if the cron job was created successfully
SELECT * FROM cron.job WHERE jobname = 'fetch-dutchie-inventory-every-minute';

-- List all cron jobs to verify
SELECT jobid, jobname, schedule, active FROM cron.job; 