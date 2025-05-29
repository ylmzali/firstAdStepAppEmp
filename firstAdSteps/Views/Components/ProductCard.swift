import SwiftUI

struct ProductCard: View {
    let product: Product
    @StateObject private var cartManager = CartManager.shared
    @State private var isActive = false
    
    init(product: Product) {
        self.product = product
    }
    
    private var isInCart: Bool {
        cartManager.cartItems.contains { $0.product.id == product.id }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .bottomTrailing) {
                    if let firstImage = product.imageUrls.first {
                        Image(firstImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        cartManager.addToCart(product: product)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(4)
                    .contentShape(Circle())
                }
                
                Text(product.name)
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.caption)
                    Text("12+ yaş")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(product.price, specifier: "%.0f") ₺")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
            .frame(width: 120)
            .background(RoundedRectangle(cornerRadius: 12).stroke(isInCart ? Color.green : Color.gray.opacity(0.2), lineWidth: isInCart ? 2 : 1))
            .contentShape(Rectangle())
            .onTapGesture {
                isActive = true
            }
        }
        .navigationDestination(isPresented: $isActive) {
            ProductDetailView(product: product)
        }
    }
}

#Preview {
    NavigationStack {
        ProductCard(product: sampleProducts[0])
    }
} 
