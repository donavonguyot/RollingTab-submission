# RollingTAB server

Serverpod 4.0.3 backend for the five-score submission. See the root README and development guide for builds and startup. Its embedded PostgreSQL database, migrations, catalog and saved passages are independent.

`catalog.list/getArtifact` provide public verified score metadata. `passages.list/save/delete` enforce authenticated ownership. Invited email/password login and JWT refresh are available; public registration and password reset are not. A temporary local bootstrap secret can provision accounts; it is removed after use.

The server serves the prebuilt static homepage at `/`, Flutter at `/play/`, the allowlisted same-origin POST bridge at `/api/`, and immutable score bytes at digest-addressed paths. Source snapshots and provenance are not served by the score route. Browser and native audio are synthesized by the client. Production secrets and deployment controls are not part of this submission.
