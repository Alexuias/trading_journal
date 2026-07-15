-- Reporting indexes. Primary and UNIQUE constraints already create their own indexes.
SET search_path TO trading_journal, public;

-- Filters a trader's account list and supports the join behind account-scoped reports.
CREATE INDEX idx_trading_accounts_trader_id ON trading_accounts (trader_id);

-- Primary access path for account history and account-balance calculations.
CREATE INDEX idx_trades_account_closed_at
    ON trades (account_id, closed_at DESC)
    WHERE trade_status = 'closed';

-- Supports date-range P&L reporting across all accounts.
CREATE INDEX idx_trades_closed_at
    ON trades (closed_at DESC)
    WHERE trade_status = 'closed';

-- Supports symbol, strategy, and session performance aggregation with closed trades only.
CREATE INDEX idx_trades_closed_instrument ON trades (instrument_id, closed_at DESC)
    WHERE trade_status = 'closed';
CREATE INDEX idx_trades_closed_strategy ON trades (strategy_id, closed_at DESC)
    WHERE trade_status = 'closed' AND strategy_id IS NOT NULL;
CREATE INDEX idx_trades_closed_session ON trades (session_id, closed_at DESC)
    WHERE trade_status = 'closed' AND session_id IS NOT NULL;

-- Supports account cash-ledger rollups in balance reporting.
CREATE INDEX idx_account_transactions_account_occurred
    ON account_transactions (account_id, occurred_at DESC);

-- At larger scale, consider a materialized monthly-performance view refreshed on a schedule.
-- For multi-tenant deployments, add RLS policies keyed to traders.trader_id.
