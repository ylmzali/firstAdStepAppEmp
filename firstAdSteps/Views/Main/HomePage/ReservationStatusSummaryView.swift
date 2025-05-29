import SwiftUI

struct ReservationStatusSummaryView: View {
    // Örnek veri
    var activeCount: Int = 2
    var upcomingCount: Int = 1
    var completedCount: Int = 5
    var onAddReservation: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rezervasyon Durumu")
                .font(.headline)
                .padding(.leading)
            HStack(spacing: 16) {
                ReservationStatusCard(title: "Aktif", count: activeCount, color: .blue, icon: "play.fill")
                ReservationStatusCard(title: "Yaklaşan", count: upcomingCount, color: .orange, icon: "clock.fill")
                ReservationStatusCard(title: "Tamamlanan", count: completedCount, color: .green, icon: "checkmark.circle.fill")
            }
            .padding(.horizontal)
            Button(action: {
                onAddReservation?()
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
            .padding(.horizontal)
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