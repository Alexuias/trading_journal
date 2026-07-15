# Trading Journal Database

A portfolio-quality PostgreSQL database for recording, analysing, and reporting on discretionary trading activity. The project models traders, brokerage accounts, instruments, strategies, trading sessions, completed trades, account cash movements, and optional trade tags.

## Technologies

- PostgreSQL 15+ (the SQL uses `timestamptz`, generated columns, triggers, and partial indexes)
- SQL / PLpgSQL
- Mermaid for the ERD

## Design decisions

- **Amounts use `numeric`, not floating point.** Currency and price calculations must be exact at the stored precision.
- **Profit and loss is recorded per trade; outcome is derived.** Storing both would create a conflicting source of truth. `net_pnl` is a generated column from gross P&L, commission, and swap.
- **Current balance is calculated, not stored.** It is the opening balance plus signed cash movements plus closed-trade net P&L. This prevents balance drift.
- **Reference data is separated.** Brokers, account types, instruments, strategies, sessions, and tags are reusable entities rather than repeated text on every trade.
- **Trade tags use a junction table.** A trade can have many tags and a tag can label many trades, without a comma-separated field.

See [ERD.md](ERD.md) for entity rationale and relationships.

## Project layout

```text
project/
├── README.md
├── ERD.md
├── schema.sql
├── insert_data.sql
├── constraints.sql
├── indexes.sql
└── queries.sql
```

## Setup

Create a PostgreSQL database, then run the scripts in this exact order from this directory:

```bash
psql -v ON_ERROR_STOP=1 -U postgres -d trading_journal -f schema.sql
psql -v ON_ERROR_STOP=1 -U postgres -d trading_journal -f insert_data.sql
psql -v ON_ERROR_STOP=1 -U postgres -d trading_journal -f constraints.sql
psql -v ON_ERROR_STOP=1 -U postgres -d trading_journal -f indexes.sql
psql -v ON_ERROR_STOP=1 -U postgres -d trading_journal -f queries.sql
```

All project tables are created in the custom `trading_journal` schema, not `public`:

```text
Databases
└── trading_journal
    └── Schemas
        └── trading_journal
            └── Tables
```

## Maintenance

`schema.sql` deliberately recreates the `trading_journal` schema, so it is suitable for local development but removes all existing project data in that schema. Back up important data before rerunning it.

Run the scripts in this order: `schema.sql`, `insert_data.sql`, `constraints.sql`, `indexes.sql`, then `queries.sql`. Use `psql -v ON_ERROR_STOP=1` as shown above so execution stops immediately if a script fails.

## Example reporting

`queries.sql` includes portfolio-ready queries for overall win rate, profit by symbol and strategy, monthly P&L, best session, average realised risk:reward, largest gains/losses, trade count, and calculated current account balances.

For example, the current balance query combines data from `trading_accounts`, `account_transactions`, and `trades`; there is no redundant mutable balance column to get out of sync.

All supplied sample data uses USD. If accounts with multiple currencies are introduced later, monetary reports should group results by `currency_code` or use exchange-rate conversion before combining totals.

## Integrity and performance

The design uses primary and foreign keys, unique keys, check constraints, generated columns, a trigger that allows trades only on active accounts belonging to active traders, and targeted reporting indexes. Details are documented in [ERD.md](ERD.md), with executable definitions in `schema.sql`, `constraints.sql`, and `indexes.sql`.

## Future improvements

- Add `trade_executions` for partial fills and scale-ins/scale-outs.
- Add exchange-rate snapshots to support native account currencies and consolidated reporting.
- Add attachments/screenshots stored in object storage with a metadata table.
- Add row-level security for a multi-tenant API.
- Add materialized monthly performance summaries when data volume warrants it.
