# RollingTAB demo video: script and recording walkthrough

**Target: 1:50, including the final card.** Record the actual hosted Chrome app at https://rollingtab.serverpod.space/play/. The story is one complete practice session: choose music, hear and understand it, slow and loop a passage, then save and reopen it.

This is a recording plan, not evidence that the final video has been recorded or published. The existing hosted acceptance is documented in [Verification](VERIFICATION.md).

## Timed script

Read the quoted narration naturally. Leave the specified audio pause. Timings are editing targets; shorten transitions rather than accelerate the app footage. The proposed six-second loop needs one rehearsal before recording.

| Time | Screen action | Narration |
| --- | --- | --- |
| 0:00–0:10 | Open on the app with a prepared Vals passage playing. Small title: **RollingTAB · Guitar passage practice**. | “A difficult guitar passage takes repetition. RollingTAB lets you hear it, see the string positions, and practice at your own pace.” |
| 0:10–0:22 | Cut to the paused app. Open **Choose server repertoire**, show the five scores, select **Vals — Ferdinando Carulli**. Open **Choose passage**; enter Start **0**, End **6**; press **Use passage**. | “Start as a guest. Choose from five hosted scores, then select the passage you want to work on.” |
| 0:22–0:34 | Press **Play** at 100%. Keep Perspective TAB and Now + next readable. Give the guitar audio four seconds without speech. | “Perspective TAB moves with the music. Now and next shows the current and upcoming positions.” **[Pause narration for four seconds of app audio.]** |
| 0:34–0:49 | Set **Speed** to **73%**. With loop enabled, let playback cross 6.0 seconds and visibly return to the start. Keep the wrap continuous and unobscured. | “Slow it down without changing pitch, and loop the same passage. Here, string and fret positions are inferred guidance.” |
| 0:49–1:04 | Pause. Select **Save passage**. Briefly show the sign-in dialog with **Create account** and **Forgot password**. Cut past private sign-in, captioned **After signing in**. Name the passage **Vals · slow practice**, then **Save**. | “Guest practice needs no account. Email signup and password recovery are available. I'll sign in to save this passage for next time.” |
| 1:04–1:21 | Show an actual browser reload, then **My passages → Vals · slow practice**. Show Vals restored, 73%, and loop enabled. Open **Choose passage** briefly to reveal **0–6** bounds; cancel. | “After a reload, I open My passages. Vals returns paused, with the same bounds, speed, and loop setting. My practice setup is ready.” |
| 1:21–1:42 | Hold the restored app. Add the architecture overlay below, then return to unobstructed playback. No terminal or dashboard tour is needed. | “Serverpod powers the catalog, authentication, and each user's saved passages in PostgreSQL. Flutter uses a generated Dart client and handles the visuals and audio locally. Resend delivers verification emails. The live app runs on Serverpod Cloud.” |
| 1:42–1:50 | Final card with the live URL, repository, and credits pointer. Let quiet app audio continue underneath. | “RollingTAB: choose a passage, practice it, and pick up where you left off. Try the live demo.” |

### Architecture overlay

Use three readable boxes over a dimmed still of the app. Keep this on screen long enough to read; animate nothing beyond a simple fade.

```text
Flutter app                 Serverpod                    PostgreSQL
Playback + visuals  <---->  Catalog + authentication  <-> Personal passages
Generated Dart client       Passage save / load
                            |
                            +--> Resend: verification / recovery email

Hosted on Serverpod Cloud
```

Audio synthesis happens in the client. Serverpod supplies catalog metadata and score assets, handles authentication, and enforces ownership of saved passages. Resend delivers the email; Serverpod manages the authentication flow. Saved passages contain practice settings, not recorded performances.

Implementation references for fact checking: [catalog](../rollingtab_server/lib/src/catalog.dart), [passage endpoints](../rollingtab_server/lib/src/passages.dart), [email authentication](../rollingtab_server/lib/src/auth/email_idp_endpoint.dart), and [email delivery](../rollingtab_server/lib/src/auth/auth_email.dart). Do not spend the limited runtime reading code on screen.

## Prepare the recording

1. Use desktop Chrome with a clean window and notifications disabled. Aim for 1920 × 1080 footage. Keep the score, Now + next panel, and playback controls visible together; adjust the recording region or browser zoom during rehearsal if needed.
2. Open the live app directly. Choose Vals, press Play once, and let **Initializing audio** finish. First use downloads the approximately 31 MB SoundFont. Confirm the recording captures browser/system audio, not just the microphone.
3. Rehearse **Choose passage → Start 0 → End 6 → Use passage**. This six-score-second passage takes about **8.2 wall-clock seconds at 73%**. Confirm it sounds suitable and visibly wraps; keep the same bounds throughout every clip. Do not wait for the full default 32.73-second passage to repeat.
4. Have a verified demo account ready before recording. Begin the guest sequence signed out. Record the empty sign-in dialog, stop capture for credential entry, then resume on the save dialog. Avoid recording addresses, passwords, verification codes, inboxes, account menus, or infrastructure secrets. Do not request fresh email codes for each take.
5. Use a unique passage name if **Vals · slow practice** already exists. The same name must appear in the save and restore shots. A fresh reload may initially show the default study: explicitly open **My passages** and select the saved Vals entry.
6. Capture narration separately if helpful. Keep app audio quiet under speech and clearly audible during the four-second demonstration. Use the app's synthesized Vals playback; no added background recording is needed.

## Capture and editing checklist

- [ ] Opening shot shows a functioning, audible app; the title does not hide the practice surface.
- [ ] Five-score picker and Vals selection are readable. Retain the **Inferred guidance** label; do not describe it as source TAB or finger tracking.
- [ ] Bounds are 0–6; speed changes from 100% to 73%; at least one loop wraps in an uninterrupted clip.
- [ ] **Create account** and **Forgot password** are visible briefly. Full signup and recovery are covered by the judge guide, not performed inside this short video.
- [ ] Save completes. Reload is real. Reopening the named passage visibly restores 73%, loop enabled, and the same bounds, paused.
- [ ] The architecture overlay matches the running implementation. Do not imply that Serverpod synthesizes audio or that the app listens to a guitarist.
- [ ] Cuts past sign-in or loading are apparent. If a network request is slow or fails, wait and re-record; do not replace a result with a fabricated success screen. Keep the persistence proof in one take where possible; label a loading cut if one is necessary.
- [ ] Final runtime, including all fades and credits, is **less than 2:00**; aim for **1:50**. Check the exported file, not just the timeline estimate.
- [ ] Watch the export once with sound and once muted. Captions and visible actions should make the core flow understandable in both cases.

The video focuses on working behavior and useful Serverpod integration. The [official event](https://builderbase.com/event/build-something-real-the-serverpod-hackathon) links the [official rules](https://sbnxiexidrjwubdfjepb.supabase.co/storage/v1/object/public/uploads/super_event/03771d49-7932-4408-a663-c1db1db88a15/6368bd87-82c9-4759-9b27-6970747b49c3.pdf). Section 5 calls for a demo under two minutes, publicly visible on YouTube or Vimeo; section 6 weights working behavior at 30%, Serverpod use at 25%, craft at 25%, and usefulness at 20%. Checked October 13, 2026.

## Final card

```text
RollingTAB
Choose a passage. Practice it. Return to it.

Try it: rollingtab.serverpod.space/play/
Source: github.com/donavonguyot/RollingTab-submission
Links, component credits, and score attribution in the description.
```

## Upload copy draft

**Title:** RollingTAB — Guitar Passage Practice with Serverpod

**Description:**

RollingTAB helps guitarists practice a short passage with audible playback, moving Perspective TAB, and a Now + next view of string positions. Choose a score, slow playback without changing pitch, loop a passage, and save its settings for your next session.

Flutter handles rendering and local audio synthesis. Serverpod supplies the catalog and score assets, authenticates accounts, and stores personal passage settings in PostgreSQL. Resend delivers signup and recovery emails. The demo is hosted on Serverpod Cloud.

- Live app: https://rollingtab.serverpod.space/play/
- Source and build instructions: https://github.com/donavonguyot/RollingTab-submission
- Judge walkthrough: https://github.com/donavonguyot/RollingTab-submission/blob/codex/submission/docs/JUDGE_GUIDE.md
- Component attribution and licenses: https://github.com/donavonguyot/RollingTab-submission/blob/codex/submission/THIRD_PARTY.md
- Score credits: https://github.com/donavonguyot/RollingTab-submission/blob/codex/submission/rollingtab_server/assets/scores/SOURCE_CREDITS.md

Music shown: Vals by Ferdinando Carulli, synthesized by the app using GeneralUser GS 1.471 by S. Christian Collins. Score sourced through PDMX v9 (https://doi.org/10.5281/zenodo.15571083); dataset attribution under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/), with the individual score's CC0 declaration retained in the repository. The demo selects an excerpt and changes playback speed. String/fret guidance for this score is inferred.

AI coding assistance was used in implementation, testing, and preparation. Adapted components and their origins are credited in the repository.

**Before upload:** confirm the exact AI tools and roles for the submission disclosure, review the final description against the actual footage, and retain the attribution links. Publishing the video and submitting its URL remain separate outstanding steps in [Submission handoff](SUBMISSION_HANDOFF.md).
