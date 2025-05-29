import SwiftUI

struct GiftCardListView: View {
    @StateObject private var cartManager = CartManager.shared
    let giftCards: [GiftCard] = sampleGiftCards // Use sample data

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hediye Kartları")
                    .font(.largeTitle).bold()
                    .padding([.top, .horizontal])
                    .padding(.bottom, 10)

                ForEach(giftCards) { giftCard in
                    GiftCardRow(giftCard: giftCard, cartManager: cartManager)
                }
            }
            .padding(.bottom) // Add some padding at the bottom of the ScrollView content
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // A slightly off-white background
        .navigationTitle("Hediye Kartları")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GiftCardRow: View {
    let giftCard: GiftCard
    @ObservedObject var cartManager: CartManager
    @State private var showAddedToCartMessage = false

    // Check if this specific gift card is already in the cart
    private var isInCart: Bool {
        cartManager.giftCardItems.contains { $0.id == giftCard.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Gift Card Image Area (Placeholder)
            ZStack {
                giftCard.colorTheme // Use the theme color for background
                    .frame(height: 180) // Give it a decent height
                    .cornerRadius(12)
                
                Image(giftCard.imageName) // This will use a placeholder image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(0.5) // Make placeholder a bit subtle
                
                Text("\(giftCard.amount, specifier: "%.0f") TL")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
            
            Text(giftCard.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(giftCard.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Button(action: {
                if !isInCart {
                    cartManager.addGiftCardToCart(giftCard: giftCard)
                    showAddedToCartMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showAddedToCartMessage = false
                    }
                }
            }) {
                HStack {
                    Image(systemName: isInCart ? "checkmark.circle.fill" : "cart.badge.plus")
                    Text(isInCart ? "Sepete Eklendi" : "Sepete Ekle")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isInCart ? Color.gray : Color.red) // Use red as primary action color
                .cornerRadius(10)
                .animation(.easeInOut, value: isInCart)
            }
            .disabled(isInCart)

            if showAddedToCartMessage && !isInCart { // Show message only when just added
                 Text("Hediye kartı sepete eklendi!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 5)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Each card on a white background
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal) // Add horizontal padding for the cards themselves
    }
}

#Preview {
    NavigationView {
        GiftCardListView()
    }
} 