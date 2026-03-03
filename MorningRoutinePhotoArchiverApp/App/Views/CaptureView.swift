import SwiftUI

struct CaptureView: View {
    @StateObject private var controller = CaptureSessionController()
    @AppStorage(SharedKeys.shouldAutoStartCapture) private var shouldAutoStartCapture = false

    var body: some View {
        ZStack {
            CameraPreviewView(session: controller.cameraController.session)
                .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            OverlayGuideView()

            VStack(spacing: 20) {
                Text(currentAngleText)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 44)

                Spacer()

                Text(primaryStatusText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if let secondaryStatusText {
                    Text(secondaryStatusText)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                if controller.state == .idle {
                    Button("Start Morning Capture") {
                        controller.startSession()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                    .padding(.bottom, 38)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            controller.cameraController.startSession()
        }
        .onDisappear {
            controller.cameraController.stopSession()
        }
        .task {
            if shouldAutoStartCapture {
                shouldAutoStartCapture = false
                controller.startSession()
            }
        }
    }

    private var currentAngleText: String {
        switch controller.state {
        case .preAngleDelay(let angle, _), .countdown(let angle, _), .capturing(let angle):
            return angle.label
        case .completed:
            return "Done"
        case .failed:
            return ""
        default:
            return "Morning Routine"
        }
    }

    private var primaryStatusText: String {
        switch controller.state {
        case .idle:
            return "Ready"
        case .getReady:
            return "Get Ready"
        case .preAngleDelay:
            return "Get In Position"
        case .countdown(_, let remaining):
            return "\(remaining)"
        case .capturing:
            return "Capture"
        case .completed:
            return "Done"
        case .failed:
            return ""
        }
    }

    private var secondaryStatusText: String? {
        switch controller.state {
        case .getReady(let remaining):
            return "Starting in \(remaining)s"
        case .preAngleDelay(_, let remaining):
            return "\(remaining)s"
        case .countdown:
            return nil
        case .capturing:
            return "Hold still"
        case .completed:
            return "Opening Photos"
        default:
            return nil
        }
    }
}
