# Getting a Fresh Supabase Service Role Key

The 401 error suggests the JWT token might be expired or invalid. Here's how to get a fresh token:

## Method 1: From Supabase Dashboard

1. **Go to your Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/zpfrcsydbgxssojtsefg
   - Click on **Settings** (gear icon) in the left sidebar
   - Click on **API** in the settings menu

2. **Copy the Service Role Key:**
   - Look for **"service_role"** key (not the anon key)
   - Copy the entire key (it should start with `eyJ...`)

3. **Update the GitHub Secret:**
   - Go to your GitHub repository: https://github.com/ChrisCacace/supabase-cron-jobs
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Find `SUPABASE_SERVICE_ROLE_KEY` and click **Update**
   - Paste the fresh service role key

## Method 2: Using Supabase CLI

If you have the Supabase CLI installed:

```bash
# Get the current project info
supabase status

# Or get the service role key directly
supabase secrets list
```

## Method 3: Check if the current token is still valid

The current token we've been using:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys
```

You can decode this JWT at https://jwt.io to see if it's expired.

## After updating the secret:

1. **Go to GitHub Actions** and run the workflow manually
2. **Check the logs** to see if the authentication works
3. **The workflow should now run successfully** every 15 minutes

## Test the new token locally:

```bash
curl -X POST https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory \
  -H "Authorization: Bearer YOUR_NEW_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{}'
``` 