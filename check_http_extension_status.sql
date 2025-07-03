-- Check HTTP extension status and available schemas
-- Run this to understand what's available in your Supabase instance

-- 1. Check if the http extension is installed
SELECT 
    extname as extension_name,
    extversion as version,
    extrelocatable as relocatable
FROM pg_extension 
WHERE extname = 'http';

-- 2. Check all available extensions
SELECT 
    extname as extension_name,
    extversion as version
FROM pg_extension 
ORDER BY extname;

-- 3. Check if the http extension can be created
SELECT 
    name,
    default_version,
    installed_version,
    comment
FROM pg_available_extensions 
WHERE name = 'http';

-- 4. Check all available extensions that might be useful
SELECT 
    name,
    default_version,
    installed_version,
    comment
FROM pg_available_extensions 
WHERE name IN ('http', 'pg_net', 'pg_cron', 'uuid-ossp', 'pgcrypto')
ORDER BY name;

-- 5. Check what schemas exist
SELECT 
    schema_name,
    schema_owner
FROM information_schema.schemata 
WHERE schema_name NOT LIKE 'pg_%' 
  AND schema_name != 'information_schema'
ORDER BY schema_name;

-- 6. Check if we can create the http extension
-- This will show if you have permission to create extensions
SELECT has_schema_privilege('public', 'CREATE') as can_create_in_public; 