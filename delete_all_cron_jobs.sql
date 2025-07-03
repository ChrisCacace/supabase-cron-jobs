-- Show existing cron jobs
SELECT 
  jobid,
  jobname,
  schedule,
  active
FROM cron.job
ORDER BY jobid;

-- Delete all cron jobs using a loop
DO $$
DECLARE
    job_record RECORD;
BEGIN
    FOR job_record IN SELECT jobname FROM cron.job LOOP
        PERFORM cron.unschedule(job_record.jobname);
        RAISE NOTICE 'Deleted cron job: %', job_record.jobname;
    END LOOP;
END $$;

-- Verify all cron jobs are deleted
SELECT 
  jobid,
  jobname,
  schedule,
  active
FROM cron.job
ORDER BY jobid; 