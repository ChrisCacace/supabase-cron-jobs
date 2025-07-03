-- Check if the http extension is properly enabled
SELECT 
  extname, 
  extversion 
FROM pg_extension 
WHERE extname = 'http';

-- Check if http functions are available in extensions schema
SELECT 
  routine_name,
  routine_schema
FROM information_schema.routines 
WHERE routine_schema = 'extensions' 
  AND routine_name LIKE '%http%';

-- Check current cron jobs
SELECT 
  jobid,
  jobname,
  schedule,
  active,
  command
FROM cron.job
ORDER BY jobid;

-- Check recent cron job runs (last 10)
SELECT 
  jobid,
  runid,
  job_pid,
  status,
  return_message,
  start_time,
  end_time
FROM cron.job_run_details
ORDER BY start_time DESC
LIMIT 10;

-- Test the http function directly to make sure it works
SELECT
  extensions.http_post(
    url := 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys'
    ),
    body := '{}'::jsonb
  ) as test_request_id;

-- Check cron job status and recent activity

-- 1. Check all active cron jobs
SELECT 
    jobid,
    schedule,
    command,
    active,
    created_at
FROM cron.job 
ORDER BY created_at DESC;

-- 2. Check recent cron job runs
SELECT 
    runid,
    jobid,
    job_pid,
    database,
    username,
    command,
    return_message,
    start_time,
    end_time,
    total_runtime
FROM cron.job_run 
ORDER BY start_time DESC 
LIMIT 10;

-- 3. Check our custom logs
SELECT 
    id,
    job_name,
    status,
    message,
    created_at
FROM cron_job_logs 
ORDER BY created_at DESC 
LIMIT 10;

-- 4. Check recent activity summary
SELECT * FROM get_recent_cron_activity(24);

-- 5. Check if cron extension is working
SELECT 
    extname,
    extversion
FROM pg_extension 
WHERE extname = 'pg_cron';

-- 6. Check cron worker status
SELECT 
    pid,
    application_name,
    client_addr,
    state,
    query_start,
    state_change
FROM pg_stat_activity 
WHERE application_name LIKE '%cron%' 
   OR query LIKE '%cron%'; 