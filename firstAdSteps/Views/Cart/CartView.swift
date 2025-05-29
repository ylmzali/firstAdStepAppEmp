import SwiftUI

extension Notification.Name {
    static let didCompleteCheckout = Notification.Name("didCompleteCheckoutNotification")
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}

struct CartView: View {
    @StateObject private var cartManager = CartManager.shared
    @State private var navigateToCheckout = false
    @State private var isGiftWrap = false
    @State private var couponCode: String = ""
    @State private var discountAmount: Double = 0.0
    @State private var appliedCouponCode: String? = nil
    @State private var showingCampaignSheet = false
    @State private var showingCouponEntrySheet = false
    @State private var selectedCampaign: Campaign? = nil {
        didSet {
            recalculateDiscounts()
        }
    }
    // New state variables for gift card redemption
    @State private var showingRedeemGiftCardSheet = false
    @State private var giftCardCodeInput: String = ""
    @State private var redeemedGiftCardAmount: Double = 0.0
    @State private var appliedGiftCardCode: String? = nil

    // Shipping cost only applies if there are physical products
    var shippingCost: Double {
        cartManager.cartItems.isEmpty ? 0 : 15.00
    }

    // Order total now comes directly from CartManager, which includes gift cards
    var orderTotal: Double {
        cartManager.getTotalPrice() // This now includes products and gift cards
    }

    var productsSubtotal: Double {
        cartManager.cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    var giftCardsSubtotal: Double {
        cartManager.giftCardItems.reduce(0) { $0 + $1.amount }
    }

    var grandTotal: Double {
        max(0, orderTotal + shippingCost - discountAmount - redeemedGiftCardAmount)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cartManager.cartItems.isEmpty && cartManager.giftCardItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Sepetiniz boş")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Sepetinize ürün veya hediye kartı ekleyebilirsiniz.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            if !cartManager.cartItems.isEmpty {
                                HStack {
                                    Image(systemName: "shippingbox")
                                    Text("İlk legon 1 - 7 Ağustos arasında gönderilecek")
                                        .font(.caption)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.3))
                            }

                            // Physical Product Items Section
                            if !cartManager.cartItems.isEmpty {
                                Text("Kiralık Ürünler")
                                    .font(.title3).bold()
                                    .padding([.top, .leading])
                                ForEach(cartManager.cartItems) { item in
                                    CartItemView(item: item) { newQuantity in
                                        cartManager.updateQuantity(for: item.product, quantity: newQuantity)
                                    } onDelete: {
                                        cartManager.removeFromCart(product: item.product)
                                    }
                                }
                                Divider().padding(.vertical)
                            }

                            // Gift Card Items Section
                            if !cartManager.giftCardItems.isEmpty {
                                Text("Hediye Kartları")
                                    .font(.title3).bold()
                                    .padding([.top, .leading])
                                ForEach(cartManager.giftCardItems) { giftCard in
                                    GiftCardCartItemView(giftCard: giftCard) {
                                        cartManager.removeGiftCardFromCart(giftCard: giftCard)
                                    }
                                }
                                Divider().padding(.vertical)
                            }
                    
                            // Replace the entire VStack below with CartSummaryView call
                            CartSummaryView(
                                productsSubtotal: productsSubtotal,
                                giftCardsSubtotal: giftCardsSubtotal,
                                shippingCost: shippingCost,
                                discountAmount: discountAmount,
                                appliedCouponCode: appliedCouponCode,
                                selectedCampaign: selectedCampaign,
                                redeemedGiftCardAmount: redeemedGiftCardAmount,
                                appliedGiftCardCode: appliedGiftCardCode,
                                grandTotal: grandTotal,
                                orderTotal: orderTotal,
                                isCartItemsEmpty: cartManager.cartItems.isEmpty,
                                isGiftWrap: $isGiftWrap,
                                showingCouponEntrySheet: $showingCouponEntrySheet,
                                showingCampaignSheet: $showingCampaignSheet,
                                showingRedeemGiftCardSheet: $showingRedeemGiftCardSheet,
                                onCheckout: {
                                    navigateToCheckout = true
                                }
                            )
                            .padding() // This padding was on the original VStack
                        }
                    }
                }
            }
            .navigationTitle("Sepet")
            // Moved NavigationLink here, to be triggered programmatically
            .background(
                NavigationLink(
                    destination: CheckoutView(
                        isGiftWrap: $isGiftWrap,
                        appliedCoupon: appliedCouponCode,
                        discountAmount: discountAmount,
                        appliedGiftCardCode: appliedGiftCardCode,
                        redeemedGiftCardAmount: redeemedGiftCardAmount
                    ),
                    isActive: $navigateToCheckout
                ) { EmptyView() }
            )
        }
        .onChange(of: cartManager.cartItems.isEmpty) { cartItemsAreEmpty in
            if cartItemsAreEmpty {
                isGiftWrap = false
                // Clear campaign and coupon states, then recalculate.
                selectedCampaign = nil // Triggers recalculateDiscounts via didSet
                appliedCouponCode = nil
                couponCode = ""
                // Explicitly recalculate if selectedCampaign was already nil, to ensure coupon state is cleared.
                // If selectedCampaign was not nil, its didSet already called recalculateDiscounts.
                if selectedCampaign == nil { // Check its current value after being set to nil
                    recalculateDiscounts() 
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didCompleteCheckout)) { _ in
            cartManager.clearCart()
            navigateToCheckout = false 
            discountAmount = 0
            appliedCouponCode = nil
            couponCode = ""
            selectedCampaign = nil
            // Reset gift card states
            redeemedGiftCardAmount = 0
            appliedGiftCardCode = nil
            giftCardCodeInput = ""
        }
        .sheet(isPresented: $showingCampaignSheet) {
            CampaignSheetView(selectedCampaign: $selectedCampaign)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingCouponEntrySheet) {
            CouponEntrySheetView(couponCode: $couponCode, onSave: {
                applyCoupon()
            })
            .presentationDetents([.medium, .large])
        }
        // New sheet for redeeming gift cards
        .sheet(isPresented: $showingRedeemGiftCardSheet) {
            RedeemGiftCardSheetView(giftCardCodeInput: $giftCardCodeInput, onApply: {
                applyGiftCard()
            })
            .presentationDetents([.medium, .large])
        }
    }

    func applyCoupon() {
        selectedCampaign = nil // Clear any active campaign first. This triggers recalculate via didSet.
        
        let codeToApply = couponCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if codeToApply == "INDIRIM25" {
            appliedCouponCode = codeToApply // Keep the code for display
            // discountAmount = 25.0 // Let recalculateDiscounts handle setting the amount
        } else {
            appliedCouponCode = nil // Invalid coupon
            // discountAmount = 0 // Let recalculateDiscounts handle this
        }
        recalculateDiscounts() // Recalculate after campaign is nil and coupon is processed
    }

    func recalculateDiscounts() {
        if let campaign = selectedCampaign {
            // Campaign is active, it overrides any coupon.
            appliedCouponCode = nil // Clear any applied coupon code if a campaign is selected
            // couponCode = "" // Keep couponCode text as is, in case user wants to re-apply if campaign is removed
            
            if let fixedDiscount = campaign.discountAmount {
                discountAmount = fixedDiscount
            } else if let percentageDiscount = campaign.discountPercentage {
                // Base percentage discount on productsSubtotal, as campaigns might not apply to gift cards
                discountAmount = productsSubtotal * percentageDiscount 
            } else {
                discountAmount = 0
            }
        } else if let coupon = appliedCouponCode, coupon == "INDIRIM25" {
            // No campaign active, check for the specific valid coupon
            discountAmount = 25.0
        } else {
            // No campaign and no valid coupon (or coupon was cleared)
            discountAmount = 0
            // appliedCouponCode should already be nil if we reach here from an invalid coupon entry
            // or if a campaign was selected then deselected.
        }
    }

    // New function to apply gift card
    func applyGiftCard() {
        // Mock valid gift cards (Code: Amount)
        let mockValidGiftCards: [String: Double] = ["GIFT100": 100.0, "GIFT50": 50.0, "GIFT20": 20.0]

        let codeToApply = giftCardCodeInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if !codeToApply.isEmpty, let cardAmount = mockValidGiftCards[codeToApply] {
            // Gift card is valid
            let payableAmount = orderTotal + shippingCost - discountAmount
            if payableAmount <= 0 {
                // Nothing to pay, clear any previously applied gift card
                self.redeemedGiftCardAmount = 0
                self.appliedGiftCardCode = nil
                // TODO: Optionally show an alert: "Ödenecek tutar yok."
            } else {
                self.redeemedGiftCardAmount = min(cardAmount, payableAmount)
                self.appliedGiftCardCode = codeToApply
                // TODO: Optionally show an alert: "Hediye kartı uygulandı."
            }
        } else {
            // Invalid or empty gift card code, clear any previously applied gift card
            self.redeemedGiftCardAmount = 0
            self.appliedGiftCardCode = nil
            if !codeToApply.isEmpty {
                // TODO: Optionally show an alert: "Geçersiz hediye kartı kodu."
            }
        }
        // Don't clear giftCardCodeInput here, so user can see what they typed if it fails.
        // The sheet will be dismissed.
    }
}

struct SummaryRow: View {
    let label: String
    let amount: Double
    var isTotal: Bool = false
    var isDiscount: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .subheadline)
                .foregroundColor(isDiscount ? .green : .primary)
            Spacer()
            Text("\(amount, specifier: "%.2f") ₺")
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(isDiscount ? .green : (isTotal ? .primary : .secondary))
        }
    }
}

// View for displaying Gift Cards in the cart
struct GiftCardCartItemView: View {
    let giftCard: GiftCard
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            giftCard.colorTheme
                .frame(width: 60, height: 40) // Smaller representation
                .cornerRadius(6)
                .overlay(
                    Image(systemName: "gift.card.fill")
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(giftCard.name)
                    .font(.headline)
                Text("Dijital Hediye Kartı")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(giftCard.amount, specifier: "%.0f") ₺")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color(UIColor.systemGray5)),
            alignment: .bottom
        )
    }
}

struct CartItemView: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let firstImage = item.product.imageUrls.first {
                Image(firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let pieceCount = item.product.pieceCount {
                    HStack(spacing: 4) {
                        Image(systemName: "puzzlepiece.extension")
                        Text("\(pieceCount) parça")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }

                if let ageRange = item.product.ageRange {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                        Text("\(ageRange) yaş")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(item.product.price * Double(item.quantity), specifier: "%.0f") ₺")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 8) {
                    Button(action: {
                        if item.quantity > 1 {
                            onQuantityChange(item.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus")
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Text("\(item.quantity)")
                        .font(.headline)
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        onQuantityChange(item.quantity + 1)
                    }) {
                        Image(systemName: "plus")
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(0)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color(UIColor.systemGray5)),
            alignment: .bottom
        )
    }
}

// --- Campaign Related Structures and Data ---
struct Campaign: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var discountPercentage: Double? = nil
    var discountAmount: Double? = nil
}

let sampleCampaigns: [Campaign] = [
    Campaign(name: "Yaz İndirimi", description: "Tüm ürünlerde %10 indirim!", discountPercentage: 0.10),
    Campaign(name: "Okula Dönüş", description: "Eğitici setlerde 50 TL indirim!", discountAmount: 50.0),
    Campaign(name: "Yeni Üyelik", description: "İlk kiralamanızda kargo bedava!", discountAmount: 15.0) // Assuming default shipping is 15.0 for this example
]
// --- End Campaign Data ---

struct CampaignSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCampaign: Campaign?
    @State private var localSelectedCampaign: Campaign?

    init(selectedCampaign: Binding<Campaign?>) { 
        self._selectedCampaign = selectedCampaign
        self._localSelectedCampaign = State(initialValue: selectedCampaign.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(sampleCampaigns) { campaign in
                        Button(action: {
                            if localSelectedCampaign == campaign {
                                localSelectedCampaign = nil
                            } else {
                                localSelectedCampaign = campaign
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(campaign.name).font(.headline)
                                    Text(campaign.description).font(.subheadline).foregroundColor(.gray)
                                }
                                Spacer()
                                if localSelectedCampaign == campaign {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .listStyle(PlainListStyle()) 
                
                Button("Seç ve Kapat") {
                    selectedCampaign = localSelectedCampaign 
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Kampanya Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Temizle") {
                        localSelectedCampaign = nil
                        // selectedCampaign = nil // Optionally clear immediately or only on close
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CouponEntrySheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var couponCode: String
    var onSave: () -> Void
    @State private var enteredCode: String = ""

    init(couponCode: Binding<String>, onSave: @escaping () -> Void) {
        self._couponCode = couponCode
        self.onSave = onSave
        self._enteredCode = State(initialValue: couponCode.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Kupon kodunu girin", text: $enteredCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.allCharacters)
                
                Button("Kuponu Uygula") {
                    couponCode = enteredCode // Update the binding
                    onSave() // Call the save handler which should trigger applyCoupon in CartView
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Kupon Kodu Gir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// New Sheet View for Redeeming Gift Card
struct RedeemGiftCardSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var giftCardCodeInput: String
    var onApply: () -> Void
    
    @State private var enteredCode: String // Local state for the text field

    init(giftCardCodeInput: Binding<String>, onApply: @escaping () -> Void) {
        self._giftCardCodeInput = giftCardCodeInput
        self.onApply = onApply
        self._enteredCode = State(initialValue: giftCardCodeInput.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Hediye kartı kodunu girin", text: $enteredCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.allCharacters)
                
                Button("Hediye Kartını Uygula") {
                    giftCardCodeInput = enteredCode // Update the binding
                    onApply() // Call the apply handler
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Hediye Kartı Kullan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Temizle") {
                        enteredCode = ""
                        // giftCardCodeInput = "" // Optionally clear binding immediately
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// New CartSummaryView struct
struct CartSummaryView: View {
    let productsSubtotal: Double
    let giftCardsSubtotal: Double
    let shippingCost: Double
    let discountAmount: Double
    let appliedCouponCode: String?
    let selectedCampaign: Campaign?
    let redeemedGiftCardAmount: Double
    let appliedGiftCardCode: String?
    let grandTotal: Double
    let orderTotal: Double // Needed for subtotalAfterPromotionalDiscounts calculation
    let isCartItemsEmpty: Bool // Derived from cartManager.cartItems.isEmpty

    @Binding var isGiftWrap: Bool
    @Binding var showingCouponEntrySheet: Bool
    @Binding var showingCampaignSheet: Bool
    @Binding var showingRedeemGiftCardSheet: Bool
    
    let onCheckout: () -> Void

    // Computed property for clarity
    private var subtotalAfterPromotionalDiscounts: Double {
        orderTotal + shippingCost - discountAmount
    }

    var body: some View {
        VStack(spacing: 12) {
            if !isCartItemsEmpty { // Check if there are physical products
                 SummaryRow(label: "Ürünler Toplamı:", amount: productsSubtotal)
            }
            if giftCardsSubtotal > 0 { // Check if there are gift cards (original logic used !cartManager.giftCardItems.isEmpty)
                SummaryRow(label: "Hediye Kartları Toplamı:", amount: giftCardsSubtotal)
            }
            if shippingCost > 0 {
                SummaryRow(label: "Kargo:", amount: shippingCost)
            }
            
            if discountAmount > 0 {
                // let interpolatedDiscountInfo = appliedCouponCode ?? selectedCampaign?.name ?? ""
                let discountLabelText = "İndirim:" // Static label
                SummaryRow(label: discountLabelText, amount: -discountAmount, isDiscount: true)
            }

            if redeemedGiftCardAmount > 0 {
                // let interpolatedGiftCardInfo = appliedGiftCardCode ?? ""
                let redeemedGiftCardLabelText = "Kullanılan Hediye Kartı:" // Static label
                SummaryRow(label: redeemedGiftCardLabelText, amount: -redeemedGiftCardAmount, isDiscount: true)
            }

            SummaryRow(label: "Genel Toplam:", amount: grandTotal, isTotal: true)

            // Main VStack for the button grid
            VStack(spacing: 10) {
                // First row of buttons
                if !isCartItemsEmpty { // Gift wrap and Coupon only if physical items
                    HStack(spacing: 10) {
                        Button(action: {
                            isGiftWrap.toggle()
                        }) {
                            VStack {
                                Image(systemName: isGiftWrap ? "gift.fill" : "gift")
                                    .foregroundColor(isGiftWrap ? .white : .blue)
                                Text("Hediye Paketi\nYap") // Static
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(isGiftWrap ? .white : .primary)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(isGiftWrap ? Color.blue : Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }

                        Button(action: {
                            showingCouponEntrySheet = true 
                        }) {
                            VStack {
                                Image(systemName: appliedCouponCode != nil ? "ticket.fill" : "ticket")
                                    .foregroundColor(appliedCouponCode != nil ? .white : .blue)
                                Text("Kupon Kodu\nEkle") // Static
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .truncationMode(.tail)
                                    .foregroundColor(appliedCouponCode != nil ? .white : .primary)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(appliedCouponCode != nil ? Color.blue : Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                    } // End of first HSTACK (Gift Wrap, Coupon)
                }

                // Second row of buttons (Campaign, Gift Card)
                // Only create this HStack if at least one of its potential buttons could be visible
                if !isCartItemsEmpty || subtotalAfterPromotionalDiscounts > 0 {
                    HStack(spacing: 10) {
                        if !isCartItemsEmpty { // Campaign only if physical items
                            Button(action: {
                                showingCampaignSheet = true
                            }) {
                                VStack {
                                    Image(systemName: selectedCampaign != nil ? "flame.fill" : "flame")
                                        .foregroundColor(selectedCampaign != nil ? .white : .blue)
                                    Text("Kampanya\nSeç") // Static
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .truncationMode(.tail)
                                        .foregroundColor(selectedCampaign != nil ? .white : .primary)
                                }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(selectedCampaign != nil ? Color.blue : Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        } else {
                            // If no physical items, Campaign button is not shown.
                            // This column should be empty to maintain 2-column structure.
                            Spacer().frame(maxWidth: .infinity)
                        }

                        if subtotalAfterPromotionalDiscounts > 0 { // Gift card only if amount to pay
                            Button(action: {
                                showingRedeemGiftCardSheet = true
                            }) {
                                VStack {
                                    Image(systemName: appliedGiftCardCode != nil ? "giftcard.fill" : "giftcard")
                                        .foregroundColor(appliedGiftCardCode != nil ? .white : .blue)
                                    Text("Hediye Kartı\nKullan") // Static label
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .truncationMode(.tail)
                                        .foregroundColor(appliedGiftCardCode != nil ? .white : .primary)
                                }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(appliedGiftCardCode != nil ? Color.blue : Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        } else {
                            // If gift card button is hidden.
                            // This column should be empty to maintain 2-column structure.
                            Spacer().frame(maxWidth: .infinity)
                        }
                    } // End of second HSTACK (Campaign, Gift Card)
                }
            }
            .padding(.vertical)

            Button(action: onCheckout) { // Use the passed-in closure
                Text("Devam Et")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            // The NavigationLink is now handled in CartView
        }
    }
}

#Preview {
    CartView()
} 

