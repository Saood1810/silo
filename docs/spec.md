# Project Spec — "Silo"

A private journaling app with a companion panel of motivational quotes — built for people processing things solo, who want a quiet space to write and a small nudge of encouragement nearby.

> Name finalized: **Silo** (formerly "Lantern" / "Silent Isolation"). Package root: `com.silo`.

---

## 1. Problem & Motivation

Living alone means a lot of processing happens internally, with no one to immediately talk it through with. This app isn't therapy or a social app — it's a private outlet: write it down, and have a small companion presence (a quote, a bit of perspective) sitting right next to it, not a full-blown "wellness platform."

## 2. Target User (v1)

- Just you, to start. Built to be genuinely used daily, not a portfolio showcase.
- Single user initially, but built with auth from day one so it can support more users later without a rewrite.

## 3. Core Value Prop

Write freely, privately, and glance at something encouraging without leaving the page.

## 4. MVP Feature List

**Diary**
- Create / edit / delete entries (title optional, body required, timestamp auto-set)
- Optional mood tag per entry (small fixed set: e.g. low / okay / good / great — or free text, your call)
- List view of entries, newest first, searchable by keyword and filterable by date
- Entry detail/edit view

**Quotes side panel**
- Panel visible alongside the diary (collapsible)
- Shows one quote at a time, with a "next quote" action
- Quotes sourced from a seeded local table to start (no external dependency, no rate limits, works offline) — can layer in an external API later
- Optional: user can "favorite" a quote

**Auth**
- Simple email + password login, JWT-based sessions
- Single user for now, but the schema/API don't assume that

## 5. Stretch Features (post-MVP)

- Mood trend chart over time
- "On this day" — resurface entries from a year/month ago
- Tagging entries by theme (e.g. work, health, relationships)
- Daily write reminder (email or push, later)
- Ability to mark an entry private/locked behind a re-auth prompt
- Export entries (PDF/Markdown)

## 6. Tech Stack

- **Backend:** Java, Spring Boot (Spring Web, Spring Data JPA, Spring Security for JWT)
- **DB:** PostgreSQL, database name `silo` (H2 fine for local dev/prototyping)
- **Migrations:** Flyway
- **Frontend:** React (web application — confirmed, no server-rendered alternative). No near-term mobile target, but UI logic stays reasonably decoupled from web-only APIs so a future port isn't painful, without over-engineering v1.
- **Quotes data:** local `quotes` table, seeded via a Flyway migration; revisit external API (e.g. Quotable) only if you want variety beyond what you seed

## 7. Data Model

```
users
  id            UUID PK
  email         VARCHAR UNIQUE NOT NULL
  password_hash VARCHAR NOT NULL
  created_at    TIMESTAMP

entries
  id            UUID PK
  user_id       UUID FK -> users.id
  title         VARCHAR NULL
  body          TEXT NOT NULL
  mood          VARCHAR NULL
  created_at    TIMESTAMP
  updated_at    TIMESTAMP

quotes
  id            UUID PK
  text          TEXT NOT NULL
  author        VARCHAR NULL

favorite_quotes
  id            UUID PK
  user_id       UUID FK -> users.id
  quote_id      UUID FK -> quotes.id
  created_at    TIMESTAMP
```

See `db-schema.sql` for the runnable version.

## 8. API Design (v1)

```
POST   /api/auth/register
POST   /api/auth/login

GET    /api/entries              # list, supports ?q=&from=&to=
POST   /api/entries
GET    /api/entries/{id}
PUT    /api/entries/{id}
DELETE /api/entries/{id}

GET    /api/quotes/random
GET    /api/quotes/favorites
POST   /api/quotes/{id}/favorite
DELETE /api/quotes/{id}/favorite
```

All `/api/entries` and `/api/quotes` routes require a valid JWT; the `user_id` is derived from the token, never passed by the client.

## 9. Screens (see wireframes.html)

1. **Journal view** — left: list of entries (searchable). Center: selected entry / editor. Right: collapsible quotes panel.
2. **New entry** — same layout, center pane in edit mode.
3. **Quotes panel** — one quote, "next" button, favorite toggle.

## 10. Suggested Build Order

1. Spring Boot project scaffold + Flyway migration for `users`, `entries`, `quotes`
2. Auth (register/login, JWT filter)
3. Entries CRUD + tests
4. Quotes seed data + `GET /api/quotes/random`
5. Wire up a minimal frontend (even just fetch calls against Postman-verified endpoints first)
6. Polish: search/filter, favorites, mood tag

## 11. Open Questions

- Local quotes only, or want to pull from a public API for variety from day one?

## 12. Learning Note

User is building the React frontend as a way to upskill and doesn't have much prior React experience. When helping with frontend work in this project, favor explaining core concepts (components, props, state, hooks, routing, data fetching patterns) as they come up rather than just delivering finished code — the goal is understanding, not just a working app.
