-- =====================================================
-- Fintech Crypto Wallet App - Initial Schema
-- =====================================================
-- This migration creates the core tables for the MVP:
-- - profiles: Extended user data
-- - wallets: User crypto wallets
-- - transactions: Transaction history
-- All tables have RLS policies for data isolation
-- =====================================================

-- =====================================================
-- 1. PROFILES TABLE
-- =====================================================
-- Extends auth.users with additional user data
-- Created automatically via trigger on user signup

CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own profile
CREATE POLICY "own_profile_select" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "own_profile_update" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "own_profile_insert" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- 2. WALLETS TABLE
-- =====================================================
-- Stores user wallet balances and BTC address
-- Auto-created on first access

CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL UNIQUE,
  usd_balance NUMERIC(18,2) DEFAULT 0.00,
  btc_balance NUMERIC(18,8) DEFAULT 0.00000000,
  btc_address TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own wallet
CREATE POLICY "own_wallet_select" ON wallets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "own_wallet_update" ON wallets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "own_wallet_insert" ON wallets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);

-- =====================================================
-- 3. TRANSACTIONS TABLE
-- =====================================================
-- Records all BTC transactions (buy, sell, send, receive)

CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  type TEXT CHECK (type IN ('buy','sell','send','receive')) NOT NULL,
  amount_btc NUMERIC(18,8),
  amount_usd NUMERIC(18,2),
  btc_price_at_time NUMERIC(18,2),
  from_address TEXT,
  to_address TEXT,
  status TEXT CHECK (status IN ('pending','completed','failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own transactions
CREATE POLICY "own_transactions_select" ON transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "own_transactions_insert" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own_transactions_update" ON transactions
  FOR UPDATE USING (auth.uid() = user_id);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_user_type ON transactions(user_id, type);

-- =====================================================
-- 4. TRIGGER: Auto-create profile on user signup
-- =====================================================
-- This function creates a profile entry when a new user signs up

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 5. TRIGGER: Auto-update updated_at timestamp
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on wallets update
DROP TRIGGER IF EXISTS set_updated_at ON wallets;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON wallets
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- 6. HELPER FUNCTION: Generate mock BTC address
-- =====================================================
-- Generates a random mock BTC address for new wallets

CREATE OR REPLACE FUNCTION public.generate_mock_btc_address()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  result TEXT := '1';
  i INTEGER;
BEGIN
  FOR i IN 2..34 LOOP
    result := result || substring(chars from floor(random() * length(chars) + 1)::integer for 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. SEED DATA (Optional - for testing)
-- =====================================================
-- Uncomment below for local development seed data

-- INSERT INTO profiles (id, full_name)
-- VALUES ('00000000-0000-0000-0000-000000000001', 'Test User');

-- INSERT INTO wallets (user_id, usd_balance, btc_balance, btc_address)
-- VALUES (
--   '00000000-0000-0000-0000-000000000001',
--   1000.00,
--   0.05,
--   public.generate_mock_btc_address()
-- );
