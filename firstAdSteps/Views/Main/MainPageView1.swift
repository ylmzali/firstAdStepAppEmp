import SwiftUI

struct MainPageView1: View {
    @StateObject private var routeViewModel = RouteViewModel()
    @State private var selectedTab = 0
    @State private var animateStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        
                        // Header Section
                        VStack(spacing: 30) {
                            VStack(spacing: 20) {
                                // İstatistik Kartları
                                HStack(spacing: 12) {
                                    EnhancedStatCard1(
                                        title: "Aktif",
                                        value: "\(routeViewModel.routes.filter { $0.status == .active }.count)",
                                        icon: "figure.walk",
                                        color: .green,
                                        animate: animateStats
                                    )
                                    EnhancedStatCard1(
                                        title: "Tamamlanan",
                                        value: "\(routeViewModel.routes.filter { $0.status == .completed }.count)",
                                        icon: "checkmark.circle",
                                        color: .blue,
                                        animate: animateStats
                                    )
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(
                                Color.white.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                            
                            VStack(spacing: 20) {
                                HStack(spacing: 15) {
                                    EnhancedQuickAccessCard1(
                                        title: "Yeni Rota",
                                        subtitle: "Oluştur",
                                        icon: "plus.circle.fill",
                                        color: .blue
                                    )
                                    EnhancedQuickAccessCard1(
                                        title: "Aktif",
                                        subtitle: "\(routeViewModel.routes.filter { $0.status == .active }.count) rota",
                                        icon: "figure.walk",
                                        color: .green
                                    )
                                }
                                .padding(.horizontal)
                                HStack(spacing: 15) {
                                    EnhancedQuickAccessCard1(
                                        title: "Bugün",
                                        subtitle: "Planlanan",
                                        icon: "calendar",
                                        color: .orange
                                    )
                                    EnhancedQuickAccessCard1(
                                        title: "Yaklaşan",
                                        subtitle: "Takip et",
                                        icon: "clock",
                                        color: .purple
                                    )
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 45)
                        }
                        
                        // Harita Tab
                        // Rota Listesi
                        RouteListView()
                            .environmentObject(routeViewModel)
                        
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateStats = true
            }
        }
    }
}

// MARK: - Supporting Views
struct EnhancedStatCard1: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct EnhancedQuickAccessCard1: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120, height: 100)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}


#Preview {
    MainPageView1()
}
