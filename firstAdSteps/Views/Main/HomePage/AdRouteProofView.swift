import SwiftUI
import MapKit

struct RouteProof: Identifiable {
    let id = UUID()
    let adSpaceName: String
    let routeSummary: String
    let date: String
    let isVerified: Bool
}

struct AdRouteProofView: View {
    // Örnek rota geçmişi
    var routeHistory: [RouteProof] = [
        RouteProof(adSpaceName: "Meydan Billboard", routeSummary: "Kadıköy Meydanı - Moda Sahili", date: "12.06.2024", isVerified: true),
        RouteProof(adSpaceName: "Metro Girişi", routeSummary: "Taksim Meydanı - Şişhane", date: "11.06.2024", isVerified: false),
    ]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rota ve İspat")
                .font(.headline)
                .padding(.leading)
            // Harita Placeholder
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $region)
                    .frame(height: 180)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                Button(action: {
                    // Canlı konum takibi başlat
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                        Text("Canlı Takip")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .padding(8)
                }
            }
            // Rota geçmişi ve doğrulama
            Text("Rota Geçmişi ve Doğrulama")
                .font(.subheadline)
                .padding(.leading)
            VStack(spacing: 10) {
                ForEach(routeHistory) { proof in
                    RouteProofItem(proof: proof)
                        .padding(.horizontal)
                }
            }
            // Rapor indirme/paylaşma
            HStack {
                Spacer()
                Button(action: {
                    // Rapor indir
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Rapor İndir")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.12))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
                Button(action: {
                    // Rapor paylaş
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Paylaş")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                Spacer()
            }
        }
        .padding(.vertical)
    }
}

struct RouteProofItem: View {
    let proof: RouteProof
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: proof.isVerified ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(proof.isVerified ? .green : .orange)
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(proof.adSpaceName)
                    .font(.headline)
                Text(proof.routeSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(proof.date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            if proof.isVerified {
                Text("Doğrulandı")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(8)
            } else {
                Text("Eksik")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    AdRouteProofView()
} 