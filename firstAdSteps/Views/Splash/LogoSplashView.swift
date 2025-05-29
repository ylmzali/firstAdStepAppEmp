import SwiftUI

// Color+Theme extension'ını import et
@_exported import struct SwiftUI.Color

struct LogoSplashView: View {
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                Image("logo-small")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 80)
            }
        }
    }
}

#Preview {
    LogoSplashView()
} 
