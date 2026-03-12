-- =====================================================
-- Trade Functions - Buy/Sell BTC
-- =====================================================
-- Atomic functions for trading BTC
-- These functions handle wallet updates and transaction creation
-- in a single atomic operation to prevent race conditions
-- =====================================================

-- =====================================================
-- 1. BUY BTC FUNCTION
-- =====================================================
-- Deducts USD from wallet and adds BTC at the current price
-- Creates a transaction record automatically

CREATE OR REPLACE FUNCTION public.buy_btc(
  p_user_id UUID,
  p_usd_amount NUMERIC,
  p_btc_amount NUMERIC,
  p_btc_price NUMERIC
)
RETURNS JSONB AS $$
DECLARE
  v_wallet_id UUID;
  v_new_usd_balance NUMERIC;
  v_new_btc_balance NUMERIC;
  v_transaction_id UUID;
  v_result JSONB;
BEGIN
  -- Get current wallet
  SELECT id, usd_balance, btc_balance
  INTO v_wallet_id, v_new_usd_balance, v_new_btc_balance
  FROM wallets
  WHERE user_id = p_user_id
  FOR UPDATE;

  -- Check if wallet exists
  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for user %', p_user_id;
  END IF;

  -- Check sufficient USD balance
  IF v_new_usd_balance < p_usd_amount THEN
    RAISE EXCEPTION 'Insufficient USD balance. Required: %, Available: %', p_usd_amount, v_new_usd_balance;
  END IF;

  -- Deduct USD and add BTC
  v_new_usd_balance := v_new_usd_balance - p_usd_amount;
  v_new_btc_balance := v_new_btc_balance + p_btc_amount;

  -- Update wallet
  UPDATE wallets
  SET usd_balance = v_new_usd_balance,
      btc_balance = v_new_btc_balance,
      updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Create transaction record
  INSERT INTO transactions (
    user_id,
    type,
    amount_btc,
    amount_usd,
    btc_price_at_time,
    status,
    created_at
  ) VALUES (
    p_user_id,
    'buy',
    p_btc_amount,
    p_usd_amount,
    p_btc_price,
    'completed',
    NOW()
  ) RETURNING id INTO v_transaction_id;

  -- Return updated wallet and transaction
  SELECT jsonb_build_object(
    'wallet', (SELECT row_to_json(w.*) FROM wallets w WHERE w.id = v_wallet_id),
    'transaction', (SELECT row_to_json(t.*) FROM transactions t WHERE t.id = v_transaction_id)
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 2. SELL BTC FUNCTION
-- =====================================================
-- Deducts BTC from wallet and adds USD at the current price
-- Creates a transaction record automatically

CREATE OR REPLACE FUNCTION public.sell_btc(
  p_user_id UUID,
  p_btc_amount NUMERIC,
  p_usd_amount NUMERIC,
  p_btc_price NUMERIC
)
RETURNS JSONB AS $$
DECLARE
  v_wallet_id UUID;
  v_new_usd_balance NUMERIC;
  v_new_btc_balance NUMERIC;
  v_transaction_id UUID;
  v_result JSONB;
BEGIN
  -- Get current wallet
  SELECT id, usd_balance, btc_balance
  INTO v_wallet_id, v_new_usd_balance, v_new_btc_balance
  FROM wallets
  WHERE user_id = p_user_id
  FOR UPDATE;

  -- Check if wallet exists
  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for user %', p_user_id;
  END IF;

  -- Check sufficient BTC balance
  IF v_new_btc_balance < p_btc_amount THEN
    RAISE EXCEPTION 'Insufficient BTC balance. Required: %, Available: %', p_btc_amount, v_new_btc_balance;
  END IF;

  -- Deduct BTC and add USD
  v_new_btc_balance := v_new_btc_balance - p_btc_amount;
  v_new_usd_balance := v_new_usd_balance + p_usd_amount;

  -- Update wallet
  UPDATE wallets
  SET usd_balance = v_new_usd_balance,
      btc_balance = v_new_btc_balance,
      updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Create transaction record
  INSERT INTO transactions (
    user_id,
    type,
    amount_btc,
    amount_usd,
    btc_price_at_time,
    status,
    created_at
  ) VALUES (
    p_user_id,
    'sell',
    p_btc_amount,
    p_usd_amount,
    p_btc_price,
    'completed',
    NOW()
  ) RETURNING id INTO v_transaction_id;

  -- Return updated wallet and transaction
  SELECT jsonb_build_object(
    'wallet', (SELECT row_to_json(w.*) FROM wallets w WHERE w.id = v_wallet_id),
    'transaction', (SELECT row_to_json(t.*) FROM transactions t WHERE t.id = v_transaction_id)
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. TRANSFER BTC FUNCTION (Send to another user)
-- =====================================================
-- Sends BTC from one user to another
-- Creates transaction records for both sender and recipient

CREATE OR REPLACE FUNCTION public.send_btc(
  p_sender_id UUID,
  p_recipient_address TEXT,
  p_btc_amount NUMERIC
)
RETURNS JSONB AS $$
DECLARE
  v_sender_wallet_id UUID;
  v_recipient_wallet_id UUID;
  v_sender_new_balance NUMERIC;
  v_recipient_new_balance NUMERIC;
  v_sender_tx_id UUID;
  v_recipient_tx_id UUID;
  v_btc_price NUMERIC;
  v_usd_amount NUMERIC;
  v_result JSONB;
BEGIN
  -- Get sender wallet
  SELECT id, btc_balance
  INTO v_sender_wallet_id, v_sender_new_balance
  FROM wallets
  WHERE user_id = p_sender_id
  FOR UPDATE;

  -- Check if sender wallet exists
  IF v_sender_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Sender wallet not found';
  END IF;

  -- Check sufficient BTC balance
  IF v_sender_new_balance < p_btc_amount THEN
    RAISE EXCEPTION 'Insufficient BTC balance. Required: %, Available: %', p_btc_amount, v_sender_new_balance;
  END IF;

  -- Find recipient wallet by address
  SELECT id, btc_balance
  INTO v_recipient_wallet_id, v_recipient_new_balance
  FROM wallets
  WHERE btc_address = p_recipient_address
  FOR UPDATE;

  -- Get current BTC price for USD valuation
  -- In production, this would fetch from market table or use a snapshot
  v_btc_price := 0;
  v_usd_amount := p_btc_amount * v_btc_price;

  -- Deduct from sender
  v_sender_new_balance := v_sender_new_balance - p_btc_amount;
  UPDATE wallets
  SET btc_balance = v_sender_new_balance,
      updated_at = NOW()
  WHERE id = v_sender_wallet_id;

  -- Create sender transaction (send)
  INSERT INTO transactions (
    user_id,
    type,
    amount_btc,
    amount_usd,
    btc_price_at_time,
    to_address,
    status,
    created_at
  ) VALUES (
    p_sender_id,
    'send',
    p_btc_amount,
    v_usd_amount,
    v_btc_price,
    p_recipient_address,
    'completed',
    NOW()
  ) RETURNING id INTO v_sender_tx_id;

  -- If recipient found (internal transfer), credit them
  IF v_recipient_wallet_id IS NOT NULL THEN
    v_recipient_new_balance := v_recipient_new_balance + p_btc_amount;
    UPDATE wallets
    SET btc_balance = v_recipient_new_balance,
        updated_at = NOW()
    WHERE id = v_recipient_wallet_id;

    -- Create recipient transaction (receive)
    INSERT INTO transactions (
      user_id,
      type,
      amount_btc,
      amount_usd,
      btc_price_at_time,
      from_address,
      status,
      created_at
    ) VALUES (
      (SELECT user_id FROM wallets WHERE id = v_recipient_wallet_id),
      'receive',
      p_btc_amount,
      v_usd_amount,
      v_btc_price,
      (SELECT btc_address FROM wallets WHERE id = v_sender_wallet_id),
      'completed',
      NOW()
    ) RETURNING id INTO v_recipient_tx_id;
  END IF;

  -- Return result
  SELECT jsonb_build_object(
    'sender_tx_id', v_sender_tx_id,
    'recipient_tx_id', v_recipient_tx_id,
    'is_internal_transfer', v_recipient_wallet_id IS NOT NULL
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.buy_btc TO authenticated;
GRANT EXECUTE ON FUNCTION public.sell_btc TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_btc TO authenticated;
