#!/usr/bin/env node

/**
 * Simple test script for the Dutchie inventory Edge Function
 * Run this after starting the Supabase local development environment
 */

const fetch = require('node-fetch');

async function testFunction() {
  try {
    console.log('🧪 Testing Dutchie Inventory Edge Function...\n');
    
    const response = await fetch('http://localhost:54321/functions/v1/fetch-dutchie-inventory', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
      }
    });

    const data = await response.json();
    
    console.log('📊 Response Status:', response.status);
    console.log('📄 Response Data:', JSON.stringify(data, null, 2));
    
    if (data.success) {
      console.log('\n✅ Function executed successfully!');
      console.log(`📦 Fetched ${data.itemCount} inventory items`);
    } else {
      console.log('\n❌ Function failed:', data.error);
    }
    
  } catch (error) {
    console.error('\n💥 Test failed:', error.message);
    console.log('\n💡 Make sure:');
    console.log('   1. Supabase is running locally: supabase start');
    console.log('   2. The function is deployed: supabase functions deploy fetch-dutchie-inventory');
    console.log('   3. Your Dutchie API key is set in the function');
  }
}

testFunction(); 