import SwiftUI

struct PaymentView: View {
    // Called before payment attempt to pass card info to CheckoutView
    var onContinue: (PaymentCardInfo) -> Void 
    // Called after payment attempt with success/failure status
    var onPaymentAttemptCompleted: (Bool) -> Void

    // Amounts passed from CheckoutView
    let discountAmount: Double
    let redeemedGiftCardAmount: Double

    @StateObject private var cartManager = CartManager.shared // Access CartManager for totals

    // Explicit Initializer
    init(onContinue: @escaping (PaymentCardInfo) -> Void, 
         onPaymentAttemptCompleted: @escaping (Bool) -> Void, 
         discountAmount: Double, 
         redeemedGiftCardAmount: Double) {
        self.onContinue = onContinue
        self.onPaymentAttemptCompleted = onPaymentAttemptCompleted
        self.discountAmount = discountAmount
        self.redeemedGiftCardAmount = redeemedGiftCardAmount
        // Note: @StateObject cartManager is initialized automatically by SwiftUI.
    }

    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var cardholderName: String = ""
    
    @State private var isProcessingPayment = false
    // paymentSuccess state is no longer needed here, as outcome is passed via onPaymentAttemptCompleted

    // Calculated final amount to be paid
    private var shippingCost: Double {
        // Recalculate based on physical items, similar to CartView
        cartManager.cartItems.isEmpty ? 0 : 15.00 
    }

    private var finalPayableAmount: Double {
        max(0, cartManager.getTotalPrice() + shippingCost - discountAmount - redeemedGiftCardAmount)
    }

    var body: some View {
        ZStack { // ZStack ile ana içeriği ve overlay'i sarmala
            // Wrap in ScrollView in case content overflows on smaller devices
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Ödeme Bilgileri")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Display the final amount to be paid
                    Text("Ödenecek Tutar: \(finalPayableAmount, specifier: "%.2f") ₺")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 20)
                    
                    // Apple Pay Button Placeholder
                    // In a real app, use PayWithApplePayButton for SwiftUI (iOS 16+)
                    // or integrate PKPaymentButton from PassKit via UIViewRepresentable.
                    Button(action: {
                        // TODO: Implement Apple Pay logic
                        print("Apple Pay Tapped - Implement Apple Pay Flow")
                        // This would typically involve presenting a PKPaymentAuthorizationViewController
                        // or handling the action of PayWithApplePayButton.
                    }) {
                        // Basic placeholder styling for an Apple Pay button
                        // For an authentic look, you'd use the official button components.
                        HStack {
                            // It's best to use the official Apple Pay mark.
                            // For this placeholder, we use an SF Symbol.
                            Image(systemName: "applelogo") // Placeholder, replace with actual Apple Pay mark/logo
                                .font(.title2)
                            Text("Pay")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.bottom)

                    Text("Veya Kredi Kartı ile Öde")
                        .font(.headline)
                        .padding(.bottom, 8)

                    // Form for manual card entry - Replaced with VStack and TextFields
                    VStack(spacing: 16) { // TextField'lar arası boşluk
                        TextField("Kart Sahibinin Adı Soyadı", text: $cardholderName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Kart Numarası", text: $cardNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        TextField("Son Kullanma Tarihi (AA/YY)", text: $expiryDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                        TextField("CVV", text: $cvv)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    .padding(.bottom) // TextField grubunun altına boşluk
                    
                    Spacer()
                    
                    // Mevcut ProgressView buradan kaldırılacak ve overlay'e taşınacak.
                    // Button "Ödemeyi Tamamla" olduğu gibi kalacak, ProgressView overlay ile yönetilecek.
                    Button(action: {
                        let cardInfo = PaymentCardInfo(cardNumber: cardNumber, 
                                                     expiryDate: expiryDate, 
                                                     cvv: cvv, 
                                                     cardholderName: cardholderName)
                        onContinue(cardInfo) 
                        processPayment()     
                    }) {
                        Text("Ödemeyi Tamamla")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isPaymentFormValid() ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isPaymentFormValid() || isProcessingPayment) // Disable button if processing
                } // End of VStack
                .padding() // ScrollView içeriği için padding
            } // End of ScrollView
            .disabled(isProcessingPayment) // Ödeme işlenirken alttaki view'ı disable et

            // Tam ekran ProgressView overlay'i
            if isProcessingPayment {
                Color.black.opacity(0.4) // Yarı saydam arka plan
                    .edgesIgnoringSafeArea(.all) // Kenarlara kadar uzansın
                
                VStack { // ProgressView ve metni ortalamak için
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2) // Biraz daha büyük görünmesi için
                    Text("Ödeme işleniyor...")
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
        } // End of ZStack
        // .padding() // ZStack'e padding uygulamak yerine ScrollView içindeki VStack'e uygulandı.
    }

    func isPaymentFormValid() -> Bool {
        return !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty && !cardholderName.isEmpty && cvv.count == 3 && expiryDate.count == 5 && isValidExpiry(expiryDate)
    }
    
    func isValidExpiry(_ expiry: String) -> Bool {
        let parts = expiry.split(separator: "/")
        guard parts.count == 2, 
              let month = Int(parts[0]), 
              let year = Int(parts[1]),
              (1...12).contains(month) else { return false }
        
        let now = Date()
        let currentYear = Calendar.current.component(.year, from: now) % 100
        let currentMonth = Calendar.current.component(.month, from: now)
        
        if year < currentYear { return false }
        if year == currentYear && month < currentMonth { return false }
        return true
    }

    func processPayment() {
        isProcessingPayment = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { 
            isProcessingPayment = false
            let paymentSucceeded = Bool.random() 
            onPaymentAttemptCompleted(paymentSucceeded)
        }
    }
}

#Preview {
    NavigationView {
        PaymentView(
            onContinue: { cardInfo in print("Card info: \(cardInfo)") },
            onPaymentAttemptCompleted: { success in print("Payment attempt completed: \(success)") },
            discountAmount: 10.0, // Example value
            redeemedGiftCardAmount: 5.0 // Example value
        )
    }
} 
