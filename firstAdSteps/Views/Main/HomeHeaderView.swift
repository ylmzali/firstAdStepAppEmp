import SwiftUI

struct HomeHeaderView: View {
    @State private var selectedDay: Int = 3 // Haftanın günü (0: Pzt, 6: Paz)
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let dates = [15, 16, 17, 18, 19, 20, 21]
    
    // Örnek değerler
    let totalKcal = 2000.0
    let remainingKcal = 1247.0
    let carbs = 122.0
    let protein = 44.0
    let fat = 20.0
    
    var body: some View {
        VStack(spacing: 16) {
            // Başlık ve ikon
            HStack {
                Spacer()
                Text("Daily Meal Plan")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
            }
            
            // Tarih seçici
            HStack(spacing: 12) {
                ForEach(0..<days.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        Text(days[i])
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(dates[i])")
                            .font(.subheadline)
                            .fontWeight(selectedDay == i ? .bold : .regular)
                            .foregroundColor(selectedDay == i ? .white : .primary)
                            .frame(width: 32, height: 32)
                            .background(selectedDay == i ? Color.blue : Color.clear)
                            .clipShape(Circle())
                    }
                    .onTapGesture { selectedDay = i }
                }
            }
            
            // Yarım daire progress ve süreç analizi
            HStack(alignment: .center, spacing: 24) {
                // Yarım daire progress
                SemiCircleProgressBar(progress: remainingKcal / totalKcal)
                    .frame(width: 130, height: 120)
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(Int(remainingKcal))")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("KCALS LEFT")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .offset(y: 10)
                    )
                
                // Süreç analizi
                VStack(alignment: .leading, spacing: 10) {
                    MacroBarView(title: "CARBS", value: carbs, maxValue: 150, color: .orange)
                    MacroBarView(title: "PROTEIN", value: protein, maxValue: 60, color: .pink)
                    MacroBarView(title: "FAT", value: fat, maxValue: 30, color: .green)
                }
                .frame(width: 100)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

struct SemiCircleProgressBar: View {
    var progress: Double // 0.0 - 1.0
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                .rotationEffect(.degrees(180))
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0) * 0.5)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(180))
        }
    }
}

struct MacroBarView: View {
    let title: String
    let value: Double
    let maxValue: Double
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(value))g")
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 6)
                    .foregroundColor(color.opacity(0.15))
                Capsule()
                    .frame(width: CGFloat(value / maxValue) * 80, height: 6)
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    HomeHeaderView()
} 
