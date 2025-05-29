import SwiftUI

struct CheckoutView: View {
    @StateObject private var cartManager = CartManager.shared // Access CartManager
    @State private var currentStep: Int
    
    // Order details passed from CartView
    @Binding var isGiftWrap: Bool
    let appliedCoupon: String?
    let discountAmount: Double
    let appliedGiftCardCode: String?
    let redeemedGiftCardAmount: Double
    
    // State for selected address, payment details etc.
    @State var deliveryAddress: Address? = nil
    @State var paymentDetails: PaymentCardInfo? = nil

    // Initializer to set currentStep based on cart contents
    init(isGiftWrap: Binding<Bool>, appliedCoupon: String?, discountAmount: Double, appliedGiftCardCode: String?, redeemedGiftCardAmount: Double) {
        self._isGiftWrap = isGiftWrap
        self.appliedCoupon = appliedCoupon
        self.discountAmount = discountAmount
        self.appliedGiftCardCode = appliedGiftCardCode
        self.redeemedGiftCardAmount = redeemedGiftCardAmount
        
        // Determine initial step
        if CartManager.shared.cartItems.isEmpty && !CartManager.shared.giftCardItems.isEmpty {
            // Only gift cards in cart, skip delivery
            self._currentStep = State(initialValue: 1) 
        } else {
            // Products in cart (or empty cart, though shouldn't reach here if cart is totally empty normally)
            self._currentStep = State(initialValue: 0)
        }
    }

    var body: some View {
        VStack {
            // Progress indicator could also be adapted based on whether delivery is skipped
            // Example: if cartManager.cartItems.isEmpty { Text("Adım \(currentStep) / 2") } else { Text("Adım \(currentStep + 1) / 3") }

            if currentStep == 0 {
                DeliveryAddressView(onContinue: { selectedAddress in
                    self.deliveryAddress = selectedAddress
                    moveToNextStep()
                })
            } else if currentStep == 1 {
                PaymentView(
                    onContinue: { cardInfo in 
                        self.paymentDetails = cardInfo
                        print("Order details for processing: Address: \(String(describing: deliveryAddress)), Payment: \(cardInfo)")
                        print("Cart items: \(cartManager.cartItems)")
                        print("Gift cards: \(cartManager.giftCardItems)") // Log gift cards
                        print("Gift Wrap: \(isGiftWrap), Coupon: \(String(describing: appliedCoupon)), Discount: \(discountAmount)")
                        print("Applied Gift Card: \(String(describing: appliedGiftCardCode)), Redeemed Amount: \(redeemedGiftCardAmount)")
                    },
                    onPaymentAttemptCompleted: { success in
                        if success {
                            moveToNextStep() 
                        } else {
                            moveToFailure() 
                        }
                    },
                    discountAmount: self.discountAmount,
                    redeemedGiftCardAmount: self.redeemedGiftCardAmount
                )
            } else if currentStep == 2 {
                OrderSuccessView()
            } else if currentStep == 3 { 
                OrderFailureView(onRetry: { retryPayment() })
            }
        }
        .navigationTitle(currentStep == 0 ? "Teslimat Adresi" : "Ödeme") // Dynamic title
        .navigationBarTitleDisplayMode(.inline)
    }

    func moveToNextStep() {
        // If delivery was skipped and we are at step 1 (Payment), next is step 2 (Success)
        // If delivery was NOT skipped (currentStep 0 -> 1), then from 1 (Payment) next is 2 (Success)
        if currentStep < 2 {
            currentStep += 1
        } 
    }
    
    func moveToFailure() {
        currentStep = 3 
    }
    
    func retryPayment() {
        // If delivery was skipped, retry goes to step 1 (Payment)
        // If delivery was NOT skipped, retry also goes to step 1 (Payment)
        currentStep = 1 
    }
}

// Dummy struct for payment card info, expand as needed
struct PaymentCardInfo {
    let cardNumber: String
    let expiryDate: String
    let cvv: String
    let cardholderName: String
}


#Preview {
    NavigationView {
        // To preview gift card only flow, you'd need to mock CartManager state
        CheckoutView(isGiftWrap: .constant(false), appliedCoupon: nil, discountAmount: 0.0, appliedGiftCardCode: nil, redeemedGiftCardAmount: 0.0)
    }
} 