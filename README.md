# DBLiner

**dbliner** — Data Orchestration Framework for PostgreSQL and GreenPlum
DBLiner is a lightweight, fully automated system for managing data loading and data mart building processes, built entirely in PL/pgSQL. It does not implement extraction, transformation, or aggregation logic itself. Instead, it provides a robust wrapper for running, monitoring, and orchestrating user‑defined ETL tasks directly inside your database.

The project is designed for teams that want to centralise control over heterogeneous processes (loading from external sources via dblink, data cleansing, mart calculations) without relying on external schedulers or complex frameworks. All management stays within the DBMS, while developers only write business logic as stored functions — DBLiner handles the rest.

## Key Features
**Task Orchestration** — register arbitrary user‑defined functions (in PL/pgSQL or any PostgreSQL‑supported language) as tasks with dependencies, schedules, and priorities.

**Flexible Scheduling** — built‑in scheduler (using pg_cron or a custom daemon that calls dbliner.run_scheduler()) triggers tasks by time, by event (trigger), or upon completion of other tasks.

**Pipelines** — chain tasks together with automatic execution order control (e.g., load raw data → run cleansing → rebuild mart).

**Logging & Alerting** — every execution attempt is recorded in detail (start/finish time, status, row counts, error stack). On failure, the system can send notifications (email, Telegram).

**Retry & Error Handling** — configurable retry policies for transient errors (e.g., dblink disconnections).

**Admin Interface** — a set of views and functions to check task status, manually run/stop tasks, or modify schedules without touching the code.

## Architecture
All DBLiner components reside in a dedicated schema dbliner. Main objects:

**Task Registry (tasks)** — stores the user‑defined function name, its parameters, schedule (cron expression or trigger event), dependencies, and retry policy.

**Dispatcher (run_task())** — dynamically calls the target function, passes context parameters, and records the outcome in the log.

**Scheduler Engine (run_scheduler())** — scans tasks, identifies those ready to run (by time or dependencies), and queues them considering priorities and concurrency limits.

**Connection Manager (dblink_connections)** — stores named connections with credentials; provides get_connection(name) that returns a connection name for use in dblink_connect().

**Execution Log (*_log)** — full history of all runs, including error traces and metadata.

**System Views** — for monitoring active tasks, delays, errors, and performance.

Users create their own functions in any schema and register them with DBLiner via a simple API (dbliner.register_task()). New tasks are picked up automatically at the next scheduler cycle — no reload required.

## Advantages
**Separation of Concerns** — developers focus solely on business logic; DBLiner ensures reliable execution, retries, logging, and monitoring.

**Minimalism** — no need to learn complex DSLs or install external tools (Airflow, Jenkins, etc.). Just plain PL/pgSQL.

**Transparency**— all code is SQL‑based, easy to audit, modify, and unit‑test.

**Flexibility** — mix different task types: dblink loads, mart updates via materialised views, etc.

**Scalability** — works equally well on a single PostgreSQL instance and on a distributed GreenPlum cluster. In a cluster, the scheduler can run on the master, while tasks execute on segments (if functions are designed accordingly).

**Security** — role‑based permissions: users see only their own tasks, administrators see everything.

## Who Is DBLiner For
Data Warehouse Developers who want to quickly set up recurring loads without writing brittle bash scripts and crontab entries.

DBAs seeking to centralise background process management and simplify debugging.

Analysts who need transparent control over mart calculation sequences.

DevOps/SRE teams looking for a lightweight alternative to heavy‑weight orchestrators in microservice architectures.

## Requirements & Installation
PostgreSQL 9+ or GreenPlum 6+ (with PL/pgSQL and dblink support).

pg_cron extension is recommended for built‑in scheduling (if unavailable, you can run dbliner.run_scheduler() from an external cron).

Installation: execute install.sql, which creates the dbliner schema, all tables, functions, and initial seed data (e.g., test tasks).

To register your own task, simply call SELECT dbliner.register_task(...) with the function name, schedule, and dependencies.

## License & Ecosystem
The project is released under the MIT License — free for commercial use. Source code is open on GitHub, and contributions are welcome. Future plans include a web monitoring interface (via a separate REST service) and integrations with alerting systems (Slack, Opsgenie).

**In summary**: DBLiner is the "skeleton" for your ETL processes. It handles the orchestration routine, while you remain in full control of the business logic. Simple, reliable, and green.