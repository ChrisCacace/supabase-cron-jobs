-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create a simple test function that just logs
CREATE OR REPLACE FUNCTION test_cron_log()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  -- Insert a log entry into a test table
  INSERT INTO cron_log (message, created_at)
  VALUES ('Cron job test executed at ' || now(), now());
  
  RAISE NOTICE 'Cron job test executed at %', now();
END;
$$;

-- Create a log table if it doesn't exist
CREATE TABLE IF NOT EXISTS cron_log (
  id SERIAL PRIMARY KEY,
  message TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Remove any existing test cron job
SELECT cron.unschedule('test-cron-job');

-- Schedule a test cron job to run every minute for testing
SELECT cron.schedule(
  'test-cron-job',
  '* * * * *',  -- Every minute for testing
  'SELECT test_cron_log();'
);

-- Verify the cron job was created
SELECT * FROM cron.job WHERE jobname = 'test-cron-job'; 