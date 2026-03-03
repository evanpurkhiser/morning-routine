import SwiftUI

struct OverlayGuideView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = min(proxy.size.width * 0.62, 280)
            let bodyHeight = width * 2.0

            ZStack {
                RoundedRectangle(cornerRadius: width * 0.28)
                    .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    .frame(width: width, height: bodyHeight)

                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    .frame(width: width * 0.38, height: width * 0.38)
                    .offset(y: -(bodyHeight * 0.64))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
