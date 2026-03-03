import AppIntents
import Foundation

@available(iOS 17.0, *)
struct StartMorningCaptureIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Morning Capture"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(true, forKey: SharedKeys.shouldAutoStartCapture)
        return .result()
    }
}
