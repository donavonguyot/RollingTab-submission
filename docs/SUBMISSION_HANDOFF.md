# Submission handoff

This directory is a standalone five-score source snapshot for public judging. Its independent repository is https://github.com/donavonguyot/RollingTab-submission and contains no original development history. See [judge guide](JUDGE_GUIDE.md), [development instructions](DEVELOPMENT.md) and [verification](VERIFICATION.md).

- [x] Publish the cleaned snapshot in its own public repository; original history remains separate.
- [x] Public repository access requires no judge invitations.
- [ ] Verify hosted signup → save → reload → reopen and password recovery; retain a private fallback account. Do not commit credentials.
- [ ] Publish the actual application demo on YouTube/Vimeo, under two minutes, and supply its URL.
- [ ] Review the project description and AI-tool disclosure for the submission form; distinguish adapted components from new work and confirm eligibility.
- [ ] Submit and retain the receipt. Keep the live demo and judge access available throughout judging.

## Description draft

RollingTAB helps guitarists practice a short passage with audible playback, moving Perspective TAB, and a Now + next view of current and upcoming string positions. Guests can choose five hosted scores, seek, loop, and change speed without changing pitch. Users with verified email accounts can save a named passage and reopen it after reloading, with bounds, speed and loop restored. Flutter renders and synthesizes locally; Serverpod delivers the repertoire and authenticates users; PostgreSQL stores their passages; Serverpod Cloud hosts the demo.

## AI and reuse disclosure draft

AI coding assistance was used during implementation, testing and preparation. The entrant should confirm the exact tools and their roles before submission. Music Surface Lab models, decoder and practice-interface concepts, and RollingPod's audio-output approach were adapted as described in [attribution](../THIRD_PARTY.md). Independent backend, passage persistence, catalog delivery and practice integration were developed for RollingTAB. This description does not assert contest eligibility.

## Distribution contents

Share the source archive or this snapshot's new history only. All historical audit records, sibling source inventories, local secrets, databases, raw logs and deployment credentials remain outside this handoff. Required decoder code, schema compatibility identifiers and audio implementation remain included because the app needs them; attribution is intentionally retained.
