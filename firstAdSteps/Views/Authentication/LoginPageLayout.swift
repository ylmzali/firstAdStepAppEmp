import SwiftUI

struct LoginPageLayout<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Arka plan
            Color.white
                .ignoresSafeArea()
            
            // İçerik
            VStack(spacing: 24) {
                // Logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 40)
                
                // Form içeriği
                content
                    .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginPageLayout {
        VStack(spacing: 16) {
            Text("Örnek İçerik")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.gray600)
            
            Text("Bu bir örnek içeriktir.")
                .font(.subheadline)
                .foregroundColor(Theme.gray400)
        }
    }
} 
