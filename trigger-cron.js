#!/usr/bin/env node

const https = require('https');

const SUPABASE_URL = 'https://zpfrcsydbgxssojtsefg.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZnJjc3lkYmd4c3NvanRzZWZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTE1ODgyNSwiZXhwIjoyMDY2NzM0ODI1fQ.Bi_Xa8BC2o5ADD55nBhtgGjhMo-IjJpdr7pRMsvzYys';

function triggerFunction() {
  const options = {
    hostname: 'zpfrcsydbgxssojtsefg.supabase.co',
    port: 443,
    path: '/functions/v1/fetch-dutchie-inventory',
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json'
    }
  };

  const req = https.request(options, (res) => {
    let data = '';
    
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      const timestamp = new Date().toISOString();
      console.log(`[${timestamp}] Function triggered with status: ${res.statusCode}`);
      
      try {
        const response = JSON.parse(data);
        console.log(`[${timestamp}] Response:`, JSON.stringify(response, null, 2));
      } catch (e) {
        console.log(`[${timestamp}] Raw response:`, data);
      }
    });
  });

  req.on('error', (error) => {
    const timestamp = new Date().toISOString();
    console.error(`[${timestamp}] Error triggering function:`, error.message);
  });

  req.end();
}

// Trigger the function
triggerFunction(); 