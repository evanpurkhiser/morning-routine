import AudioToolbox
import Foundation

final class SoundManager {
    private let beepSoundId: SystemSoundID = 1104

    func playCountdownBeep() {
        AudioServicesPlaySystemSound(beepSoundId)
    }

    func playCaptureConfirmation() async {
        AudioServicesPlaySystemSound(beepSoundId)
        try? await Task.sleep(nanoseconds: 150_000_000)
        AudioServicesPlaySystemSound(beepSoundId)
    }
}
