-- Sample data: 5 traders, 5 accounts, 6 instruments, 5 strategies, and 50 closed trades.
SET search_path TO trading_journal, public;

INSERT INTO traders (display_name, email, timezone) VALUES
  ('Aisha Khan', 'aisha.khan@example.com', 'Africa/Johannesburg'),
  ('Daniel Brooks', 'daniel.brooks@example.com', 'Europe/London'),
  ('Lerato Molefe', 'lerato.molefe@example.com', 'Africa/Johannesburg'),
  ('Marcus Chen', 'marcus.chen@example.com', 'America/New_York'),
  ('Sofia Rossi', 'sofia.rossi@example.com', 'Europe/Rome');

INSERT INTO brokers (broker_name, website_url) VALUES
  ('Apex Markets', 'https://www.apexmarkets.example'),
  ('Global Prime', 'https://www.globalprime.example'),
  ('IC Markets', 'https://www.icmarkets.example'),
  ('Eightcap', 'https://www.eightcap.example');

INSERT INTO account_types (type_name, description) VALUES
  ('Live', 'Live funded brokerage account.'),
  ('Demo', 'Simulated practice account.'),
  ('Prop Challenge', 'Proprietary trading firm evaluation account.');

INSERT INTO instruments (symbol, asset_class, base_currency, quote_currency) VALUES
  ('XAUUSD', 'metal', 'XAU', 'USD'),
  ('EURUSD', 'forex', 'EUR', 'USD'),
  ('GBPUSD', 'forex', 'GBP', 'USD'),
  ('NAS100', 'index', NULL, NULL),
  ('US30', 'index', NULL, NULL),
  ('BTCUSD', 'crypto', 'BTC', 'USD');

INSERT INTO strategies (strategy_name, description) VALUES
  ('London Breakout', 'Trades the break of the London-session range with predefined risk.'),
  ('New York Reversal', 'Fades an exhausted intraday move at a confirmed New York level.'),
  ('Trend Pullback', 'Enters a pullback in an established higher-timeframe trend.'),
  ('Range Mean Reversion', 'Targets a return to range equilibrium after a boundary rejection.'),
  ('News Momentum', 'Captures structured post-news continuation after volatility settles.');

INSERT INTO trading_sessions (session_name, session_start, session_end, description) VALUES
  ('Asia', '00:00', '08:00', 'Asian market session, expressed in UTC.'),
  ('London', '08:00', '13:00', 'London market session, expressed in UTC.'),
  ('New York', '13:00', '21:00', 'New York market session, expressed in UTC.'),
  ('London-New York Overlap', '13:00', '16:00', 'Highest-liquidity overlap, expressed in UTC.');

INSERT INTO trading_accounts (trader_id, broker_id, account_type_id, account_number, account_name, currency_code, opening_balance, opened_on) VALUES
  (1, 1, 1, 'AM-100245', 'Aisha Main', 'USD', 10000.00, '2025-01-02'),
  (2, 2, 3, 'GP-CH-8831', 'Daniel Challenge', 'USD', 50000.00, '2025-02-10'),
  (3, 3, 1, 'IC-778901', 'Lerato Swing', 'USD', 25000.00, '2025-01-15'),
  (4, 4, 2, 'EC-DEMO-442', 'Marcus Lab', 'USD', 100000.00, '2025-03-01'),
  (5, 1, 1, 'AM-100999', 'Sofia Main', 'USD', 15000.00, '2025-01-20');

INSERT INTO account_transactions (account_id, transaction_type, amount, occurred_at, reference, notes) VALUES
  (1, 'deposit', 2000.00, '2025-04-01 08:00+00', 'DEP-A-APR', 'Capital top-up'),
  (3, 'withdrawal', 1000.00, '2025-05-02 10:30+00', 'WDR-L-MAY', 'Partial profit withdrawal'),
  (5, 'deposit', 3000.00, '2025-06-03 09:15+00', 'DEP-S-JUN', 'Additional trading capital');

INSERT INTO tags (tag_name, description) VALUES
  ('A-setup', 'Trade fully matched the written plan.'),
  ('Countertrend', 'Trade was placed against the higher-timeframe trend.'),
  ('High-impact news', 'Trade had material news-event exposure.'),
  ('Rule deviation', 'Trade included a documented process deviation.'),
  ('Scale-out', 'Position was partially closed before final exit.');

-- Values: account, instrument, strategy, session, order ID, direction, opened, closed,
-- entry, exit, volume, stop, target, risk, gross P&L, commission, swap, notes.
INSERT INTO trades (account_id, instrument_id, strategy_id, session_id, broker_order_id, direction,
                    trade_status, opened_at, closed_at, entry_price, exit_price, volume,
                    stop_loss_price, take_profit_price, risk_amount, gross_pnl, commission, swap, setup_notes) VALUES
 (1,1,1,2,'A-0001','long','closed','2025-01-06 08:15+00','2025-01-06 11:40+00',2640.50000,2654.80000,0.5000,2635.50000,2655.50000,250.00,715.00,3.50,0.00,'Clean London range break.'),
 (1,2,3,2,'A-0002','short','closed','2025-01-09 09:20+00','2025-01-09 12:10+00',1.03120,1.02860,1.0000,1.03300,1.02700,180.00,260.00,7.00,0.00,'Trend pullback continuation.'),
 (1,4,2,3,'A-0003','long','closed','2025-01-14 14:05+00','2025-01-14 16:45+00',21120.00000,21055.00000,0.3000,21040.00000,21300.00000,240.00,-195.00,2.40,0.00,'Reversal failed at resistance.'),
 (1,3,1,2,'A-0004','long','closed','2025-02-03 08:40+00','2025-02-03 10:30+00',1.24200,1.24550,0.8000,1.23950,1.24600,200.00,280.00,5.60,0.00,'London breakout reached target.'),
 (1,6,5,3,'A-0005','short','closed','2025-02-12 15:10+00','2025-02-12 18:05+00',95800.00000,96350.00000,0.0500,96400.00000,94700.00000,300.00,-275.00,4.00,-1.25,'CPI volatility stop-out.'),
 (1,1,4,1,'A-0006','short','closed','2025-03-05 06:25+00','2025-03-05 07:50+00',2918.40000,2909.60000,0.4000,2924.00000,2908.00000,224.00,352.00,2.80,0.00,'Asia range rejection.'),
 (1,2,3,4,'A-0007','long','closed','2025-03-18 13:35+00','2025-03-18 15:20+00',1.08650,1.08380,0.7000,1.08350,1.09100,210.00,-189.00,4.90,0.00,'Pullback invalidated.'),
 (1,5,2,3,'A-0008','short','closed','2025-04-02 14:10+00','2025-04-02 17:00+00',42210.00000,41920.00000,0.2000,42360.00000,41900.00000,150.00,290.00,2.00,0.00,'NY reversal at weekly level.'),
 (1,3,5,4,'A-0009','long','closed','2025-04-11 13:10+00','2025-04-11 14:30+00',1.29600,1.29920,0.6000,1.29350,1.30050,150.00,192.00,4.20,0.00,'Post-data momentum continuation.'),
 (1,1,1,2,'A-0010','long','closed','2025-05-07 08:30+00','2025-05-07 12:15+00',3370.00000,3363.50000,0.3000,3362.00000,3386.00000,240.00,-195.00,2.10,0.00,'False breakout.'),
 (2,4,1,2,'D-0001','long','closed','2025-01-07 08:10+00','2025-01-07 12:50+00',21340.00000,21580.00000,0.5000,21220.00000,21580.00000,600.00,1200.00,4.00,0.00,'Strong opening-drive breakout.'),
 (2,1,3,4,'D-0002','short','closed','2025-01-16 13:25+00','2025-01-16 15:55+00',2722.00000,2710.00000,1.0000,2728.00000,2708.00000,600.00,1200.00,7.00,0.00,'Trend pullback on gold.'),
 (2,2,4,1,'D-0003','long','closed','2025-02-04 05:40+00','2025-02-04 07:15+00',1.03800,1.03620,2.0000,1.03600,1.04100,400.00,-360.00,14.00,0.00,'Range floor broke.'),
 (2,5,2,3,'D-0004','short','closed','2025-02-20 14:20+00','2025-02-20 16:10+00',44500.00000,44220.00000,0.4000,44640.00000,44200.00000,560.00,1120.00,4.00,0.00,'Reversal after liquidity sweep.'),
 (2,6,5,3,'D-0005','long','closed','2025-03-12 15:00+00','2025-03-12 18:20+00',82400.00000,81500.00000,0.1000,81500.00000,84200.00000,900.00,-900.00,8.00,-2.00,'FOMC whipsaw.'),
 (2,3,1,2,'D-0006','short','closed','2025-03-27 08:35+00','2025-03-27 11:25+00',1.28700,1.28100,1.5000,1.29000,1.28100,450.00,900.00,10.50,0.00,'London breakout continuation.'),
 (2,4,3,4,'D-0007','long','closed','2025-04-08 13:15+00','2025-04-08 15:10+00',20100.00000,20240.00000,0.4000,20020.00000,20340.00000,320.00,560.00,3.20,0.00,'Trend resumed after pullback.'),
 (2,1,2,3,'D-0008','long','closed','2025-04-22 14:35+00','2025-04-22 17:20+00',3285.00000,3279.00000,0.6000,3278.00000,3300.00000,420.00,-360.00,4.20,0.00,'Reversal lacked confirmation.'),
 (2,2,5,4,'D-0009','short','closed','2025-05-02 13:40+00','2025-05-02 14:50+00',1.13000,1.12600,1.5000,1.13300,1.12500,450.00,600.00,10.50,0.00,'NFP continuation.'),
 (2,5,1,2,'D-0010','long','closed','2025-05-19 09:05+00','2025-05-19 12:40+00',41800.00000,42080.00000,0.3000,41660.00000,42080.00000,420.00,840.00,3.00,0.00,'Breakout from consolidation.'),
 (3,3,3,2,'L-0001','long','closed','2025-01-08 09:10+00','2025-01-08 12:15+00',1.23500,1.23950,1.0000,1.23250,1.24000,250.00,450.00,7.00,0.00,'Daily trend pullback.'),
 (3,1,4,1,'L-0002','short','closed','2025-01-22 06:10+00','2025-01-22 07:30+00',2755.00000,2762.00000,0.4000,2762.00000,2740.00000,280.00,-280.00,2.80,0.00,'Range reversal stopped.'),
 (3,6,3,3,'L-0003','long','closed','2025-02-06 14:00+00','2025-02-06 19:40+00',96600.00000,98800.00000,0.0300,95800.00000,99000.00000,240.00,660.00,3.00,-0.75,'Bitcoin trend continuation.'),
 (3,2,1,2,'L-0004','short','closed','2025-02-25 08:25+00','2025-02-25 11:05+00',1.05200,1.05500,0.8000,1.05500,1.04700,240.00,-240.00,5.60,0.00,'Failed breakout entry.'),
 (3,4,2,4,'L-0005','short','closed','2025-03-11 13:20+00','2025-03-11 15:30+00',19800.00000,19650.00000,0.3000,19880.00000,19640.00000,240.00,450.00,2.40,0.00,'NY reversal into imbalance.'),
 (3,5,5,3,'L-0006','long','closed','2025-03-21 14:05+00','2025-03-21 16:30+00',43000.00000,42800.00000,0.2500,42800.00000,43400.00000,200.00,-200.00,2.50,0.00,'News follow-through failed.'),
 (3,1,1,2,'L-0007','long','closed','2025-04-03 08:20+00','2025-04-03 11:45+00',3100.00000,3112.00000,0.5000,3094.00000,3112.00000,300.00,600.00,3.50,0.00,'London break to target.'),
 (3,3,4,1,'L-0008','long','closed','2025-04-17 05:50+00','2025-04-17 07:10+00',1.32500,1.32200,0.7000,1.32200,1.32900,210.00,-210.00,4.90,0.00,'Asia range loss.'),
 (3,2,3,4,'L-0009','short','closed','2025-05-08 13:30+00','2025-05-08 15:00+00',1.12200,1.11850,1.0000,1.12400,1.11800,200.00,350.00,7.00,0.00,'Pullback short aligned with trend.'),
 (3,6,5,3,'L-0010','short','closed','2025-05-28 15:30+00','2025-05-28 20:10+00',108400.00000,106900.00000,0.0250,109000.00000,106800.00000,150.00,375.00,2.50,-0.50,'Momentum short after data release.'),
 (4,4,3,2,'M-0001','long','closed','2025-01-10 08:30+00','2025-01-10 12:05+00',20950.00000,21100.00000,0.8000,20875.00000,21175.00000,600.00,1200.00,6.40,0.00,'Demo trend pullback.'),
 (4,5,1,2,'M-0002','short','closed','2025-01-28 09:00+00','2025-01-28 11:50+00',44800.00000,45000.00000,0.5000,45000.00000,44400.00000,500.00,-500.00,5.00,0.00,'Breakout faded too early.'),
 (4,1,2,3,'M-0003','long','closed','2025-02-14 14:15+00','2025-02-14 16:55+00',2930.00000,2942.00000,0.8000,2924.00000,2948.00000,480.00,960.00,5.60,0.00,'Confirmed NY reversal.'),
 (4,2,4,1,'M-0004','short','closed','2025-02-28 06:30+00','2025-02-28 07:45+00',1.04700,1.04950,1.2000,1.04950,1.04300,300.00,-300.00,8.40,0.00,'Range high did not hold.'),
 (4,6,3,3,'M-0005','long','closed','2025-03-14 15:10+00','2025-03-14 18:40+00',83800.00000,85400.00000,0.0500,83000.00000,85400.00000,400.00,800.00,4.00,-1.00,'Higher-low trend entry.'),
 (4,3,5,4,'M-0006','short','closed','2025-03-28 13:25+00','2025-03-28 14:40+00',1.29400,1.29700,1.0000,1.29700,1.28800,300.00,-300.00,7.00,0.00,'News momentum reversed.'),
 (4,4,1,2,'M-0007','long','closed','2025-04-09 08:45+00','2025-04-09 12:20+00',20300.00000,20520.00000,0.5000,20190.00000,20520.00000,550.00,1100.00,4.00,0.00,'London breakout winner.'),
 (4,5,2,3,'M-0008','short','closed','2025-04-24 14:10+00','2025-04-24 16:00+00',40000.00000,40150.00000,0.4000,40150.00000,39600.00000,300.00,-300.00,4.00,0.00,'Reversal stopped at high.'),
 (4,1,3,4,'M-0009','short','closed','2025-05-09 13:20+00','2025-05-09 15:50+00',3320.00000,3308.00000,0.5000,3326.00000,3302.00000,300.00,600.00,3.50,0.00,'Gold pullback short.'),
 (4,2,1,2,'M-0010','long','closed','2025-05-22 08:15+00','2025-05-22 11:30+00',1.12800,1.13200,1.0000,1.12600,1.13200,200.00,400.00,7.00,0.00,'EURUSD breakout.'),
 (5,5,3,2,'S-0001','short','closed','2025-01-13 08:50+00','2025-01-13 12:00+00',42100.00000,41900.00000,0.2000,42200.00000,41900.00000,200.00,400.00,2.00,0.00,'Trend pullback on US30.'),
 (5,3,1,2,'S-0002','long','closed','2025-01-30 09:15+00','2025-01-30 11:35+00',1.23800,1.23500,0.6000,1.23500,1.24400,180.00,-180.00,4.20,0.00,'Breakout immediately failed.'),
 (5,1,5,3,'S-0003','long','closed','2025-02-11 14:05+00','2025-02-11 16:20+00',2900.00000,2910.00000,0.4000,2895.00000,2910.00000,200.00,400.00,2.80,0.00,'Inflation news continuation.'),
 (5,6,4,1,'S-0004','short','closed','2025-02-26 06:20+00','2025-02-26 07:40+00',88000.00000,89000.00000,0.0200,89000.00000,86000.00000,200.00,-200.00,2.00,-0.50,'Range short stopped.'),
 (5,2,3,4,'S-0005','long','closed','2025-03-06 13:30+00','2025-03-06 15:05+00',1.07900,1.08300,0.9000,1.07700,1.08300,180.00,360.00,6.30,0.00,'Trend pullback target hit.'),
 (5,4,2,3,'S-0006','short','closed','2025-03-19 14:25+00','2025-03-19 16:45+00',20200.00000,20300.00000,0.3000,20300.00000,19900.00000,300.00,-300.00,2.40,0.00,'NY reversal loss.'),
 (5,3,5,4,'S-0007','short','closed','2025-04-04 13:15+00','2025-04-04 14:25+00',1.30300,1.29800,0.7000,1.30550,1.29800,175.00,350.00,4.90,0.00,'Data-driven GBP momentum.'),
 (5,5,1,2,'S-0008','long','closed','2025-04-16 08:40+00','2025-04-16 12:10+00',39800.00000,40100.00000,0.2500,39650.00000,40100.00000,375.00,750.00,2.50,0.00,'London breakout winner.'),
 (5,1,4,1,'S-0009','short','closed','2025-05-13 05:55+00','2025-05-13 07:20+00',3240.00000,3246.00000,0.3000,3246.00000,3228.00000,180.00,-180.00,2.10,0.00,'Asia mean reversion loss.'),
 (5,6,3,3,'S-0010','long','closed','2025-05-30 15:20+00','2025-05-30 19:15+00',104000.00000,106000.00000,0.0200,103000.00000,106000.00000,200.00,400.00,2.00,-0.50,'BTC trend continuation.');

INSERT INTO trade_tags (trade_id, tag_id) VALUES
  (1,1), (3,4), (5,3), (8,1), (11,1), (15,3), (18,4), (19,3),
  (21,1), (23,5), (25,1), (26,3), (27,1), (30,3), (33,1), (35,5),
  (37,1), (38,4), (41,1), (43,3), (45,1), (47,3), (48,1), (50,5);
