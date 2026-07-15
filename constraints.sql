-- Additional cross-table integrity rules.
SET search_path TO trading_journal, public;

-- A database CHECK constraint cannot safely inspect another table. This trigger
-- ensures new or amended trades always belong to an active account and trader.
CREATE OR REPLACE FUNCTION enforce_trade_owner_is_active()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM trading_accounts a
        JOIN traders tr ON tr.trader_id = a.trader_id
        WHERE a.account_id = NEW.account_id
          AND a.account_status = 'active'
          AND tr.is_active
    ) THEN
        RAISE EXCEPTION 'Trades require an active account owned by an active trader (account_id=%)', NEW.account_id
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_trades_require_active_owner
BEFORE INSERT OR UPDATE OF account_id ON trades
FOR EACH ROW
EXECUTE FUNCTION enforce_trade_owner_is_active();

-- Documentation comments make the operational rules discoverable in psql clients.
COMMENT ON FUNCTION enforce_trade_owner_is_active() IS
    'Rejects a trade assigned to a suspended/archived account or inactive trader.';
COMMENT ON CONSTRAINT ck_trades_lifecycle ON trades IS
    'Closed trades require exit data and chronological timestamps; open/cancelled trades cannot have exit data.';
COMMENT ON CONSTRAINT ck_account_transactions_amount ON account_transactions IS
    'Amounts are positive; transaction_type determines whether the balance effect is positive or negative.';
