import AppIntents

@available(iOS 17.0, *)
struct MorningRoutineShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartMorningCaptureIntent(),
            phrases: [
                "Start morning capture in \(.applicationName)",
                "Run morning routine with \(.applicationName)"
            ],
            shortTitle: "Start Morning Capture",
            systemImageName: "camera"
        )
    }
}
