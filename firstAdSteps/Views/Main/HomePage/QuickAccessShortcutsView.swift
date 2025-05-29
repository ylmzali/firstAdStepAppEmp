import SwiftUI

struct QuickAccessShortcutsView: View {
    // Örnek sık kullanılan reklam alanları
    var favoriteAdSpaces: [String] = [
        "Meydan Billboard",
        "Metro Girişi",
        "Sahil Yolu"
    ]
    var onNewReservation: (() -> Void)? = nil
    var onDownloadReport: (() -> Void)? = nil
    var onSupport: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Hızlı Erişim & Kısayollar")
                .font(.headline)
                .padding(.leading)
            HStack(spacing: 16) {
                ShortcutButton(title: "Yeni Rezervasyon", icon: "plus.circle.fill", color: .blue, action: onNewReservation)
                ShortcutButton(title: "Rapor İndir", icon: "arrow.down.doc.fill", color: .green, action: onDownloadReport)
                ShortcutButton(title: "Destek", icon: "questionmark.circle.fill", color: .orange, action: onSupport)
            }
            .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("Sık Kullanılan Reklam Alanları")
                    .font(.subheadline)
                    .padding(.leading, 4)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(favoriteAdSpaces, id: \.self) { name in
                            FavoriteAdSpaceChip(name: name)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

struct ShortcutButton: View {
    let title: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 90)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: color.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
}

struct FavoriteAdSpaceChip: View {
    let name: String
    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Color.blue.opacity(0.10))
            .foregroundColor(.blue)
            .cornerRadius(16)
    }
}

#Preview {
    QuickAccessShortcutsView()
} 