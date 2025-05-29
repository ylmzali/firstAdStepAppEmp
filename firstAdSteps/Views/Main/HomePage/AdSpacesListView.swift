import SwiftUI

struct AdSpace: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let isAvailable: Bool
    let summary: String
}

struct AdSpacesListView: View {
    // Örnek veri
    var adSpaces: [AdSpace] = [
        AdSpace(name: "Meydan Billboard", location: "Kadıköy, İstanbul", isAvailable: true, summary: "Yüksek yaya trafiği, merkezi konum."),
        AdSpace(name: "Metro Girişi", location: "Taksim, İstanbul", isAvailable: false, summary: "Günde 20.000+ kişi, yoğun saatlerde çok görünür."),
        AdSpace(name: "Sahil Yolu", location: "Bakırköy, İstanbul", isAvailable: true, summary: "Araç ve yaya trafiği yüksek, deniz manzaralı."),
    ]
    var onQuickReserve: ((AdSpace) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reklam Alanları")
                .font(.headline)
                .padding(.leading)
            ForEach(adSpaces) { adSpace in
                AdSpaceListItem(adSpace: adSpace, onQuickReserve: onQuickReserve)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct AdSpaceListItem: View {
    let adSpace: AdSpace
    var onQuickReserve: ((AdSpace) -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(adSpace.name)
                    .font(.headline)
                Spacer()
                Text(adSpace.isAvailable ? "Müsait" : "Dolu")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(adSpace.isAvailable ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(adSpace.isAvailable ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                    .cornerRadius(8)
            }
            Text(adSpace.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(adSpace.summary)
                .font(.caption)
                .foregroundColor(.gray)
            HStack {
                Spacer()
                Button(action: {
                    onQuickReserve?(adSpace)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: adSpace.isAvailable ? "plus.circle.fill" : "eye.fill")
                        Text(adSpace.isAvailable ? "Hızlı Rezervasyon" : "Detay/Kontrol")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(adSpace.isAvailable ? Color.blue.opacity(0.12) : Color.gray.opacity(0.12))
                    .foregroundColor(adSpace.isAvailable ? .blue : .gray)
                    .cornerRadius(10)
                }
                .disabled(!adSpace.isAvailable)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AdSpacesListView()
} 