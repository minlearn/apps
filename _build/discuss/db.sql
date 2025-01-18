-- CreateTables

-- federation tables
CREATE TABLE IF NOT EXISTS "account" (
    "name" TEXT NOT NULL PRIMARY KEY,
    "privkey" TEXT,
    "pubkey" TEXT,
    "webfinger" TEXT,
    "actor" TEXT,
    "apikey" TEXT,
    "followers" TEXT,
    "messages" TEXT
);

CREATE TABLE IF NOT EXISTS "messages" (
    "guid" TEXT NOT NULL PRIMARY KEY,
    "message" TEXT
);


-- default tables
CREATE TABLE IF NOT EXISTS "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL UNIQUE,
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NULL,
    "gravatar" TEXT,
    "signature" TEXT,
    "roletags" TEXT
);


CREATE TABLE IF NOT EXISTS "posts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT,
    "body" TEXT NOT NULL,
    "userId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NULL,
    "istop" INTEGER,
    "isro" INTEGER,
    "viewtimes" INTEGER,
    "cattags" TEXT
);

CREATE TABLE IF NOT EXISTS "comments" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "body" TEXT NOT NULL,
    "postId" TEXT,
    "userId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NULL
);


CREATE TABLE IF NOT EXISTS "notifies" (
    "touserid" TEXT NOT NULL,
    "isreaded" INTEGER NOT NULL,
    "commenthappeningid" TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS "regcodes" (
    "body" TEXT NOT NULL,
    "isredeemed" INTEGER NOT NULL,
    "redeemedto" TEXT
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");