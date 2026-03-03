import Foundation

enum CaptureSessionState: Equatable {
    case idle
    case getReady(remaining: Int)
    case preAngleDelay(angle: CaptureAngle, remaining: Int)
    case countdown(angle: CaptureAngle, remaining: Int)
    case capturing(angle: CaptureAngle)
    case completed
    case failed
}
