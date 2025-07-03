-- First, let's check what extensions are currently enabled
SELECT 
  extname, 
  extversion 
FROM pg_extension 
ORDER BY extname;

-- Enable the http extension properly
CREATE EXTENSION IF NOT EXISTS "http" SCHEMA extensions;

-- Check if the net schema now exists
SELECT 
  schema_name 
FROM information_schema.schemata 
WHERE schema_name = 'net';

-- Check if http functions are available
SELECT 
  routine_name,
  routine_schema
FROM information_schema.routines 
WHERE routine_schema = 'extensions' 
  AND routine_name LIKE '%http%';

-- Now let's update the cron job to use the correct schema
-- First, let's see what cron jobs exist
SELECT 
  jobid,
  jobname,
  schedule,
  active
FROM cron.job
ORDER BY jobid;

-- Delete the existing cron job
SELECT cron.unschedule('fetch-dutchie-inventory-every-minute');

-- Create a new cron job with the correct http function call
SELECT
  cron.schedule(
    'fetch-dutchie-inventory-every-minute',
    '* * * * *', -- every minute
    $$
    SELECT
      extensions.http_post(
        url := 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys'
        ),
        body := '{}'::jsonb
      ) as request_id;
    $$
  );

-- Verify the new cron job was created
SELECT 
  jobid,
  jobname,
  schedule,
  active
FROM cron.job 
WHERE jobname = 'fetch-dutchie-inventory-every-minute'; 