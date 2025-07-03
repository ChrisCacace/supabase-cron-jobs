-- Try different approaches to make HTTP requests

-- Approach 1: Try net.http_post (original approach)
SELECT 'Testing net.http_post...' as test;
SELECT
  net.http_post(
    url := 'https://httpbin.org/get',
    headers := jsonb_build_object('Content-Type', 'application/json'),
    body := '{}'::jsonb
  ) as result;

-- Approach 2: Try extensions.http_post
SELECT 'Testing extensions.http_post...' as test;
SELECT
  extensions.http_post(
    url := 'https://httpbin.org/get',
    headers := jsonb_build_object('Content-Type', 'application/json'),
    body := '{}'::jsonb
  ) as result;

-- Approach 3: Try public.http_post
SELECT 'Testing public.http_post...' as test;
SELECT
  public.http_post(
    url := 'https://httpbin.org/get',
    headers := jsonb_build_object('Content-Type', 'application/json'),
    body := '{}'::jsonb
  ) as result;

-- Approach 4: Try without schema prefix
SELECT 'Testing http_post without schema...' as test;
SELECT
  http_post(
    url := 'https://httpbin.org/get',
    headers := jsonb_build_object('Content-Type', 'application/json'),
    body := '{}'::jsonb
  ) as result;

-- Check what HTTP functions are actually available
SELECT 
  routine_name,
  routine_schema,
  parameter_name,
  parameter_mode,
  data_type
FROM information_schema.parameters 
WHERE routine_name LIKE '%http%'
ORDER BY routine_schema, routine_name, ordinal_position; 