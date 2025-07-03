-- First, let's see what cron jobs exist
SELECT 
  jobid,
  jobname,
  schedule,
  active
FROM cron.job
ORDER BY jobid;

-- Delete cron jobs one by one
-- Replace 'job-name-here' with the actual job names from the query above
-- Run these commands for each cron job you want to delete:

-- Example: SELECT cron.unschedule('fetch-dutchie-inventory-every-minute');
-- Example: SELECT cron.unschedule('test-cron-job');

-- To delete all cron jobs, you can run this for each job:
-- SELECT cron.unschedule(jobname) FROM cron.job;

-- Verify cron jobs are deleted
SELECT 
  jobid,
  jobname,
  schedule,
  active
FROM cron.job
ORDER BY jobid;

-- If you want to delete a specific cron job by name, use:
-- SELECT cron.unschedule('job-name-here'); 