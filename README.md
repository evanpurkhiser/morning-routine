# Morning Routine Photo Archiver (Prototype v1)

Scaffold for a SwiftUI + AVFoundation + PhotoKit iOS app that runs an automated 5-angle morning capture workflow.

## What is included

- SwiftUI full-screen capture UI with static framing overlay
- Session state machine for get-ready, pre-angle delay, countdown, capture, complete
- AVFoundation still image capture service
- PhotoKit album creation and per-angle saving
- Basic beep feedback manager
- App Intent (`Start Morning Capture`) + URL scheme (`morningroutine://startCapture`)
- `XcodeGen` spec (`project.yml`) to generate `.xcodeproj` on macOS

## Generate and run on macOS

1. Install Xcode and Xcode command line tools.
2. Install XcodeGen (`brew install xcodegen`).
3. From repository root run:

```bash
xcodegen generate
open MorningRoutinePhotoArchiver.xcodeproj
```

4. Select an iPhone target, build, and run.

## Notes

- This scaffold targets prototype behavior and leaves UI polish/error UX intentionally minimal.
- Permissions are requested at runtime. If denied, the session ends silently (per v1 spec).
- App Intent integration requires testing on-device with Shortcuts automation.
