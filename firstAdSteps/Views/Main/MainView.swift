import SwiftUI

struct MainView: View {
    @StateObject private var routeViewModel = RouteViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                     Image("logo-small")
                        .resizable()
                        .frame(width: 63, height: 37)
                    
                    MainPageHeaderSection()
                    
                    RouteListView()
                        .environmentObject(routeViewModel)
                    
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
