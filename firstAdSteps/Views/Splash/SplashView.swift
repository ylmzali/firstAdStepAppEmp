import SwiftUI

// Color+Theme extension'ını import et
@_exported import struct SwiftUI.Color

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            AppFlowView()
        } else {
            ZStack {
                Color.blue.ignoresSafeArea()
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 180, height: 180)
                            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                        VStack {
                            Image(systemName: "megaphone.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.blue)
                            Text("AdSteps")
                                .font(.title2).bold()
                                .foregroundColor(.primary)
                        }
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 
