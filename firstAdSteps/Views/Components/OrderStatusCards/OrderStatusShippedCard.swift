import SwiftUI

struct OrderStatusShippedCards: View {
    var onTrack: (() -> Void)?
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Siparişin yola çıktı.")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.green)
            VStack(alignment: .leading, spacing: 8) {
                Text("4 lego paketi, 1 hediye kartı")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Button(action: { onTrack?() }) {
                    Text("SİPARİŞİ TAKİP ET")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandPurple", bundle: nil) ?? .purple)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .padding(4)
    }
}


struct OrderStatusShippedCard: View {
    @State private var showTracking = false

    var onCourier: (() -> Void)?
    var body: some View {
        HStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text("Siparişin yola çıktı")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 8, topTrailing: 8))
                    .fill(Color.green))
                .frame(width: .infinity)

                VStack(alignment: .leading) {
                    Text("4 lego paketi, 1 hediye kartı")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.9))
                    Button(action: {
                        showTracking = true
                    }) {
                        Text("SİPARİŞİ TAKİP ET")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                }
                .padding()
                
                

                
            }
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue400.opacity(0.2), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 6)
            .padding()

        }
        .frame(width: .infinity)
        .onTapGesture {
            showTracking = true
        }
        .sheet(isPresented: $showTracking) {
            OrderTrackingPage()
        }

    }
}

#Preview {
    OrderStatusShippedCard()
}
