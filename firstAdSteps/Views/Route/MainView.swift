import SwiftUI

// Color+Theme extension'ını import et
@_exported import struct SwiftUI.Color

struct MainView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                     Image("logo-small")
                        .resizable()
                        .frame(width: 63, height: 37)
                    
                    MainPageHeaderSection()
                    MainPageTabSection()
                    
                }
                .padding(.vertical)
            }
        }
    }
}

#Preview {
    MainView()
} 
