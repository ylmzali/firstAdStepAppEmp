import SwiftUI

struct OrderStatusLast5DaysCard: View {
    @State private var showTracking = false

    var onCourier: (() -> Void)?
    var body: some View {
        HStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text("Siparişinin son 5 günü")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 8, topTrailing: 8))
                    .fill(Color.orange))
                .frame(width: .infinity)

                VStack(alignment: .leading) {
                    Text("4 lego paketi, 1 hediye kartı")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.9))
                    Button(action: {
                        showTracking = true
                    }) {
                        Text("KURYE AYARLA")
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
    OrderStatusLast5DaysCard()
}
