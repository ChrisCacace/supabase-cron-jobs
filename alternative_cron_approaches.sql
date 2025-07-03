-- Alternative approaches for cron jobs when HTTP extension is not available

-- Approach 1: Use pg_cron to call a PostgreSQL function that logs to a table
-- This can be used to trigger external monitoring systems

-- Create a logging table for cron events
CREATE TABLE IF NOT EXISTS cron_events (
    id SERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    event_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a function that logs the cron event
CREATE OR REPLACE FUNCTION log_cron_event()
RETURNS void AS $$
BEGIN
    INSERT INTO cron_events (event_type, event_data)
    VALUES ('dutchie_inventory_fetch', 
            jsonb_build_object(
                'timestamp', now(),
                'message', 'Cron job triggered - manual intervention required'
            ));
    
    -- You can also send notifications here if you have email/webhook setup
    RAISE NOTICE 'Cron job triggered at %', now();
END;
$$ LANGUAGE plpgsql;

-- Create the cron job to call this function every 15 minutes
SELECT cron.schedule(
    'dutchie-inventory-fetch',
    '*/15 * * * *',
    'SELECT log_cron_event();'
);

-- Approach 2: Use a different HTTP client approach
-- If you have access to plpython3u extension

-- First check if plpython3u is available
SELECT 
    name,
    default_version,
    installed_version
FROM pg_available_extensions 
WHERE name = 'plpython3u';

-- If plpython3u is available, you can create a Python function to make HTTP calls
-- CREATE EXTENSION IF NOT EXISTS plpython3u;
-- 
-- CREATE OR REPLACE FUNCTION call_edge_function_python()
-- RETURNS text AS $$
-- import urllib.request
-- import urllib.parse
-- import json
-- 
-- url = 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory'
-- headers = {
--     'Authorization': 'Bearer ' + 'your-service-role-key-here',
--     'Content-Type': 'application/json'
-- }
-- 
-- try:
--     req = urllib.request.Request(url, headers=headers)
--     with urllib.request.urlopen(req) as response:
--         return response.read().decode('utf-8')
-- except Exception as e:
--     return 'Error: ' + str(e)
-- $$ LANGUAGE plpython3u;

-- Approach 3: Use a simple notification system
-- Create a table to track when the function should be called
CREATE TABLE IF NOT EXISTS scheduled_tasks (
    id SERIAL PRIMARY KEY,
    task_name TEXT NOT NULL,
    last_run TIMESTAMPTZ,
    next_run TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert the task
INSERT INTO scheduled_tasks (task_name, next_run)
VALUES ('fetch-dutchie-inventory', 
        date_trunc('minute', now()) + 
        INTERVAL '15 minutes' * (EXTRACT(minute FROM now())::integer / 15 + 1));

-- Create a function to check and update the schedule
CREATE OR REPLACE FUNCTION check_scheduled_tasks()
RETURNS TABLE(task_name TEXT, should_run BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        st.task_name,
        CASE WHEN st.next_run <= now() THEN true ELSE false END as should_run
    FROM scheduled_tasks st
    WHERE st.is_active = true;
    
    -- Update next_run for tasks that should run
    UPDATE scheduled_tasks 
    SET next_run = next_run + INTERVAL '15 minutes',
        last_run = now()
    WHERE is_active = true 
      AND next_run <= now();
END;
$$ LANGUAGE plpgsql;

-- Create a cron job to check scheduled tasks every minute
SELECT cron.schedule(
    'check-scheduled-tasks',
    '* * * * *',
    'SELECT check_scheduled_tasks();'
); 