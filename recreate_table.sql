-- Drop existing table
DROP TABLE IF EXISTS public.dutchie_inventory;

-- Recreate table with larger decimal fields
CREATE TABLE public.dutchie_inventory (
    id BIGSERIAL PRIMARY KEY,
    profile_email TEXT REFERENCES public.profiles(email) ON DELETE CASCADE,
    unit_weight_unit TEXT,
    unit_cost DECIMAL(15,5),
    allocated_quantity DECIMAL(15,5),
    inventory_id BIGINT,
    product_id BIGINT,
    sku TEXT,
    product_name TEXT,
    description TEXT,
    category_id BIGINT,
    category TEXT,
    image_url TEXT,
    quantity_available DECIMAL(15,4),
    quantity_units TEXT,
    unit_weight DECIMAL(15,4),
    flower_equivalent DECIMAL(15,6),
    rec_flower_equivalent DECIMAL(15,6),
    flower_equivalent_units TEXT,
    batch_id BIGINT,
    batch_name TEXT,
    package_id TEXT,
    package_status TEXT,
    unit_price DECIMAL(15,8),
    med_unit_price DECIMAL(15,8),
    rec_unit_price DECIMAL(15,8),
    strain_id BIGINT,
    strain TEXT,
    strain_type TEXT,
    size TEXT,
    lab_results TEXT,
    tested_date TIMESTAMP WITH TIME ZONE,
    sample_date TIMESTAMP WITH TIME ZONE,
    packaged_date TIMESTAMP WITH TIME ZONE,
    manufacturing_date TIMESTAMP WITH TIME ZONE,
    last_modified_date_utc TIMESTAMP WITH TIME ZONE,
    lab_test_status TEXT,
    vendor_id BIGINT,
    vendor TEXT,
    expiration_date TIMESTAMP WITH TIME ZONE,
    room_quantities TEXT,
    pricing_tier_name TEXT,
    alternate_name TEXT,
    tags JSONB,
    brand_id BIGINT,
    brand_name TEXT,
    medical_only BOOLEAN,
    external_package_id TEXT,
    producer TEXT,
    producer_id BIGINT,
    potency_indicator TEXT,
    master_category TEXT,
    effective_potency_mg DECIMAL(15,2),
    is_cannabis BOOLEAN,
    package_ndc TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_dutchie_inventory_profile_email ON public.dutchie_inventory(profile_email);
CREATE INDEX idx_dutchie_inventory_inventory_id ON public.dutchie_inventory(inventory_id);
CREATE INDEX idx_dutchie_inventory_product_id ON public.dutchie_inventory(product_id);
CREATE INDEX idx_dutchie_inventory_sku ON public.dutchie_inventory(sku);
CREATE INDEX idx_dutchie_inventory_category ON public.dutchie_inventory(category);
CREATE INDEX idx_dutchie_inventory_created_at ON public.dutchie_inventory(created_at);

-- Add RLS (Row Level Security) policy
ALTER TABLE public.dutchie_inventory ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to see only their own inventory data
CREATE POLICY "Users can view their own dutchie inventory" ON public.dutchie_inventory
    FOR SELECT USING (auth.jwt() ->> 'email' = profile_email);

-- Create policy to allow service role to insert/update/delete
CREATE POLICY "Service role can manage dutchie inventory" ON public.dutchie_inventory
    FOR ALL USING (auth.role() = 'service_role'); 