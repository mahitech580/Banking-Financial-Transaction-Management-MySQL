# Run and deploy the Ledgerly banking dashboard

This repository keeps the original MySQL capstone SQL scripts and adds a browser dashboard plus an Express API. The dashboard talks to the API; the API talks to MySQL. Browser code never receives database credentials.

## Architecture

- **Frontend:** vanilla HTML, CSS and JavaScript in `public/`
- **API:** Node.js + Express in `server.js`
- **Database:** MySQL 8.0+ using the schema already defined by this project
- **Transactional transfer:** locks source and destination rows, validates status and funds, writes debit and credit transaction rows, updates balances, inserts a transfer record, and commits atomically. Errors roll the transaction back.

The hosted dashboard is a portfolio demonstration, not a real banking service. Use synthetic sample data only.

## Set up MySQL locally

1. Install and start MySQL 8.0+.
2. From the repository root, run the SQL files in this order:

   ```text
   01_database_schema.sql
   02_tables.sql
   03_constraints.sql
   04_reference_data.sql
   05_customer_data.sql
   06_account_data.sql
   07_transaction_data.sql
   29_demo_operations_data.sql   (recommended demo records)
   ```

3. The numbered query, analytics, view, procedure, function, trigger, transaction and index scripts can then be run as needed. Note that `01_database_schema.sql` drops and recreates the project database, so run it only against a disposable demo database.

## Start the application

Requires Node.js 20 or newer.

```bash
npm install
cp .env.example .env
npm start
```

On Windows PowerShell, copy the template with:

```powershell
Copy-Item .env.example .env
```

Edit `.env` with your own local database values. The app accepts either a single `MYSQL_URL` or `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, and `MYSQL_DATABASE`. Do not commit your real `.env` or database credentials.

Open [http://localhost:10000](http://localhost:10000). Check [http://localhost:10000/api/health](http://localhost:10000/api/health) to verify the database connection and schema visibility. The independent liveness endpoint is [http://localhost:10000/healthz](http://localhost:10000/healthz).

### Enable the transfer demo

Transfers are **disabled by default** to avoid exposing a public write endpoint accidentally. To test them, use only a private/local database filled with synthetic data and set:

```env
ENABLE_DEMO_TRANSFERS=true
```

Restart the server after changing the environment. The dashboard enables the transfer button only when both MySQL and the explicit transfer flag are ready. The API validates the account IDs and amount, requires both accounts to be active, rejects insufficient funds, locks accounts to prevent overlapping transfers, and rolls back on failure.

Do not enable this flag on production financial data. The demo is not an authenticated production banking system.

## Deploy to Render

A `render.yaml` Blueprint is included for the Node web service. To deploy:

1. Confirm the latest changes are pushed to the repository's `main` branch.
2. Open the Render Blueprint flow for this repository: [Create Blueprint](https://dashboard.render.com/blueprint/new?repo=https://github.com/mahitech580/Banking-Financial-Transaction-Management-MySQL).
3. Apply the Blueprint. The service uses Node, runs `npm install` and `npm start`, and checks `/healthz`.
4. In the service environment settings, supply `MYSQL_URL` as a secret value and set `MYSQL_SSL=true` if your managed MySQL provider requires TLS. Make sure the remote database allows connections from the application host.
5. Once deployed, open `/api/health` on the service URL and confirm it returns `"database":"connected"` before considering the database integration ready.

**Database provisioning is separate.** The Blueprint deploys the web app but does not create a MySQL database. Render's Blueprint database resource is PostgreSQL, not MySQL, so you need an existing reachable MySQL 8 database or a separate managed MySQL provider. Never paste credentials into the source code or README. Leave `ENABLE_DEMO_TRANSFERS=false` on the public service unless you have isolated it to synthetic test data and understand that this demo does not implement production authentication.

## API endpoints

| Endpoint | Purpose |
| --- | --- |
| `GET /healthz` | Liveness check; works without database credentials |
| `GET /api/health` | MySQL connection and configuration status |
| `GET /api/overview` | Dashboard metrics and latest transactions |
| `GET /api/customers?q=` | Search customers |
| `GET /api/accounts?q=` | Search accounts |
| `GET /api/transactions?q=&status=` | Search and filter transactions |
| `GET /api/analytics` | Daily, channel, type and customer aggregates |
| `GET /api/loans` | Loan and repayment summaries |
| `GET /api/fraud-events` | Recorded fraud events |
| `POST /api/transfers` | Atomic demo transfer; requires `ENABLE_DEMO_TRANSFERS=true` |

## Troubleshooting

- **Database not configured:** copy `.env.example` and set the MySQL values.
- **Access denied / timeout:** verify username, password, host, port, network allow-list and required TLS.
- **Missing tables:** create `banking_financial_management` by running setup scripts 01–07 in order.
- **Empty loan/fraud screens:** run `29_demo_operations_data.sql` after loading customers, accounts and transactions.
- **Render deploy is healthy but API says database offline:** the web process is running; set a valid reachable `MYSQL_URL` in Render and recheck `/api/health`.
