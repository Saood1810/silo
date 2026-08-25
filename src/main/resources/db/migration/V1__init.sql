


CREATE TABLE users (
                       id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       email         VARCHAR(255) NOT NULL UNIQUE,
                       password_hash VARCHAR(255) NOT NULL,
                       created_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE entries (
                         id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                         title      VARCHAR(255),
                         body       TEXT NOT NULL,
                         mood       VARCHAR(50),
                         created_at TIMESTAMP NOT NULL DEFAULT now(),
                         updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_entries_user_id ON entries(user_id);

CREATE TABLE quotes (
                        id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                        text   TEXT NOT NULL,
                        author VARCHAR(255)
);

CREATE TABLE favorite_quotes (
                                 id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                 user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                                 quote_id   UUID NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
                                 created_at TIMESTAMP NOT NULL DEFAULT now(),
                                 UNIQUE (user_id, quote_id)
);