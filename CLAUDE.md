# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

**Silo** is a private journaling app with a companion panel of motivational quotes — solo-built, backend-first. Not therapy, not a social platform: a quiet space to write, with a small nudge of encouragement nearby.

Formerly called "Lantern" / "Silent Isolation" during early planning — the app name is now finalized as **Silo**, package root `com.silo`. The local folder/repo may still be named "Silent Isolation" — that's just the directory name and isn't being renamed right now.

The full product spec lives in `docs/spec.md` — treat that as the source of truth for scope and decisions; read it before making feature-level decisions. `docs/project-context.md` has the same summary in a more condensed form (originally written to be pasted into a Claude Project's custom instructions). `docs/wireframes.html` is a clickable low-fi wireframe of the journal view, entry editor, and quotes panel.

## Stack (confirmed — don't re-litigate without discussion)

- **Backend:** Java 21 + Spring Boot 4.1 (Spring Web, Spring Data JPA, Spring Security for JWT)
- **DB:** PostgreSQL, database name `silo`. Flyway-managed migrations — no JPA auto-DDL.
- **Auth:** JWT-based sessions, single user for now but schema supports more
- **Frontend:** React (web application, confirmed — not server-rendered, no near-term mobile target)

## Commands

Use the Maven wrapper (`./mvnw` on Unix, `mvnw.cmd` on Windows).

- Build: `./mvnw clean package`
- Run the app: `./mvnw spring-boot:run`
- Run all tests: `./mvnw test`
- Run a single test class: `./mvnw test -Dtest=<ClassName>`
- Run a single test method: `./mvnw test -Dtest=<ClassName>#<methodName>`
- Native image build (GraalVM required): `./mvnw -Pnative native:compile`

## Package structure

Follow `com.silo.<domain>`:
- `com.silo.entries`
- `com.silo.quotes`
- `com.silo.auth`
- `com.silo.config` — security config, etc.

## How to work in this codebase

- Keep controllers thin — validation and business logic in services, persistence in repositories
- Every new table needs a Flyway migration file (`src/main/resources/db/migration`, named `V1__init.sql`, `V2__seed_quotes.sql`, etc.) — never rely on Hibernate auto-DDL to create/alter schema
- `spring.jpa.hibernate.ddl-auto` should stay `validate`, not `update` or `create`
- Favor small, testable slices: a new feature = migration + entity + repository + service + controller + test, reviewed in that order

## Data model summary

```
users            id, email, password_hash, created_at
entries          id, user_id, title (nullable), body, mood (nullable), created_at, updated_at
quotes           id, text, author (nullable)
favorite_quotes  id, user_id, quote_id, created_at
```

Full schema in `docs/db-schema.sql` — a draft of the `V1__init.sql` + `V2__seed_quotes.sql` Flyway migrations. It still needs to be split into actual migration files under `src/main/resources/db/migration` when the schema is implemented.

## API summary

```
POST   /api/auth/register
POST   /api/auth/login

GET    /api/entries              # ?q=&from=&to=
POST   /api/entries
GET    /api/entries/{id}
PUT    /api/entries/{id}
DELETE /api/entries/{id}

GET    /api/quotes/random
GET    /api/quotes/favorites
POST   /api/quotes/{id}/favorite
DELETE /api/quotes/{id}/favorite
```

All `/api/entries` and `/api/quotes` routes require a valid JWT; `user_id` is always derived from the token, never passed by the client.

## React frontend — learning note

The user is building the React frontend specifically to upskill and has limited prior React experience. **When working on frontend code, explain the core concepts as they come up** (components, props, state, hooks, routing, data fetching patterns) rather than just handing over finished code. The goal is understanding, not just a working app — favor smaller, well-explained steps over large code dumps.

## Screens

See `docs/wireframes.html` for the low-fi wireframe: journal view (entry list, editor, collapsible quotes panel), new-entry mode, and a mobile layout for a possible future port.

## Build-time stack notes

- **Lombok** is wired as an annotation processor in `maven-compiler-plugin` — use its annotations for entity/DTO boilerplate.
- **Hibernate bytecode enhancement** runs at build time via `hibernate-maven-plugin` (lazy loading, dirty tracking) — entities are enhanced during `package`, so behavior may differ from a plain IDE run.
- **Bean validation** (`spring-boot-starter-validation`) is available — validate request DTOs with Jakarta `@Valid` / constraint annotations.

## Conventions

- Indentation in existing Java files is 2 spaces.