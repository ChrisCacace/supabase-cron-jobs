import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    console.log('Supabase URL:', supabaseUrl)
    console.log('Service Key exists:', !!supabaseServiceKey)
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Fetch raw API key from profiles table
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('dutchie_api_key')
      .not('dutchie_api_key', 'is', null)
      .limit(1)
      .single()
    
    console.log('Profile query result:', { profile, profileError })
    
    if (profileError || !profile?.dutchie_api_key) {
      throw new Error('No Dutchie API key found in profiles table')
    }
    
    const apiKey = profile.dutchie_api_key
    // Generate Basic Auth header dynamically
    const authHeader = 'Basic ' + btoa(`${apiKey}:`)
    
    // Dutchie API endpoint for inventory
    const dutchieInventoryUrl = 'https://api.pos.dutchie.com/reporting/inventory'
    // Make request to Dutchie API
    const response = await fetch(dutchieInventoryUrl, {
      method: 'GET',
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
        'User-Agent': 'Supabase-Edge-Function/1.0'
      }
    })

    if (!response.ok) {
      throw new Error(`Dutchie API error: ${response.status} ${response.statusText}`)
    }

    const inventoryData = await response.json()
    
    // Log the response for debugging
    console.log('Dutchie API Response:', JSON.stringify(inventoryData, null, 2))
    
    // Log some basic stats about the response
    if (inventoryData.data && Array.isArray(inventoryData.data)) {
      console.log(`Successfully fetched ${inventoryData.data.length} inventory items`)
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Inventory data fetched successfully',
        itemCount: inventoryData.data?.length || 0,
        timestamp: new Date().toISOString(),
        rawResponse: inventoryData // Include the actual response for debugging
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error fetching Dutchie inventory:', error)
    
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
}) 