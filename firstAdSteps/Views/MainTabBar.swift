import SwiftUI

struct TabBarIcon: View {
    let image: String
    let selectedImage: String
    let isSelected: Bool
    
    var body: some View {
        Image(isSelected ? selectedImage : image)
            .renderingMode(.template)
            .foregroundColor(isSelected ? .black : .gray)
    }
}

struct TabBarText: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        Text(text)
            .font(.custom("Roboto", size: 12))
            .foregroundColor(isSelected ? .black : .gray)
    }
}

struct MainTabBar: View {
    @State private var selectedTab = 0
    @StateObject private var cartManager = CartManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MainPageView()
                    .tabItem {
                        TabBarIcon(image: "Home", selectedImage: "HomeHover", isSelected: selectedTab == 0)
                        TabBarText(text: "Anasayfa", isSelected: selectedTab == 0)
                    }
                    .tag(0)
                
                SearchPage()
                    .tabItem {
                        TabBarIcon(image: "Search", selectedImage: "SearchHover", isSelected: selectedTab == 1)
                        TabBarText(text: "Ara", isSelected: selectedTab == 1)
                    }
                    .tag(1)
                
                CartView()
                    .tabItem {
                        TabBarIcon(image: "Buy", selectedImage: "BuyHover", isSelected: selectedTab == 2)
                        TabBarText(text: "Sepetim", isSelected: selectedTab == 2)
                    }
                    .tag(2)
                
                UserProfileView()
                    .tabItem {
                        TabBarIcon(image: "Profile", selectedImage: "ProfileHover", isSelected: selectedTab == 3)
                        TabBarText(text: "Profil", isSelected: selectedTab == 3)
                    }
                    .tag(3)
            }
            .tint(.black)
            
            
            if cartManager.itemCount > 0 {
                GeometryReader { geometry in
                    Text("\(cartManager.itemCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .position(x: geometry.size.width * 0.68, y: 10)
                }
                .frame(height: 50)
            }
        }
        .statusBar(hidden: true)
    }
}

#Preview {
    MainTabBar()
        .environmentObject(RouteViewModel())
        .environmentObject(UserProfileViewViewModel())
} 
