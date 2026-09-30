-- V1__init.sql
-- Flyway migration for the diary + quotes app

CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE entries (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title         VARCHAR(255),
    body          TEXT NOT NULL,
    mood          VARCHAR(50),
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_entries_user_id_created_at ON entries(user_id, created_at DESC);

CREATE TABLE quotes (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text          TEXT NOT NULL,
    author        VARCHAR(255)
);

CREATE TABLE favorite_quotes (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quote_id      UUID NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE (user_id, quote_id)
);

-- V2__seed_quotes.sql
-- A small starter set — replace/expand freely

INSERT INTO quotes (text, author) VALUES
    ('The wound is the place where the light enters you.', 'Rumi'),
    ('You are not required to set yourself on fire to keep others warm.', NULL),
    ('Almost everything will work again if you unplug it for a few minutes, including you.', 'Anne Lamott'),
    ('What lies behind us and what lies before us are tiny matters compared to what lies within us.', 'Ralph Waldo Emerson'),
    ('You don''t have to control your thoughts. You just have to stop letting them control you.', 'Dan Millman'),
    ('The only way out is through.', 'Robert Frost'),
    ('Be patient with yourself. Self-growth is tender; it''s holy ground.', 'Stephen Covey');
