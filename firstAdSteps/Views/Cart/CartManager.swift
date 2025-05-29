import SwiftUI

class CartManager: ObservableObject {
    static let shared = CartManager()
    @Published var itemCount: Int = 0
    @Published var cartItems: [CartItem] = []
    @Published var giftCardItems: [GiftCard] = []
    
    private init() {
        updateTotals()
    }
    
    func addToCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
        updateTotals()
    }
    
    func removeFromCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems.remove(at: index)
            updateTotals()
        }
    }
    
    func updateQuantity(for product: Product, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                cartItems.remove(at: index)
            }
            updateTotals()
        }
    }
    
    func addGiftCardToCart(giftCard: GiftCard) {
        if !giftCardItems.contains(where: { $0.id == giftCard.id }) {
            giftCardItems.append(giftCard)
        }
        updateTotals()
    }

    func removeGiftCardFromCart(giftCard: GiftCard) {
        giftCardItems.removeAll { $0.id == giftCard.id }
        updateTotals()
    }
    
    func clearCart() {
        cartItems.removeAll()
        giftCardItems.removeAll()
        updateTotals()
    }
    
    func getTotalPrice() -> Double {
        let productsTotal = cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
        let giftCardsTotal = giftCardItems.reduce(0) { $0 + $1.amount }
        return productsTotal + giftCardsTotal
    }
    
    func getItemCount() -> Int {
        let productItemCount = cartItems.reduce(0) { $0 + $1.quantity }
        let giftCardItemCount = giftCardItems.count
        return productItemCount + giftCardItemCount
    }

    private func updateTotals() {
        itemCount = getItemCount()
    }
} 