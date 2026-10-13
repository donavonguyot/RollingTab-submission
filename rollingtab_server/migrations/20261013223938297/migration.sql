BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "rollingtab_auth_email_attempt" (
    "id" bigserial PRIMARY KEY,
    "emailHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "auth_email_attempt_time" ON "rollingtab_auth_email_attempt" USING btree ("createdAt");


--
-- MIGRATION VERSION FOR rollingtab
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('rollingtab', '20261013223938297', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261013223938297', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
