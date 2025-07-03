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

    // Fetch all profiles with Dutchie API keys
    const { data: profiles, error: profileError } = await supabase
      .from('profiles')
      .select('dutchie_api_key, email')
      .not('dutchie_api_key', 'is', null)
    
    console.log('Profiles query result:', { profiles, profileError })
    
    if (profileError || !profiles || profiles.length === 0) {
      throw new Error('No profiles with Dutchie API keys found')
    }
    
    console.log(`Found ${profiles.length} profiles with Dutchie API keys`)
    
    const results: Array<{
      email: string;
      success: boolean;
      itemsProcessed?: number;
      itemsStored?: number;
      error?: string;
    }> = []
    let totalItemsProcessed = 0
    
    // Process each profile
    for (const profile of profiles) {
      if (!profile.dutchie_api_key || !profile.email) {
        console.log(`Skipping profile with missing API key or email: ${profile.email}`)
        continue
      }
      
      try {
        console.log(`Processing profile: ${profile.email}`)
        
        const apiKey = profile.dutchie_api_key
        const profileEmail = profile.email
        
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
          throw new Error(`Dutchie API error for ${profileEmail}: ${response.status} ${response.statusText}`)
        }

        const inventoryData = await response.json()
        console.log(`Fetched ${inventoryData.length} inventory items for ${profileEmail}`)
        
        // Store inventory data in database
        if (inventoryData && Array.isArray(inventoryData) && inventoryData.length > 0) {
          // Prepare data for insertion
          const inventoryItems = inventoryData.map((item: any) => ({
            profile_email: profileEmail,
            unit_weight_unit: item.unitWeightUnit,
            unit_cost: item.unitCost,
            allocated_quantity: item.allocatedQuantity,
            inventory_id: item.inventoryId,
            product_id: item.productId,
            sku: item.sku,
            product_name: item.productName,
            description: item.description,
            category_id: item.categoryId,
            category: item.category,
            image_url: item.imageUrl,
            quantity_available: item.quantityAvailable,
            quantity_units: item.quantityUnits,
            unit_weight: item.unitWeight,
            flower_equivalent: item.flowerEquivalent,
            rec_flower_equivalent: item.recFlowerEquivalent,
            flower_equivalent_units: item.flowerEquivalentUnits,
            batch_id: item.batchId,
            batch_name: item.batchName,
            package_id: item.packageId,
            package_status: item.packageStatus,
            unit_price: item.unitPrice,
            med_unit_price: item.medUnitPrice,
            rec_unit_price: item.recUnitPrice,
            strain_id: item.strainId,
            strain: item.strain,
            strain_type: item.strainType,
            size: item.size,
            lab_results: item.labResults,
            tested_date: item.testedDate,
            sample_date: item.sampleDate,
            packaged_date: item.packagedDate,
            manufacturing_date: item.manufacturingDate,
            last_modified_date_utc: item.lastModifiedDateUtc,
            lab_test_status: item.labTestStatus,
            vendor_id: item.vendorId,
            vendor: item.vendor,
            expiration_date: item.expirationDate,
            room_quantities: item.roomQuantities,
            pricing_tier_name: item.pricingTierName,
            alternate_name: item.alternateName,
            tags: item.tags,
            brand_id: item.brandId,
            brand_name: item.brandName,
            medical_only: item.medicalOnly,
            external_package_id: item.externalPackageId,
            producer: item.producer,
            producer_id: item.producerId,
            potency_indicator: item.potencyIndicator,
            master_category: item.masterCategory,
            effective_potency_mg: item.effectivePotencyMg,
            is_cannabis: item.isCannabis,
            package_ndc: item.packageNDC
          }))
          
          // Clear existing inventory for this user
          const { error: deleteError } = await supabase
            .from('dutchie_inventory')
            .delete()
            .eq('profile_email', profileEmail)
          
          if (deleteError) {
            console.error(`Error clearing existing inventory for ${profileEmail}:`, deleteError)
          }
          
          // Insert new inventory data
          const { data: insertedData, error: insertError } = await supabase
            .from('dutchie_inventory')
            .insert(inventoryItems)
            .select()
          
          if (insertError) {
            console.error(`Error inserting inventory data for ${profileEmail}:`, insertError)
            throw new Error(`Failed to store inventory data for ${profileEmail}: ${insertError.message}`)
          }
          
          console.log(`Successfully stored ${insertedData?.length || 0} inventory items for ${profileEmail}`)
          
          results.push({
            email: profileEmail,
            success: true,
            itemsProcessed: inventoryData.length,
            itemsStored: insertedData?.length || 0
          })
          
          totalItemsProcessed += inventoryData.length
        } else {
          console.log(`No inventory data found for ${profileEmail}`)
          results.push({
            email: profileEmail,
            success: true,
            itemsProcessed: 0,
            itemsStored: 0
          })
        }
        
      } catch (error) {
        console.error(`Error processing profile ${profile.email}:`, error)
        results.push({
          email: profile.email,
          success: false,
          error: error.message
        })
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Inventory data fetched and stored for all profiles with API keys',
        profilesProcessed: profiles.length,
        totalItemsProcessed,
        results,
        timestamp: new Date().toISOString()
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