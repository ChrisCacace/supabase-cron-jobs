-- Check what extensions are enabled
SELECT 
  extname, 
  extversion 
FROM pg_extension 
ORDER BY extname;

-- Check all schemas that might contain http functions
SELECT 
  schema_name 
FROM information_schema.schemata 
WHERE schema_name LIKE '%http%' OR schema_name = 'extensions';

-- Check for http functions in all schemas
SELECT 
  routine_name,
  routine_schema,
  data_type
FROM information_schema.routines 
WHERE routine_name LIKE '%http%'
ORDER BY routine_schema, routine_name;

-- Check if there's a net schema
SELECT 
  schema_name 
FROM information_schema.schemata 
WHERE schema_name = 'net';

-- Check for http functions in the net schema if it exists
SELECT 
  routine_name,
  routine_schema,
  data_type
FROM information_schema.routines 
WHERE routine_schema = 'net' 
  AND routine_name LIKE '%http%';

-- Check what's in the extensions schema
SELECT 
  routine_name,
  routine_schema,
  data_type
FROM information_schema.routines 
WHERE routine_schema = 'extensions'
ORDER BY routine_name; 