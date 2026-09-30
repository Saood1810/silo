# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

**Silo** is a private journaling app with a companion panel of motivational quotes. It is solo-built and backend-first. It is not therapy and not a social platform: it's a quiet space to write, with a small nudge of encouragement nearby. It is built for daily use by one person, with auth from day one so more users can be added later without a rewrite.

During early planning it was called "Lantern" / "Silent Isolation". The app name is now finalized as **Silo**, with package root `com.silo`. The repo folder may still be named "Silent Isolation"; that's only the directory name and isn't being renamed right now.

## Source of truth

- `docs/spec.md` is the source of truth for scope and decisions (§7 data model, §8 API, §10 build order, §11 open questions). Read it before making feature-level decisions. Any reference to `spec.md` (including in `.claude/agents/`) means this file.
- `docs/project-context.md` is a condensed summary of the same material.
- `docs/wireframes.html` is the low-fi wireframe: journal view, entry editor, collapsible quotes panel, mobile layout.
- `docs/db-schema.sql` is a draft of the initial migrations and still needs splitting into real files under `src/main/resources/db/migration`. Before relying on a table, check whether its migration actually exists.
- If code and the spec disagree, flag it. Don't silently pick one.
- When a decision changes, propose the exact `docs/spec.md` edit and wait for approval. Never edit the spec on your own initiative.

## Stack (confirmed, don't re-litigate without discussion)

- **Backend:** Java 21 + Spring Boot 4.1 (Spring Web, Spring Data JPA, Spring Security for JWT)
- **DB:** PostgreSQL, database name `silo`. Flyway-managed migrations; no JPA auto-DDL.
- **Auth:** JWT-based sessions. Single user for now, but the schema supports more.
- **Frontend:** React web application (not server-rendered, no near-term mobile target)

## Commands

Use the Maven wrapper (`./mvnw` on Unix, `mvnw.cmd` on Windows).

- Build: `./mvnw clean package`
- Run the app: `./mvnw spring-boot:run`
- Run all tests: `./mvnw test`
- Run a single test class: `./mvnw test -Dtest=<ClassName>`
- Run a single test method: `./mvnw test -Dtest=<ClassName>#<methodName>`
- Native image build (GraalVM required): `./mvnw -Pnative native:compile`

## Package structure (by layer)

The codebase is organized by technical layer, not by domain. (Some older notes say `com.silo.<domain>`; that's outdated. Follow the code.)

- `com.silo.controller`: REST controllers. Request/response DTOs go in `com.silo.controller.dto`.
- `com.silo.entity`: JPA entities (`User`, `Entry`, `Quote`, `FavoriteQuote`).
- `com.silo.repository`: Spring Data repositories.
- `com.silo.service`: business logic and validation.
- `com.silo.security`: JWT classes (`JwtService`, `JwtAuthFilter`) and security config (`SecurityConfig`, `SecurityBeansConfig`).
- `com.silo.config`: only for new non-security config beans. Don't move existing security config out of `security`.

Match the style already in the repo rather than introducing a new one. Examples: constructor injection via `@RequiredArgsConstructor`, and DTOs as records.

## Hard rules

1. **Thin controllers.** Controllers accept a DTO, call a service and return a response. Validation and business logic live in services; persistence lives in repositories.
2. **User id from the token only.** `user_id` always comes from the authenticated JWT principal. Never take it from a request body, path or query parameter.
3. **Scope all user-owned data.** Every read, update and delete of entries or favorites is scoped to the current user. One user must never be able to see or change another user's data.
4. **Flyway for every schema change.** Changes go in a **new** migration under `src/main/resources/db/migration`, named `V<n>__<description>.sql` (e.g. `V1__init.sql`, `V2__seed_quotes.sql`).
   - Never edit a migration that may already have been applied.
   - `spring.jpa.hibernate.ddl-auto` stays `validate`; never `update` or `create`.
5. **Validate request DTOs.** Use Jakarta Bean Validation (`@Valid` plus constraint annotations).
6. **Don't invent schema.** No invented columns, tables or relationships. The schema is whatever the migrations say.
7. **Smallest safe change.** Don't refactor, rename or "improve" code outside the task; mention it instead.
8. **Build order.** A new feature is built as migration, entity, repository, service, controller, test, in that order.

## Data model summary

```
users            id, email, password_hash, created_at
entries          id, user_id, title (nullable), body, mood (nullable), created_at, updated_at
quotes           id, text, author (nullable)
favorite_quotes  id, user_id, quote_id, created_at
```

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

All `/api/entries` and `/api/quotes` routes require a valid JWT.

## Evidence labels

When reasoning about behaviour, label each claim:

- **FACT**: confirmed from code, migrations, spec, test output or logs you actually read or ran.
- **ASSUMPTION**: inferred. Say what it was inferred from.
- **UNKNOWN**: needs verification or a decision.

Never present an assumption as a fact. Never fill an UNKNOWN by guessing.

## Open decisions (ask, don't decide)

- **Mood:** fixed set (low / okay / good / great) or free text? The spec leaves this open.
- **Quotes:** local seeded table only, or an external API later? (spec §11)
- **JWT storage on the frontend:** memory, localStorage or cookie? Not decided.
- **Test database:** H2 or Postgres (e.g. Testcontainers)? Check the existing test setup before assuming.

## React frontend: learning note

The developer is experienced with Java and Spring but is building the React frontend specifically to upskill, with limited prior React experience. **On frontend work, explain the core concepts as they come up** (components, props, state, hooks, routing, data-fetching patterns) instead of handing over finished code. The goal is understanding, not just a working app, so favour smaller, well-explained steps over large code dumps. On backend work, skip the basics.

## Build-time stack notes

- **Lombok** is wired as an annotation processor in `maven-compiler-plugin`. Use its annotations for entity/DTO boilerplate.
- **Hibernate bytecode enhancement** runs at build time via `hibernate-maven-plugin` (lazy loading, dirty tracking). Entities are enhanced during `package`, so behaviour may differ from a plain IDE run. Keep this in mind when debugging entity behaviour.
- **Bean validation** (`spring-boot-starter-validation`) is available.

## Conventions

- Indentation in Java files is 2 spaces.

## Agents (`.claude/agents/`)

| Agent | Use it to |
|---|---|
| `backend-builder` | Build one backend feature slice from a defined requirement |
| `bug-investigator` | Find the root cause of a specific failure and apply the smallest fix |
| `code-reviewer` | Review a change against the spec and these rules (read-only) |
| `react-coach` | Build frontend pieces while teaching the React concepts involved |
