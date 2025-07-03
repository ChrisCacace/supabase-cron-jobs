# Supabase Cron Jobs - Dutchie Inventory Sync

This project contains a Supabase Edge Function to fetch inventory data from the Dutchie API. This is Step 1 in a larger cron-based inventory sync system.

## Project Structure

```
supabase-cron-jobs/
├── supabase/
│   └── functions/
│       └── fetch-dutchie-inventory/
│           └── index.ts
├── README.md
└── .env.example
```

## Setup

### 1. Install Supabase CLI

```bash
npm install -g supabase
```

### 2. Initialize Supabase Project

```bash
supabase init
```

### 3. Link to Your Supabase Project

```bash
supabase link --project-ref YOUR_PROJECT_REF
```

### 4. Set Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Then edit `.env` with your actual values:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
DUTCHIE_API_KEY=your_dutchie_api_key
```

### 5. Deploy the Edge Function

```bash
supabase functions deploy fetch-dutchie-inventory
```

## Usage

### Testing the Function

You can test the function using curl:

```bash
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/fetch-dutchie-inventory \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### Expected Response

On success:
```json
{
  "success": true,
  "message": "Inventory data fetched successfully",
  "itemCount": 150,
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

On error:
```json
{
  "success": false,
  "error": "Dutchie API error: 401 Unauthorized",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## Configuration

### API Key Setup

Currently, the function uses a hardcoded API key. To use a dynamic API key from your users table:

1. Uncomment the code in `index.ts` that fetches from the users table
2. Comment out the hardcoded API key line
3. Ensure your users table has a `dutchie_api_key` column

### Dutchie API Endpoint

The function currently uses the basic inventory endpoint: `https://api.dutchie.com/v2/inventory`

You may need to adjust this based on your specific Dutchie API requirements.

## Logging

The function logs:
- Complete JSON response from Dutchie API
- Number of inventory items fetched
- Any errors that occur

Check your Supabase dashboard logs to see the output.

## Next Steps

This is Step 1 of the inventory sync system. Future steps will include:

1. **Step 2**: Store inventory data in Supabase database
2. **Step 3**: Set up cron job to run this function periodically
3. **Step 4**: Add data transformation and validation
4. **Step 5**: Implement error handling and retry logic
5. **Step 6**: Add monitoring and alerting

## Troubleshooting

### Common Issues

1. **401 Unauthorized**: Check your Dutchie API key
2. **403 Forbidden**: Verify your Supabase service role key
3. **Network errors**: Ensure the function has internet access

### Debug Mode

To see detailed logs, check the Supabase dashboard under Functions > Logs.

## Security Notes

- Never commit API keys to version control
- Use environment variables for all sensitive data
- Consider implementing rate limiting for production use
- The function currently allows CORS from all origins - restrict this for production # Last activity: Thu Jul  3 02:08:41 UTC 2025
