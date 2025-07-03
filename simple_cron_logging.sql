-- Simple cron job approach that works without HTTP extensions
-- This creates a logging system that you can monitor externally

-- 1. Create a table to log cron events
CREATE TABLE IF NOT EXISTS cron_job_logs (
    id SERIAL PRIMARY KEY,
    job_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'triggered',
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create a function that logs the cron event
CREATE OR REPLACE FUNCTION log_dutchie_cron_event()
RETURNS void AS $$
BEGIN
    -- Log that the cron job was triggered
    INSERT INTO cron_job_logs (job_name, status, message)
    VALUES (
        'fetch-dutchie-inventory',
        'triggered',
        'Cron job triggered - edge function should be called manually or via external system'
    );
    
    -- Also log to PostgreSQL logs for debugging
    RAISE NOTICE 'Dutchie inventory cron job triggered at %', now();
END;
$$ LANGUAGE plpgsql;

-- 3. Create the cron job to run every 15 minutes
SELECT cron.schedule(
    'dutchie-inventory-fetch-every-15min',
    '*/15 * * * *',
    'SELECT log_dutchie_cron_event();'
);

-- 4. Verify the cron job was created
SELECT 
    jobid,
    schedule,
    command,
    nodename,
    nodeport,
    database,
    username,
    active
FROM cron.job 
WHERE command LIKE '%log_dutchie_cron_event%';

-- 5. Create a function to check recent cron activity
CREATE OR REPLACE FUNCTION get_recent_cron_activity(hours_back INTEGER DEFAULT 24)
RETURNS TABLE(
    job_name TEXT,
    last_triggered TIMESTAMPTZ,
    trigger_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cjl.job_name,
        MAX(cjl.created_at) as last_triggered,
        COUNT(*) as trigger_count
    FROM cron_job_logs cjl
    WHERE cjl.created_at >= now() - INTERVAL '1 hour' * hours_back
    GROUP BY cjl.job_name
    ORDER BY last_triggered DESC;
END;
$$ LANGUAGE plpgsql;

-- 6. Test the function
SELECT * FROM get_recent_cron_activity(1);

-- 7. Create a cleanup function to prevent the logs table from growing too large
CREATE OR REPLACE FUNCTION cleanup_old_cron_logs(days_to_keep INTEGER DEFAULT 7)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM cron_job_logs 
    WHERE created_at < now() - INTERVAL '1 day' * days_to_keep;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 8. Create a cron job to clean up old logs daily
SELECT cron.schedule(
    'cleanup-cron-logs-daily',
    '0 2 * * *', -- Run at 2 AM daily
    'SELECT cleanup_old_cron_logs(7);'
); 