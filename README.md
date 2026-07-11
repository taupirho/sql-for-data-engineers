# SQL Patterns Every Data Engineer Should Know

*Practical solutions to common ETL and pipeline problems*

This repository contains the reproducible SQLite examples for the article. The examples focus on seven recurring data-engineering tasks:

1. Deduplicating records with a deterministic winning-row rule
2. Finding missing records with an anti-join
3. Loading incrementally with a high-water mark and overlap
4. Detecting changed records, including `NULL` values
5. Calculating rolling metrics over rows and calendar ranges
6. Sessionising events with `LAG()` and cumulative window functions
7. Reconciling source and target tables

The sample data is intentionally imperfect: it includes duplicate customer versions, missing orders, a late-arriving event, changed values, tied timestamps, missing dates, and source/target discrepancies.

## Requirements

- Windows 10 or later
- SQLite command-line tools for Windows
- PowerShell or Command Prompt

## Setup on Windows

1. Download the SQLite tools from the [official SQLite download page](https://www.sqlite.org/download.html). Under **Precompiled Binaries for Windows**, download `sqlite-tools-win-x64-<version>.zip`.
2. Extract it to a directory such as `C:\sqlite`.
3. Either use the full executable path or add the directory to the current PowerShell session:

```powershell
$env:Path += ";C:\sqlite"
sqlite3 --version
```

From the repository root, create the practice database:

```powershell
sqlite3 sql-patterns-practice.db ".read sql/sqlite-setup.sql"
```

Open it interactively if required:

```powershell
sqlite3 sql-patterns-practice.db
```

The setup script is safe to rerun because it drops and recreates the example tables. The generated database is ignored by Git.

## Run the examples

Each pattern is a standalone script intended to be run against `sql-patterns-practice.db`:

```powershell
sqlite3 -header -column sql-patterns-practice.db ".read sql/01-deduplication.sql"
sqlite3 -header -column sql-patterns-practice.db ".read sql/02-anti-join.sql"
sqlite3 -header -column sql-patterns-practice.db ".read sql/03-high-water-mark.sql"
sqlite3 -header -column sql-patterns-practice.db ".read sql/04-changed-records.sql"
sqlite3 -header -column sql-patterns-practice.db ".read sql/05-rolling-metrics.sql"
sqlite3 -header -column sql-patterns-practice.db ".read sql/06-sessionisation.sql"
sqlite3 -header -column sql-patterns-practice.db ".read sql/07-reconciliation.sql"
```

The scripts return result sets; they do not modify the sample tables.

## Repository layout

```text
sql-patterns-every-data-engineer-should-know/
â”œâ”€â”€ .gitignore
â”œâ”€â”€ CONTRIBUTING.md
â”œâ”€â”€ LICENSE
â”œâ”€â”€ README.md
â””â”€â”€ sql/
    â”œâ”€â”€ 01-deduplication.sql
    â”œâ”€â”€ 02-anti-join.sql
    â”œâ”€â”€ 03-high-water-mark.sql
    â”œâ”€â”€ 04-changed-records.sql
    â”œâ”€â”€ 05-rolling-metrics.sql
    â”œâ”€â”€ 06-sessionisation.sql
    â”œâ”€â”€ 07-reconciliation.sql
    â””â”€â”€ sqlite-setup.sql
```

## Notes

The examples use ISO-8601 text timestamps (`YYYY-MM-DD HH:MM:SS`), which sort correctly in SQLite when consistently formatted. Production pipelines should also define their timezone, late-arrival policy, idempotency key, and tolerance rules explicitly.

