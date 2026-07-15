-- Portfolio reporting queries. All monetary values are in each account's currency.
SET search_path TO trading_journal, public;

-- 1. Overall win rate, based on closed trades and net P&L after costs.
SELECT
    COUNT(*) AS total_closed_trades,
    COUNT(*) FILTER (WHERE net_pnl > 0) AS winning_trades,
    COUNT(*) FILTER (WHERE net_pnl < 0) AS losing_trades,
    ROUND(100.0 * COUNT(*) FILTER (WHERE net_pnl > 0) / NULLIF(COUNT(*), 0), 2) AS win_rate_percent
FROM trades
WHERE trade_status = 'closed';

-- 2. Net profit by symbol.
SELECT i.symbol, COUNT(*) AS trade_count, ROUND(SUM(t.net_pnl), 2) AS net_profit
FROM trades t
JOIN instruments i ON i.instrument_id = t.instrument_id
WHERE t.trade_status = 'closed'
GROUP BY i.symbol
ORDER BY net_profit DESC;

-- 3. Net profit by strategy. Unclassified trades are retained as "Unclassified".
SELECT COALESCE(s.strategy_name, 'Unclassified') AS strategy,
       COUNT(*) AS trade_count,
       ROUND(SUM(t.net_pnl), 2) AS net_profit
FROM trades t
LEFT JOIN strategies s ON s.strategy_id = t.strategy_id
WHERE t.trade_status = 'closed'
GROUP BY COALESCE(s.strategy_name, 'Unclassified')
ORDER BY net_profit DESC;

-- 4. Monthly net profit and win rate.
SELECT date_trunc('month', closed_at)::date AS month,
       COUNT(*) AS trade_count,
       ROUND(SUM(net_pnl), 2) AS net_profit,
       ROUND(100.0 * COUNT(*) FILTER (WHERE net_pnl > 0) / COUNT(*), 2) AS win_rate_percent
FROM trades
WHERE trade_status = 'closed'
GROUP BY date_trunc('month', closed_at)::date
ORDER BY month;

-- 5. Best session by net P&L (with trade count included for context).
SELECT ts.session_name, COUNT(*) AS trade_count, ROUND(SUM(t.net_pnl), 2) AS net_profit
FROM trades t
JOIN trading_sessions ts ON ts.session_id = t.session_id
WHERE t.trade_status = 'closed'
GROUP BY ts.session_name
ORDER BY net_profit DESC
LIMIT 1;

-- 6. Average realised risk:reward. Positive values are wins; negatives are losses.
SELECT ROUND(AVG(net_pnl / NULLIF(risk_amount, 0)), 2) AS average_realised_r_multiple
FROM trades
WHERE trade_status = 'closed';

-- 7. Largest winning trade.
SELECT t.trade_id, tr.display_name AS trader, i.symbol, t.direction, t.closed_at, t.net_pnl
FROM trades t
JOIN trading_accounts a ON a.account_id = t.account_id
JOIN traders tr ON tr.trader_id = a.trader_id
JOIN instruments i ON i.instrument_id = t.instrument_id
WHERE t.trade_status = 'closed' AND t.net_pnl > 0
ORDER BY t.net_pnl DESC
LIMIT 1;

-- 8. Largest losing trade.
SELECT t.trade_id, tr.display_name AS trader, i.symbol, t.direction, t.closed_at, t.net_pnl
FROM trades t
JOIN trading_accounts a ON a.account_id = t.account_id
JOIN traders tr ON tr.trader_id = a.trader_id
JOIN instruments i ON i.instrument_id = t.instrument_id
WHERE t.trade_status = 'closed' AND t.net_pnl < 0
ORDER BY t.net_pnl
LIMIT 1;

-- 9. Total trades (all statuses) and closed trade count.
SELECT COUNT(*) AS total_trades,
       COUNT(*) FILTER (WHERE trade_status = 'closed') AS closed_trades
FROM trades;

-- 10. Current account balances: opening balance + cash ledger + closed-trade net P&L.
WITH cash_movements AS (
    SELECT account_id,
           SUM(CASE WHEN transaction_type IN ('deposit', 'adjustment_credit') THEN amount
                    ELSE -amount END) AS net_cash_movement
    FROM account_transactions
    GROUP BY account_id
),
trade_pnl AS (
    SELECT account_id, SUM(net_pnl) AS closed_trade_pnl
    FROM trades
    WHERE trade_status = 'closed'
    GROUP BY account_id
)
SELECT tr.display_name AS trader,
       a.account_name,
       a.currency_code,
       a.opening_balance,
       COALESCE(cm.net_cash_movement, 0) AS net_cash_movement,
       COALESCE(tp.closed_trade_pnl, 0) AS closed_trade_pnl,
       ROUND(a.opening_balance + COALESCE(cm.net_cash_movement, 0) + COALESCE(tp.closed_trade_pnl, 0), 2) AS current_balance
FROM trading_accounts a
JOIN traders tr ON tr.trader_id = a.trader_id
LEFT JOIN cash_movements cm ON cm.account_id = a.account_id
LEFT JOIN trade_pnl tp ON tp.account_id = a.account_id
ORDER BY tr.display_name, a.account_name;
