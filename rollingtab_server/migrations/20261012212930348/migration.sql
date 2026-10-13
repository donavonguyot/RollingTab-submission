BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "rollingtab_catalog" ADD COLUMN "recommendedStart" double precision;
ALTER TABLE "rollingtab_catalog" ADD COLUMN "recommendedEnd" double precision;
ALTER TABLE "rollingtab_catalog" ADD COLUMN "practiceFocus" text;
ALTER TABLE "rollingtab_catalog" ADD COLUMN "guidanceDescription" text;

--
-- MIGRATION VERSION FOR rollingtab
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('rollingtab', '20261012212930348', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261012212930348', "timestamp" = now();

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
