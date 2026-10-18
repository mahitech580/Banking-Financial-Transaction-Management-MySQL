# Security Policy

## Intended use

This repository is an educational portfolio project. It is not a production banking service and does not provide production-grade identity verification, authentication, authorization, regulatory controls, reconciliation, or operational controls. All visible seed records are synthetic.

## Safe configuration

- Never commit `.env`, passwords, database URLs, API keys or production records.
- Use a database account with only the permissions needed for the demo.
- Restrict remote MySQL access to trusted hosts and use TLS when the provider requires it.
- Keep `ENABLE_DEMO_TRANSFERS=false` on publicly accessible instances.
- Enable transfers only against an isolated disposable database containing synthetic data.
- Do not use actual customer, cardholder, account or loan information.
- Back up any database before running the destructive reset script `01_database_schema.sql`; it drops and recreates the demo database.
- Review configuration and access rules before making a deployed service public.

## Reporting a vulnerability

Please do not publish credentials or private customer data in issues. Report suspected vulnerabilities privately to the repository owner through GitHub's private vulnerability reporting feature when available, or contact the owner through the email shown on the GitHub profile.

## Scope limitations

The transfer endpoint is intentionally a demonstration of SQL transactions and row locking. It is not a substitute for an authenticated payment system with idempotency keys, a balanced double-entry ledger, reconciliation, fraud controls, rate limiting, access auditing and independent review.
