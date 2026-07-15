-- Trading Journal Database: core schema
-- Rerunnable local-development setup. This removes only the project schema.

DROP SCHEMA IF EXISTS trading_journal CASCADE;
CREATE SCHEMA trading_journal;
SET search_path TO trading_journal, public;

CREATE TABLE traders (
    trader_id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    display_name    varchar(100) NOT NULL,
    email           varchar(254) NOT NULL UNIQUE,
    timezone        varchar(64) NOT NULL DEFAULT 'UTC',
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_traders_email_format CHECK (email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

CREATE TABLE brokers (
    broker_id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    broker_name     varchar(100) NOT NULL UNIQUE,
    website_url     varchar(255),
    is_active       boolean NOT NULL DEFAULT true
);

CREATE TABLE account_types (
    account_type_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_name       varchar(50) NOT NULL UNIQUE,
    description     text NOT NULL
);

CREATE TABLE instruments (
    instrument_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    symbol          varchar(20) NOT NULL UNIQUE,
    asset_class     varchar(20) NOT NULL,
    base_currency   char(3),
    quote_currency  char(3),
    is_active       boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_instruments_asset_class CHECK (asset_class IN ('forex', 'metal', 'index', 'crypto', 'commodity', 'equity')),
    CONSTRAINT ck_instruments_currency_pair CHECK (
        (base_currency IS NULL AND quote_currency IS NULL)
        OR (base_currency ~ '^[A-Z]{3}$' AND quote_currency ~ '^[A-Z]{3}$')
    )
);

CREATE TABLE strategies (
    strategy_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    strategy_name   varchar(100) NOT NULL UNIQUE,
    description     text NOT NULL,
    is_active       boolean NOT NULL DEFAULT true
);

CREATE TABLE trading_sessions (
    session_id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_name    varchar(50) NOT NULL UNIQUE,
    session_start   time NOT NULL,
    session_end     time NOT NULL,
    description     text NOT NULL
);

CREATE TABLE trading_accounts (
    account_id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trader_id       bigint NOT NULL REFERENCES traders(trader_id),
    broker_id       bigint NOT NULL REFERENCES brokers(broker_id),
    account_type_id bigint NOT NULL REFERENCES account_types(account_type_id),
    account_number  varchar(64) NOT NULL,
    account_name    varchar(100) NOT NULL,
    currency_code   char(3) NOT NULL DEFAULT 'USD',
    opening_balance numeric(18,2) NOT NULL DEFAULT 0,
    account_status  varchar(20) NOT NULL DEFAULT 'active',
    opened_on       date NOT NULL DEFAULT current_date,
    created_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_accounts_broker_number UNIQUE (broker_id, account_number),
    CONSTRAINT ck_accounts_currency CHECK (currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_accounts_opening_balance CHECK (opening_balance >= 0),
    CONSTRAINT ck_accounts_status CHECK (account_status IN ('active', 'archived', 'suspended'))
);

CREATE TABLE trades (
    trade_id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id       bigint NOT NULL REFERENCES trading_accounts(account_id),
    instrument_id    bigint NOT NULL REFERENCES instruments(instrument_id),
    strategy_id      bigint REFERENCES strategies(strategy_id),
    session_id       bigint REFERENCES trading_sessions(session_id),
    broker_order_id  varchar(100),
    direction        varchar(5) NOT NULL,
    trade_status     varchar(10) NOT NULL DEFAULT 'open',
    opened_at        timestamptz NOT NULL,
    closed_at        timestamptz,
    entry_price      numeric(20,8) NOT NULL,
    exit_price       numeric(20,8),
    volume           numeric(18,4) NOT NULL,
    stop_loss_price  numeric(20,8),
    take_profit_price numeric(20,8),
    risk_amount      numeric(18,2) NOT NULL,
    gross_pnl        numeric(18,2) NOT NULL DEFAULT 0,
    commission       numeric(18,2) NOT NULL DEFAULT 0,
    swap             numeric(18,2) NOT NULL DEFAULT 0,
    net_pnl          numeric(18,2) GENERATED ALWAYS AS (gross_pnl - commission + swap) STORED,
    setup_notes      text,
    created_at       timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_trades_account_broker_order UNIQUE (account_id, broker_order_id),
    CONSTRAINT ck_trades_direction CHECK (direction IN ('long', 'short')),
    CONSTRAINT ck_trades_status CHECK (trade_status IN ('open', 'closed', 'cancelled')),
    CONSTRAINT ck_trades_prices CHECK (entry_price > 0 AND (exit_price IS NULL OR exit_price > 0)
        AND (stop_loss_price IS NULL OR stop_loss_price > 0)
        AND (take_profit_price IS NULL OR take_profit_price > 0)),
    CONSTRAINT ck_trades_volume CHECK (volume > 0),
    CONSTRAINT ck_trades_risk CHECK (risk_amount > 0),
    CONSTRAINT ck_trades_lifecycle CHECK (
        (trade_status = 'closed' AND closed_at > opened_at AND exit_price IS NOT NULL)
        OR (trade_status = 'open' AND closed_at IS NULL AND exit_price IS NULL)
        OR (trade_status = 'cancelled' AND closed_at IS NULL AND exit_price IS NULL AND gross_pnl = 0 AND commission = 0 AND swap = 0)
    )
);

CREATE TABLE account_transactions (
    account_transaction_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id      bigint NOT NULL REFERENCES trading_accounts(account_id),
    transaction_type varchar(20) NOT NULL,
    amount           numeric(18,2) NOT NULL,
    occurred_at      timestamptz NOT NULL DEFAULT now(),
    reference        varchar(100),
    notes            text,
    CONSTRAINT ck_account_transactions_type CHECK (transaction_type IN ('deposit', 'withdrawal', 'adjustment_credit', 'adjustment_debit')),
    CONSTRAINT ck_account_transactions_amount CHECK (amount > 0),
    CONSTRAINT uq_account_transactions_reference UNIQUE (account_id, reference)
);

CREATE TABLE tags (
    tag_id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag_name        varchar(50) NOT NULL UNIQUE,
    description     text
);

CREATE TABLE trade_tags (
    trade_id        bigint NOT NULL REFERENCES trades(trade_id) ON DELETE CASCADE,
    tag_id          bigint NOT NULL REFERENCES tags(tag_id) ON DELETE RESTRICT,
    PRIMARY KEY (trade_id, tag_id)
);

COMMENT ON TABLE trades IS 'One journalled trade/position. P&L is denominated in its account currency.';
COMMENT ON COLUMN trades.net_pnl IS 'Generated: gross_pnl - commission + swap.';
