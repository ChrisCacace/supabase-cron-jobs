-- Enable the required extensions
CREATE EXTENSION IF NOT EXISTS "pg_cron";
CREATE EXTENSION IF NOT EXISTS "http";

-- Create a cron job that triggers the fetch-dutchie-inventory edge function every minute
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
          'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys'
        ),
        body := '{}'::jsonb
      ) as request_id;
    $$
  );

-- Check if the cron job was created successfully
SELECT * FROM cron.job WHERE jobname = 'fetch-dutchie-inventory-every-minute';

-- List all cron jobs to verify
SELECT jobid, jobname, schedule, active FROM cron.job; 