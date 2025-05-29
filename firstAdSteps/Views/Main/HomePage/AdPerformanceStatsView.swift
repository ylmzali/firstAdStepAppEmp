import SwiftUI

struct AdPerformanceStat: Identifiable {
    let id = UUID()
    let adSpaceName: String
    let impressions: Int
    let reach: Int
    let clicks: Int
    let duration: Int // dakika
}

struct AdPerformanceStatsView: View {
    @State private var selectedPeriod: String = "Günlük"
    let periods = ["Günlük", "Haftalık", "Aylık"]
    // Örnek veri
    var stats: [AdPerformanceStat] = [
        AdPerformanceStat(adSpaceName: "Meydan Billboard", impressions: 1200, reach: 900, clicks: 80, duration: 180),
        AdPerformanceStat(adSpaceName: "Metro Girişi", impressions: 2200, reach: 1700, clicks: 120, duration: 240),
        AdPerformanceStat(adSpaceName: "Sahil Yolu", impressions: 800, reach: 600, clicks: 40, duration: 90),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text("Performans İstatistikleri")
                    .font(.headline)

                Picker("Zaman", selection: $selectedPeriod) {
                    ForEach(periods, id: \.self) { period in
                        Text(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: .infinity)
            }
            .padding(.horizontal)
            // Toplam özetler
            HStack(spacing: 16) {
                StatSummaryCard(title: "Gösterim", value: stats.map { $0.impressions }.reduce(0, +), color: .blue)
                StatSummaryCard(title: "Erişim", value: stats.map { $0.reach }.reduce(0, +), color: .green)
                StatSummaryCard(title: "Tıklama", value: stats.map { $0.clicks }.reduce(0, +), color: .orange)
            }
            .padding(.horizontal)
            // Her reklam alanı için performans kartı
            VStack(spacing: 12) {
                ForEach(stats) { stat in
                    AdPerformanceCard(stat: stat)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

struct StatSummaryCard: View {
    let title: String
    let value: Int
    let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.title2).bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct AdPerformanceCard: View {
    let stat: AdPerformanceStat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stat.adSpaceName)
                .font(.headline)
            HStack(spacing: 16) {
                StatBar(title: "Gösterim", value: stat.impressions, maxValue: 3000, color: .blue)
                StatBar(title: "Erişim", value: stat.reach, maxValue: 3000, color: .green)
                StatBar(title: "Tıklama", value: stat.clicks, maxValue: 500, color: .orange)
            }
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.gray)
                Text("Süre: \(stat.duration) dk")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct StatBar: View {
    let title: String
    let value: Int
    let maxValue: Int
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(width: 60, height: 7)
                    .foregroundColor(color.opacity(0.15))
                Capsule()
                    .frame(width: CGFloat(min(Double(value) / Double(maxValue), 1.0)) * 60, height: 7)
                    .foregroundColor(color)
            }
            Text("\(value)")
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    AdPerformanceStatsView()
} 
