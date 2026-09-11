-- ==================================================
-- AGRIVYAAN SUPABASE DATABASE SCHEMA AND RLS POLICIES
-- Run this entire script in Supabase SQL Editor
-- ==================================================

-- ================================================
-- IMPORTANT: Enable Phone Auth in Supabase Dashboard
-- Authentication > Providers > Phone > Enable
-- If you don't have Twilio, use Email OTP instead
-- ================================================

-- 1. USERS / FARMER PROFILES TABLE
-- auth_id is nullable to support demo/offline users
CREATE TABLE IF NOT EXISTS users (
    fid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    phone VARCHAR(20),
    name VARCHAR(255) NOT NULL DEFAULT 'Farmer',
    location TEXT DEFAULT 'Wardha, Maharashtra',
    email TEXT,
    preferred_language VARCHAR(10) DEFAULT 'en',
    farm_area NUMERIC(10,2) DEFAULT 0.0,
    area_unit VARCHAR(20) DEFAULT 'acres',
    main_crop VARCHAR(100) DEFAULT 'Cotton',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow anon and authenticated users to select, insert, update profiles
-- NOTE: Phone Auth (Twilio) not configured, so inserts happen without a JWT session.
DROP POLICY IF EXISTS "Public select users" ON users;
DROP POLICY IF EXISTS "Public insert users" ON users;
DROP POLICY IF EXISTS "Public update users" ON users;
DROP POLICY IF EXISTS "Allow anon and authenticated select on users" ON users;
DROP POLICY IF EXISTS "Allow anon and authenticated insert on users" ON users;
DROP POLICY IF EXISTS "Allow anon and authenticated update on users" ON users;

CREATE POLICY "Allow select on users" ON users FOR SELECT USING (true);
CREATE POLICY "Allow insert on users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update on users" ON users FOR UPDATE USING (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON users TO anon, authenticated;

-- 2. FIELDS TABLE
CREATE TABLE IF NOT EXISTS fields (
    fieldid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fid UUID NOT NULL REFERENCES users(fid) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    crop VARCHAR(100) NOT NULL,
    area NUMERIC(10,2) NOT NULL DEFAULT 1.0,
    area_unit VARCHAR(20) DEFAULT 'acres',
    location TEXT,
    latitude NUMERIC(10,6),
    longitude NUMERIC(10,6),
    sowing_date TIMESTAMPTZ DEFAULT NOW(),
    crop_stage VARCHAR(100) DEFAULT 'Sowing',
    notes TEXT,
    health_score NUMERIC(5,2) DEFAULT 80,
    soil_moisture NUMERIC(5,2) DEFAULT 50,
    temperature NUMERIC(5,2) DEFAULT 28,
    humidity NUMERIC(5,2) DEFAULT 60,
    last_scan TIMESTAMPTZ DEFAULT NOW(),
    zones_json JSONB DEFAULT '[]'::jsonb,
    problems_json JSONB DEFAULT '[]'::jsonb,
    improvements_json JSONB DEFAULT '[]'::jsonb,
    sensors_json JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE fields ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Farmers can access own fields" ON fields;
DROP POLICY IF EXISTS "Allow all access on fields" ON fields;
CREATE POLICY "Allow all access on fields" ON fields FOR ALL USING (true) WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON fields TO anon, authenticated;

-- 3. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fid UUID NOT NULL REFERENCES users(fid) ON DELETE CASCADE,
    fieldid UUID REFERENCES fields(fieldid) ON DELETE CASCADE,
    date VARCHAR(50) NOT NULL,
    time VARCHAR(50),
    scan_type VARCHAR(100) NOT NULL,
    operator_name VARCHAR(255) DEFAULT 'Pending Assignment',
    status VARCHAR(50) NOT NULL DEFAULT 'REQUESTED',
    verification_status VARCHAR(50) DEFAULT 'PENDING',
    health_score INT DEFAULT 80,
    ai_report_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Farmers can access own bookings" ON bookings;
DROP POLICY IF EXISTS "Allow all access on bookings" ON bookings;
CREATE POLICY "Allow all access on bookings" ON bookings FOR ALL USING (true) WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON bookings TO anon, authenticated;

-- 4. SOIL_HEALTH TABLE
CREATE TABLE IF NOT EXISTS soil_health (
    shid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fid UUID NOT NULL REFERENCES users(fid) ON DELETE CASCADE,
    fieldid UUID REFERENCES fields(fieldid) ON DELETE SET NULL,
    ph NUMERIC(4,2),
    ec NUMERIC(6,2),
    organic_carbon NUMERIC(5,2),
    nitrogen NUMERIC(8,2),
    phosphorus NUMERIC(8,2),
    potassium NUMERIC(8,2),
    sulphur NUMERIC(8,2),
    card_number VARCHAR(100),
    sample_id VARCHAR(100),
    farmer_name VARCHAR(255),
    father_husband_name VARCHAR(255),
    village VARCHAR(100),
    tehsil VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    total_land_holding VARCHAR(100),
    registration_date TIMESTAMPTZ,
    sample_date TIMESTAMPTZ,
    upload_date TIMESTAMPTZ DEFAULT NOW(),
    soil_type VARCHAR(100),
    soil_colour VARCHAR(100),
    soil_texture VARCHAR(100),
    location TEXT,
    nutrients_json JSONB DEFAULT '[]'::jsonb,
    fertilizer_recommendations JSONB DEFAULT '[]'::jsonb,
    nutrient_recommendations JSONB DEFAULT '[]'::jsonb,
    crop_recommendations JSONB DEFAULT '[]'::jsonb,
    source_file_name TEXT,
    source_file_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_current BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE soil_health ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Farmers can access own soil health records" ON soil_health;
DROP POLICY IF EXISTS "Allow all access on soil_health" ON soil_health;
CREATE POLICY "Allow all access on soil_health" ON soil_health FOR ALL USING (true) WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON soil_health TO anon, authenticated;

-- 5. TRIGGER: auto-update updated_at on users
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_users_updated_at ON users;
CREATE TRIGGER set_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
