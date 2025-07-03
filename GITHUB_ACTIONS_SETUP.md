# GitHub Actions Cron Job Setup

Since Supabase's native cron functionality isn't working in your instance, we'll use GitHub Actions which is actually more reliable and widely used for this purpose.

## Step-by-Step Setup

### 1. Push to GitHub
If you haven't already, push this repository to GitHub:
```bash
git add .
git commit -m "Add GitHub Actions cron job for Dutchie inventory"
git push origin main
```

### 2. Add the Supabase Service Role Key as a GitHub Secret

1. **Go to your GitHub repository**
2. **Navigate to Settings** → **Secrets and variables** → **Actions**
3. **Click "New repository secret"**
4. **Add the secret:**
   - **Name**: `SUPABASE_SERVICE_ROLE_KEY`
   - **Value**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys`

### 3. Enable GitHub Actions

1. **Go to the Actions tab** in your GitHub repository
2. **You should see the "Dutchie Inventory Cron Job" workflow**
3. **Click on it and then click "Run workflow"** to test it manually

### 4. Verify It's Working

- **Check the Actions tab** to see if the workflow ran successfully
- **Check your Supabase Edge Function logs** to see if the function was called
- **Query your database** to see if new inventory data was added

## Benefits of GitHub Actions

✅ **Reliable** - GitHub's infrastructure is very stable  
✅ **Free** - No additional costs  
✅ **Easy monitoring** - See all runs in the Actions tab  
✅ **Manual triggering** - Can run the job anytime  
✅ **Detailed logs** - Full execution history  
✅ **No infrastructure needed** - Runs on GitHub's servers  

## Monitoring

- **GitHub Actions**: Check the Actions tab for run history
- **Supabase Logs**: Check Edge Function logs for execution details
- **Database**: Query `dutchie_inventory` table for fresh data

## Manual Testing

You can manually trigger the workflow anytime from the Actions tab, or run this command:

```bash
curl -X POST https://zpfrcsydbgxssojtsefg.supabase.co/functions/v1/fetch-dutchie-inventory \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys"
```

## Troubleshooting

If the workflow fails:
1. Check the Actions tab for error details
2. Verify the `SUPABASE_SERVICE_ROLE_KEY` secret is correct
3. Check your Supabase Edge Function logs
4. Test the function manually first 