#!/bin/bash

echo "🚀 Setting up Supabase Cron Jobs Project"
echo "========================================"

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Installing..."
    npm install -g supabase
else
    echo "✅ Supabase CLI already installed"
fi

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "⚠️  Please edit .env with your actual API keys"
else
    echo "✅ .env file already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env with your actual API keys"
echo "2. Run: supabase start"
echo "3. Run: supabase functions deploy fetch-dutchie-inventory"
echo "4. Run: npm test"
echo ""
echo "📚 See README.md for detailed instructions" 