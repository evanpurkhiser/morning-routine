# Morning Routine Photo Archiver (iOS) — Design Document (Prototype v1)

## 0) Summary
A single-user iOS app that runs a fully automated, zero-touch photo capture sequence each morning when launched via an iOS Shortcut (triggered by an NFC tag). The app captures 5 photos (Front → Right → Back → Left → Face), with a static framing guide and simple beeps for feedback, then saves each photo to its corresponding Photos album (5 albums total). After completion, the app opens Photos to the relevant album context.

Prototype goal: produce a reliable end-to-end capture + archive workflow with minimal UI and no ML/detection.

---

## 1) Goals
- Launch directly into an automated capture session from Shortcuts (App Intent / URL scheme).
- Capture 5 photos in a deterministic timed sequence.
- Provide basic user guidance via on-screen text and beeps.
- Save each photo into a dedicated Photos album (Front/Right/Back/Left/Face).
- Open Photos at the end for immediate confirmation.

## 2) Non-Goals (v1)
- No in-app photo viewer, timeline, comparisons, or timelapse.
- No body detection, pose detection, "in position" checks, underwear detection.
- No auto-alignment/cropping/normalization.
- No blur detection or retakes (planned later).
- No haptics, no voice prompts.
- No multi-device support; only targeted at one iPhone model / portrait mount usage.

---

## 3) User Story
Each morning:
1. User places iPhone on a MagSafe wall mount in portrait orientation.
2. User taps NFC tag; iOS Shortcut launches the app's "Start Morning Capture" action.
3. App shows a brief "Get ready" screen, then automatically runs the 5-shot sequence.
4. App saves photos into Photos albums.
5. App opens Photos at the end (for quick verification).

---

## 4) Launch & Automation Integration

### 4.1 Shortcut entry point
Provide an App Intent (preferred) so Shortcuts can run:
- Action name: **Start Morning Capture**
- Behavior: launches app and immediately starts the capture session.

Alternative fallback: URL scheme deep link, e.g.:
- `morningroutine://startCapture`

For prototype, implement whichever is quickest; App Intent is ideal.

### 4.2 NFC automation
Not implemented in-app. The user configures an iOS Shortcut automation:
- When NFC tag is scanned → Run "Start Morning Capture".

---

## 5) Capture Sequence Spec

### 5.1 Angles (fixed)
1. Front
2. Right (rotate clockwise)
3. Back (rotate clockwise)
4. Left (rotate clockwise)
5. Face (step closer to camera)

### 5.2 Timing (fixed constants)
- **Get Ready screen:** 2.0 seconds
- **Rotation/positioning delay:** 4.0 seconds **before every angle**, including the first
- **Countdown:** 3.0 seconds
- Total per angle: 4s delay + 3s countdown + capture

### 5.3 Audio (beeps only)
- Countdown: 1 short beep each second during countdown (3 beeps).
- Capture confirmation: 2 quick beeps immediately after photo is captured successfully.
- No voice, no haptics.

Note: No guarantee to override silent mode. Accept current system behavior for prototype.

### 5.4 UI during capture
- Full-screen camera preview.
- Static overlay framing guide (non-interactive).
- Angle label text (e.g., "Front").
- Status text for rotation delay (e.g., "Get in position") then countdown numbers "3…2…1".

### 5.5 Failure handling (silent)
- If camera permission or Photos permission is missing/denied, the session stops. No error UI required in v1.
- If saving fails for any reason, continue best-effort; do not block or prompt.

---

## 6) Photos Storage Model

### 6.1 Albums to create/use
Maintain exactly **5 albums**:
- `Morning Routine - Front`
- `Morning Routine - Right`
- `Morning Routine - Back`
- `Morning Routine - Left`
- `Morning Routine - Face`

(Album naming is not critical; choose consistent names.)

No "All Sessions" album.

Optional (nice-to-have): create a Photos **folder** named `Morning Routine` and place the 5 albums inside it. If folder creation is annoying in prototype, skip it.

### 6.2 What to save
- Save only the original captured image (no processed copies).
- Each photo is added to exactly one corresponding album.

### 6.3 End behavior
After successful completion, open Photos app.
Preferred: open Photos to the **Face** album (most recent) or simply open Photos if deep-linking to a specific album is too hard.

---

## 7) Permissions
Required:
- Camera: `NSCameraUsageDescription`
- Photos Add Only: `NSPhotoLibraryAddUsageDescription` (and use add-only APIs where possible)

v1 policy:
- Request permissions on first run if needed.
- If denied, session ends silently.

---

## 8) Architecture & Implementation Notes (Prototype)

### 8.1 Technologies
- Swift + SwiftUI (UI) and AVFoundation (camera capture).
- PhotoKit for album creation and saving (`PHPhotoLibrary`, `PHAssetCollection`).
- App Intents for Shortcuts integration (`AppIntents` framework).

### 8.2 Key components

#### CaptureSessionController
Responsibilities:
- Owns the session state machine.
- Drives angle transitions, timers, beeps, and capture requests.
- Emits state to SwiftUI for labels/countdown display.

State machine:
- `idle`
- `getReady(remaining)`
- `preAngleDelay(angle, remaining)`
- `countdown(angle, remaining)`
- `capturing(angle)`
- `completed`
- `failed` (silent)

#### CameraController (AVFoundation)
Responsibilities:
- Configure camera in portrait.
- Provide preview layer / SwiftUI preview view.
- Capture still image on demand (high quality).

Notes:
- Use back camera by default unless front camera is explicitly desired (not requested).
- Lock orientation to portrait within the app.

#### PhotoLibraryManager (PhotoKit)
Responsibilities:
- Ensure 5 albums exist (create if missing).
- Save captured photo to library and add it to the correct album.

Album lookup strategy:
- Find by title; if not found, create.

#### SoundManager
Responsibilities:
- Play simple beep sounds for countdown and capture confirm.
- Use system sounds or bundled short wav file. Keep minimal.

### 8.3 Concurrency
- Use Swift concurrency (`async/await`) where convenient.
- PhotoKit writes and camera capture callbacks must not block UI thread.

### 8.4 Data & settings (minimal)
Hardcode constants for prototype:
- `GET_READY_SECONDS = 2`
- `PRE_ANGLE_SECONDS = 4`
- `COUNTDOWN_SECONDS = 3`
- Angle list fixed.

Optionally expose these as debug constants at top of file for quick tuning.

---

## 9) UX Details (Screens)

### 9.1 Get Ready screen (2s)
- Shows: live preview + overlay + "Get ready".
- No controls.

### 9.2 Capture screen
- Angle label at top.
- Center text:
  - During pre-angle: "Rotate / position" and a small countdown of the 4 seconds (optional).
  - During countdown: large "3", "2", "1".
- Overlay guide visible throughout.

### 9.3 Completion screen (optional, 1s)
- "Done" (optional).
- Then open Photos.

Prototype may skip this and open Photos immediately after final save.

---

## 10) Static Overlay Guide (v1)
- A transparent "human outline" graphic (SVG/PNG) centered in the preview.
- No logic attached; purely visual framing guidance.
- Should scale reasonably across common iPhone sizes; can be tuned later.

Implementation:
- SwiftUI overlay view positioned using relative geometry.
- Maintain safe margins to avoid notch areas.

---

## 11) Testing Checklist (Prototype)
- First-run with no permissions:
  - Camera prompt appears; after granting, sequence runs.
  - Photos add prompt appears; after granting, photos save.
- Albums created correctly and reused on subsequent runs.
- Sequence timing matches 4s pre-angle + 3s countdown.
- Beeps occur: 3 during countdown, 2 after capture.
- All 5 photos appear in correct albums.
- App opens Photos at end.

---

## 12) Future Phases (not in v1)
Phase 2:
- Blur detection (simple sharpness heuristic) and auto-retake once.
- Basic "stillness" gating using motion sensors.

Phase 3:
- Pose detection post-capture to align/crop consistently.
- Save processed versions (optional).

Phase 4:
- Clothing/underwear detection or safer reminder-based approach.

---

## 13) Deliverables for Prototype
- Xcode project with:
  - App Intent: "Start Morning Capture"
  - Full-screen capture UI
  - AVFoundation still capture
  - PhotoKit album creation + save
  - Beep feedback
  - Open Photos after completion
