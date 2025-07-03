-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS call_fetch_dutchie_inventory();

-- Create a function to call the edge function using pg_net
CREATE OR REPLACE FUNCTION call_fetch_dutchie_inventory()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  response text;
BEGIN
  -- Call the edge function using pg_net
  SELECT content INTO response
  FROM net.http_post(
    url := 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory',
    headers := jsonb_build_object(
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys',
      'Content-Type', 'application/json'
    ),
    body := '{}'
  );
  
  -- Log the response (optional)
  RAISE NOTICE 'Cron job executed: %', response;
END;
$$;

-- Remove the existing cron job if it exists
SELECT cron.unschedule('fetch-dutchie-inventory-every-15-min');

-- Schedule the cron job to run every 15 minutes
SELECT cron.schedule(
  'fetch-dutchie-inventory-every-15-min',
  '*/15 * * * *',
  'SELECT call_fetch_dutchie_inventory();'
);

-- Test the function manually
SELECT call_fetch_dutchie_inventory();

-- Verify the cron job was created
SELECT * FROM cron.job WHERE jobname = 'fetch-dutchie-inventory-every-15-min'; 