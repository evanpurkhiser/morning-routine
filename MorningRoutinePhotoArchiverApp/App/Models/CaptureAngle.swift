import Foundation

enum CaptureAngle: String, CaseIterable, Identifiable {
    case front
    case right
    case back
    case left
    case face

    var id: String { rawValue }

    var label: String {
        switch self {
        case .front:
            return "Front"
        case .right:
            return "Right"
        case .back:
            return "Back"
        case .left:
            return "Left"
        case .face:
            return "Face"
        }
    }

    var albumName: String {
        "Morning Routine - \(label)"
    }
}
