import SwiftUI

struct NotificationAlert: Identifiable {
    let id = UUID()
    let type: AlertType
    let title: String
    let message: String
    let date: String
    enum AlertType {
        case reservationApproved, reservationRejected, performanceWarning, routeWarning, proofMissing
    }
}

struct NotificationsAlertsView: View {
    // Örnek bildirimler ve uyarılar
    var alerts: [NotificationAlert] = [
        NotificationAlert(type: .reservationApproved, title: "Rezervasyon Onaylandı", message: "Meydan Billboard için rezervasyonunuz onaylandı.", date: "12.06.2024"),
        NotificationAlert(type: .reservationRejected, title: "Rezervasyon Reddedildi", message: "Metro Girişi için rezervasyonunuz uygun bulunmadı.", date: "11.06.2024"),
        NotificationAlert(type: .performanceWarning, title: "Performans Hedefi Uyarısı", message: "Sahil Yolu reklamı için gösterim hedefinin altındasınız.", date: "10.06.2024"),
        NotificationAlert(type: .routeWarning, title: "Rota Dışı Uyarısı", message: "Aktif reklamınız belirlenen rotadan çıktı.", date: "09.06.2024"),
        NotificationAlert(type: .proofMissing, title: "İspat Eksik", message: "Metro Girişi reklamı için rota ispatı eksik.", date: "08.06.2024"),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(spacing: 10) {
                        ForEach(alerts) { alert in
                            NotificationAlertCard(alert: alert)
                                .padding(.horizontal)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Bildirimler & Uyarılar")

        }
    }
}

struct NotificationAlertCard: View {
    let alert: NotificationAlert
    var icon: (String, Color) {
        switch alert.type {
        case .reservationApproved:
            return ("checkmark.circle.fill", .green)
        case .reservationRejected:
            return ("xmark.octagon.fill", .red)
        case .performanceWarning:
            return ("exclamationmark.triangle.fill", .orange)
        case .routeWarning:
            return ("location.slash.fill", .purple)
        case .proofMissing:
            return ("questionmark.circle.fill", .yellow)
        }
    }
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon.0)
                .foregroundColor(icon.1)
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.headline)
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(alert.date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: icon.1.opacity(0.08), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    NotificationsAlertsView()
} 
