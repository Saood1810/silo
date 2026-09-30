# Claude Project Context — Silo (diary + quotes app)

Paste this into the Project's custom instructions / knowledge, alongside `spec.md` and `db-schema.sql`, so any conversation in the project starts with the same shared understanding.

> Formerly "Lantern" / "Silent Isolation" — app name is now finalized as **Silo**. Package root is `com.silo`.

## What this project is

A personal journaling app with a side panel of motivational quotes. Solo-built, backend-first. Full detail in `spec.md` — treat that file as the source of truth for scope and decisions; update it when a decision changes rather than letting context drift across chats.

## Stack decisions (don't re-litigate these without discussion)

- Java + Spring Boot backend (Web, Data JPA, Security) — **confirmed: web application, no native mobile target for now**
- PostgreSQL, Flyway-managed migrations
- JWT auth, single user for now but schema supports more
- **Frontend: React (web) — confirmed, not server-rendered.** User is learning React through this project, so explanations of *why* something is structured a certain way are welcome alongside the code, not just the code itself.

## How to work in this project

- When asked to scaffold code, follow the package structure: `com.silo.<domain>` (e.g. `com.silo.entries`, `com.silo.quotes`, `com.silo.auth`)
- Keep controllers thin — validation and business logic in services, persistence in repositories
- Every new table needs a Flyway migration file, not a JPA auto-DDL change
- Favor small, testable slices: a new feature = migration + entity + repository + service + controller + test, reviewed in that order
- On the React side, favor explaining core concepts as they come up (components, props, state, effects, routing) rather than assuming familiarity — user is new to the framework

## Known open questions (see spec.md §11)

- Local-only quotes vs. external API later

## Files in this project

- `spec.md` — product + technical spec
- `db-schema.sql` — Flyway migration (schema + seed data)
- `wireframes.html` — clickable low-fi wireframe of the journal view, entry editor, and quotes panel
