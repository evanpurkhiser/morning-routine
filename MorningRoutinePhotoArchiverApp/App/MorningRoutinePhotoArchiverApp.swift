import SwiftUI

@main
struct MorningRoutinePhotoArchiverApp: App {
    @AppStorage(SharedKeys.shouldAutoStartCapture) private var shouldAutoStartCapture = false

    var body: some Scene {
        WindowGroup {
            CaptureView()
                .onOpenURL { url in
                    guard url.scheme == "morningroutine", url.host == "startCapture" else { return }
                    shouldAutoStartCapture = true
                }
        }
    }
}
