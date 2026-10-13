# Attribution and source provenance

RollingTAB is a private application. No open-source license is granted to the project as a whole. Existing third-party licenses continue to apply to their respective components.

- **Music Surface Lab:** the initial guitar surface, voicing panel/models, authored studies, diagnostics and transport concepts were adapted from the author's earlier local lab. New movement-study content and the independent application integration were authored for RollingTAB.
- **PDMX decoder:** `lib/vendor/pdmx_document.dart` derives from the lab's decoder snapshot. Decoder implementation and wire-format identifiers are retained for compatibility; internal process comments are omitted. It is not a runtime dependency on another application.
- **RollingPod:** the internal `rollingtab_audio` package adapts the author's existing SoundFont/PCM output approach. Scheduling, cancellation and guitar techniques were adapted independently. No sibling source imports or services are required.
- **GeneralUser GS 1.471:** S. Christian Collins, copyright 1997–2015. The SoundFont is preserved byte-for-byte; see [its license](assets/licenses/GeneralUser-GS-LICENSE.txt). Runtime synthesis and the homepage demonstration use it.
- **Bravura:** retain the [included license](assets/licenses/Bravura-LICENSE.txt).
- **Scores:** see [score credits](rollingtab_server/assets/scores/SOURCE_CREDITS.md) and companion provenance files for dataset attribution, individual score declarations, transformations and hashes. Inferred guitar guidance is distinguished from source TAB.
- **Dependencies:** Flutter Scene 0.24.0 provides rendering, dart_melty_soundfont 2.0.0 synthesis, flutter_pcm_sound 3.3.3 native PCM output, Web Audio browser output, Serverpod 4.0.3 backend/authentication, and Jaspr 0.23.5 the static homepage. Package lockfiles preserve resolved versions and package distributions supply their licenses.
- **Homepage media:** the video and poster are actual captures of an authored chord study with scheduled synthesized PCM. [Media provenance](provenance/homepage-media.json) records settings and hashes; it is not a physical speaker-loopback recording.

This submission snapshot intentionally excludes the original repository history, sibling-project inventories, internal machine paths, historical integration patches and raw review logs. Original development provenance remains with the author. The included adaptation credits are not a claim that all components were created during the contest.
