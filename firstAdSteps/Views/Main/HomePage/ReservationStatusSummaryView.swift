import SwiftUI

struct ReservationStatusSummaryView: View {
    // Örnek veri
    var activeCount: Int = 2
    var upcomingCount: Int = 1
    var completedCount: Int = 5
    
    @State private var showAddRoute: Bool = false
    @State private var showRouteList: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16)
        {

            
            
            Text("Rezervasyon Durumu")
                .font(.headline)
                .padding(.leading)
            HStack(spacing: 16) {
                ReservationStatusCard(title: "Aktif", count: activeCount, color: .blue, icon: "play.fill")
                ReservationStatusCard(title: "Yaklaşan", count: upcomingCount, color: .orange, icon: "clock.fill")
                ReservationStatusCard(title: "Tamamlanan", count: completedCount, color: .green, icon: "checkmark.circle.fill")
            }
            .padding(.horizontal)
            
            NavigationLink(destination: AddRouteView(), isActive: $showAddRoute) {
                EmptyView()
            }

            VStack(alignment: .leading, spacing: 8)
            {
                
                Button(action: {
                    showAddRoute = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Yeni Rezervasyon Ekle")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                /*
                .fullScreenCover(isPresented: $showAddRoute) {
                    AddRouteView()
                }
                 */
                .padding(.horizontal)
                
                
                
                
                NavigationLink(destination: RouteListView(), isActive: $showRouteList) {
                    EmptyView()
                }
                
                Button(action: {
                    showRouteList = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.rectangle.stack.fill")
                        Text("Rezervasyonlarım")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(1))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct ReservationStatusCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.12))
                .clipShape(Circle())
            Text("\(count)")
                .font(.title2).bold()
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: color.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    ReservationStatusSummaryView()
}
