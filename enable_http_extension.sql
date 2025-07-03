-- Enable HTTP extension for making HTTP requests from PostgreSQL
-- This is needed for cron jobs to call edge functions

-- First, try to create the http extension
CREATE EXTENSION IF NOT EXISTS http;

-- Check if it was created successfully
SELECT 
    extname as extension_name,
    extversion as version
FROM pg_extension 
WHERE extname = 'http';

-- If the above fails, try creating it in the extensions schema
-- CREATE EXTENSION IF NOT EXISTS http SCHEMA extensions;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA http TO postgres;
GRANT USAGE ON SCHEMA http TO anon;
GRANT USAGE ON SCHEMA http TO authenticated;
GRANT USAGE ON SCHEMA http TO service_role;

-- Check what HTTP functions are now available
SELECT 
    routine_name,
    routine_schema,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'http'
ORDER BY routine_name; 