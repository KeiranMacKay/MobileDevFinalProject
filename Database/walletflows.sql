
-- CSCI Mobile Dev - Part 2 (SQLite)  |  Naveenan V.
-- App: WalletFlow (working name)
-- File: student_walletflow.sql
-- Notes:
--   This is a small, local database for the prototype. I kept it simple on purpose:
--   - cents stored as INTEGER to avoid float rounding
--   - a few basic constraints + FKs
--   - enough seed rows to make the UI screens in the mockups show data

PRAGMA foreign_keys = ON;

-----------------------------
-- Accounts & People
-----------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    display_name  TEXT NOT NULL,
    created_at    TEXT DEFAULT (datetime('now'))
);

-- People under the account we can split with (Person A, Person B, etc.)
CREATE TABLE IF NOT EXISTS members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id   INTEGER NOT NULL,
    nickname  TEXT NOT NULL,
    -- basic color tag for charts (optional)
    color_hex TEXT,
    UNIQUE(user_id, nickname),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-----------------------------
-- Categories & Budgets
-----------------------------
CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL,
    name        TEXT NOT NULL,
    icon_name   TEXT,
    UNIQUE(user_id, name),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- One budget row per (user, month, year). I only stored income for now.
CREATE TABLE IF NOT EXISTS budgets (
    budget_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id      INTEGER NOT NULL,
    month        INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    year         INTEGER NOT NULL,
    income_cents INTEGER DEFAULT 0 CHECK (income_cents >= 0),
    UNIQUE(user_id, month, year),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Planned money per category per month (used for “breakdown” screen)
CREATE TABLE IF NOT EXISTS budget_allocations (
    allocation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    budget_id     INTEGER NOT NULL,
    category_id   INTEGER NOT NULL,
    planned_cents INTEGER NOT NULL CHECK (planned_cents >= 0),
    UNIQUE(budget_id, category_id),
    FOREIGN KEY (budget_id) REFERENCES budgets(budget_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-----------------------------
-- Expenses & Attachments
-----------------------------
CREATE TABLE IF NOT EXISTS expenses (
    expense_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id      INTEGER NOT NULL,
    category_id  INTEGER,
    description  TEXT NOT NULL,              -- e.g., "McDonalds"
    amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
    expense_date TEXT NOT NULL,              -- YYYY-MM-DD
    notes        TEXT,
    created_at   TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Who pays what for each expense (helps compute Person A / B totals)
CREATE TABLE IF NOT EXISTS expense_splits (
    split_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    expense_id  INTEGER NOT NULL,
    member_id   INTEGER NOT NULL,
    share_cents INTEGER NOT NULL CHECK (share_cents >= 0),
    UNIQUE(expense_id, member_id),
    FOREIGN KEY (expense_id) REFERENCES expenses(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- simple spot for receipt image/uri
CREATE TABLE IF NOT EXISTS receipts (
    receipt_id INTEGER PRIMARY KEY AUTOINCREMENT,
    expense_id INTEGER NOT NULL,
    uri        TEXT NOT NULL,
    mime_type  TEXT,
    FOREIGN KEY (expense_id) REFERENCES expenses(expense_id) ON DELETE CASCADE
);

-----------------------------
-- Recurring Bills
-----------------------------
CREATE TABLE IF NOT EXISTS recurring_bills (
    bill_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id        INTEGER NOT NULL,
    name           TEXT NOT NULL,
    default_amount_cents INTEGER,
    category_id    INTEGER,
    notes          TEXT,
    start_date     TEXT NOT NULL,                       -- first due date
    interval_type  TEXT NOT NULL CHECK (interval_type IN ('WEEKLY','MONTHLY','YEARLY')),
    interval_count INTEGER NOT NULL DEFAULT 1 CHECK (interval_count >= 1),
    is_active      INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-----------------------------
-- Indexes I actually use in queries
-----------------------------
CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON expenses(user_id, expense_date);
CREATE INDEX IF NOT EXISTS idx_splits_member ON expense_splits(member_id);

-----------------------------
-- Seed Data (to make the screenshots believable)
-----------------------------
INSERT INTO users (email, password_hash, display_name)
VALUES ('guest@example.com', 'demo-hash', 'Guest User');

-- Two people to match the wireframes
INSERT INTO members (user_id, nickname, color_hex) VALUES
(1, 'Person A', '#3b82f6'),
(1, 'Person B', '#f97316');

-- Basic categories used in examples
INSERT INTO categories (user_id, name, icon_name) VALUES
(1, 'Food & Drink', 'utensils'),
(1, 'Utilities', 'bolt'),
(1, 'Transport', 'car');

-- Jan 2025 budget with simple allocations
INSERT INTO budgets (user_id, month, year, income_cents)
VALUES (1, 1, 2025, 450000);

INSERT INTO budget_allocations (budget_id, category_id, planned_cents) VALUES
(1, 1, 60000),  -- Food & Drink $600
(1, 2, 20000),  -- Utilities $200
(1, 3, 15000);  -- Transport $150

-- Example expenses shown in the mockups
INSERT INTO expenses (user_id, category_id, description, amount_cents, expense_date, notes) VALUES
(1, 1, 'Starbucks', 1456, '2025-01-02', NULL),
(1, 1, 'Five Guys Burgers and Fries', 2656, '2025-02-03', NULL),
(1, 1, 'McDonalds', 4513, '2025-03-04', 'Inflations getting bad out here');

-- Split those between A/B so we can compute per-person totals
INSERT INTO expense_splits (expense_id, member_id, share_cents) VALUES
(1, 1, 800),  (1, 2, 656),
(2, 1, 1600), (2, 2, 1056),
(3, 1, 2260), (3, 2, 2253);

-- One receipt attached to McDonalds (for the “photo add”)
INSERT INTO receipts (expense_id, uri, mime_type) VALUES
(3, 'content://receipts/mcd_2025_03_04.jpg', 'image/jpeg');

-- A sample recurring bill (e.g., phone)
INSERT INTO recurring_bills (user_id, name, default_amount_cents, category_id, notes, start_date, interval_type)
VALUES (1, 'Phone Bill', 8000, 2, 'Rogers plan', '2025-01-15', 'MONTHLY');
