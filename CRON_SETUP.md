# Cron Job Setup for Dutchie Inventory Fetch

## Option 1: GitHub Actions (Recommended)

This project includes a GitHub Actions workflow that runs every 15 minutes to fetch Dutchie inventory data.

### Setup Instructions:

1. **Push this repository to GitHub** (if not already done)

2. **Add the Supabase Service Role Key as a GitHub Secret:**
   - Go to your GitHub repository
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `SUPABASE_SERVICE_ROLE_KEY`
   - Value: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys`

3. **Enable GitHub Actions:**
   - The workflow will automatically start running once the secret is added
   - You can manually trigger it from the Actions tab

### Benefits:
- ✅ Reliable and free
- ✅ Easy to monitor and debug
- ✅ Can be manually triggered
- ✅ No additional infrastructure needed

## Option 2: Supabase Native Scheduler (Alternative)

If you prefer to use Supabase's native scheduler, you can run the migration manually:

1. **Access your Supabase Dashboard:**
   - Go to https://supabase.com/dashboard/project/zpfrcsydbgxssojtsefg
   - Navigate to SQL Editor

2. **Run the migration manually:**
   ```sql
   -- Enable pg_cron extension
   CREATE EXTENSION IF NOT EXISTS pg_cron;
   
   -- Create function to call edge function
   CREATE OR REPLACE FUNCTION call_fetch_dutchie_inventory()
   RETURNS void
   LANGUAGE plpgsql
   SECURITY DEFINER
   AS $$
   BEGIN
     PERFORM net.http_post(
       url := 'https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory',
       headers := jsonb_build_object(
         'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys',
         'Content-Type', 'application/json'
       ),
       body := '{}'
     );
   END;
   $$;
   
   -- Schedule cron job to run every 15 minutes
   SELECT cron.schedule(
     'fetch-dutchie-inventory-every-15-min',
     '*/15 * * * *',
     'SELECT call_fetch_dutchie_inventory();'
   );
   ```

## Monitoring

- **GitHub Actions:** Check the Actions tab in your repository
- **Supabase:** Check the Edge Functions logs in your Supabase dashboard
- **Database:** Query the `dutchie_inventory` table to see the latest data

## Manual Testing

You can manually trigger the function anytime:

```bash
curl -X POST https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys"
``` 