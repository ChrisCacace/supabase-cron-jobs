-- Check if pg_cron extension is enabled
SELECT 
  extname, 
  extversion 
FROM pg_extension 
WHERE extname = 'pg_cron';

-- List all existing cron jobs
SELECT 
  jobid,
  jobname,
  schedule,
  active,
  command
FROM cron.job
ORDER BY jobid;

-- Count total cron jobs
SELECT 
  COUNT(*) as total_cron_jobs
FROM cron.job;

-- Check recent cron job runs
SELECT 
  jobid,
  job_pid,
  database,
  username,
  command,
  return_message,
  start_time,
  end_time,
  total_runtime
FROM cron.job_run_details
ORDER BY start_time DESC
LIMIT 10;

-- Check if http extension is enabled (needed for HTTP requests)
SELECT 
  extname, 
  extversion 
FROM pg_extension 
WHERE extname = 'http'; 