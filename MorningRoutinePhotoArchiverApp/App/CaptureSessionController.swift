import Foundation
import UIKit

@MainActor
final class CaptureSessionController: ObservableObject {
    @Published private(set) var state: CaptureSessionState = .idle

    let cameraController = CameraController()

    private let photoLibraryManager = PhotoLibraryManager()
    private let soundManager = SoundManager()
    private var isRunning = false

    func startSession() {
        guard !isRunning else { return }
        isRunning = true

        Task {
            await runSession()
            isRunning = false
        }
    }

    private func runSession() async {
        let cameraGranted = await cameraController.requestPermission()
        let photosGranted = await photoLibraryManager.requestAddOnlyPermission()

        guard cameraGranted, photosGranted else {
            state = .failed
            return
        }

        cameraController.startSession()
        await photoLibraryManager.ensureAlbumsExist()

        await runGetReady()

        for angle in CaptureAngle.allCases {
            await runPreAngleDelay(for: angle)
            await runCountdown(for: angle)
            await capture(angle: angle)
        }

        state = .completed
        openPhotosApp()
        cameraController.stopSession()
    }

    private func runGetReady() async {
        for second in stride(from: CaptureConstants.getReadySeconds, to: 0, by: -1) {
            state = .getReady(remaining: second)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    private func runPreAngleDelay(for angle: CaptureAngle) async {
        for second in stride(from: CaptureConstants.preAngleSeconds, to: 0, by: -1) {
            state = .preAngleDelay(angle: angle, remaining: second)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    private func runCountdown(for angle: CaptureAngle) async {
        for second in stride(from: CaptureConstants.countdownSeconds, to: 0, by: -1) {
            state = .countdown(angle: angle, remaining: second)
            soundManager.playCountdownBeep()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    private func capture(angle: CaptureAngle) async {
        state = .capturing(angle: angle)

        do {
            let data = try await cameraController.capturePhotoData()
            await photoLibraryManager.savePhoto(data, toAlbumNamed: angle.albumName)
            await soundManager.playCaptureConfirmation()
        } catch {
            return
        }
    }

    private func openPhotosApp() {
        guard let url = URL(string: "photos-redirect://") else { return }
        UIApplication.shared.open(url)
    }
}
