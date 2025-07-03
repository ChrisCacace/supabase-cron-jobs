-- Enable pg_cron extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create a function to call the edge function
CREATE OR REPLACE FUNCTION call_fetch_dutchie_inventory()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Call the edge function using http extension
  PERFORM net.http_post(
    url := 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory',
    headers := jsonb_build_object(
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys',
      'Content-Type', 'application/json'
    ),
    body := '{}'
  );
END;
$$;

-- Schedule the cron job to run every 15 minutes
SELECT cron.schedule(
  'fetch-dutchie-inventory-every-15-min',
  '*/15 * * * *',
  'SELECT call_fetch_dutchie_inventory();'
);

-- List all cron jobs to verify
SELECT * FROM cron.job; 