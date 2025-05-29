import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.dismiss) var dismiss // To potentially dismiss the whole checkout flow
    @Environment(\.presentationMode) var presentationMode // For custom back button if needed or to pop

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding(.top, 40) // Add some padding from the nav bar

            Text("Siparisin alindi!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "3A3A3A")) // Darker text color

            Text("Siparisinle ilgili bilgileri mail adresine gonderdik.")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Points reward banner
            ZStack(alignment: .topTrailing) {
                HStack {
                    Spacer()
                    Text("Legonu bize 15 gun onceden gonder 15 puan kazan!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .background(Color.green)
                .cornerRadius(15)
                .padding(.horizontal)

                Text("+15 puan")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(Color.red)
                    .clipShape(Capsule())
                    .offset(x: -25, y: -10) // Adjust position of the badge
            }
            .padding(.vertical)


            Spacer() // Pushes buttons to the bottom

            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    // TODO: Implement order tracking
                    print("Siparişi takip et tıklandı.")
                }) {
                    Text("Siparisi takip et")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25) // Rounded corners like image
                }

                Button(action: {
                    NotificationCenter.default.post(name: .didCompleteCheckout, object: nil)
                    // presentationMode.wrappedValue.dismiss() // This might dismiss only this view.
                                                              // Rely on CartView to pop to root.
                }) {
                    Text("Ana sayfaya geri don")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue) // Blue text color
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25) // Rounded corners like image
                                .stroke(Color.blue, lineWidth: 2) // Blue border
                        )
                }
            }
            .padding()
        }
        .navigationTitle("Siparis Detayi")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // Ensure back button is visible
        // .navigationBarHidden(false) // Redundant if title is set
        .onAppear {
            // Optionally, you could post the notification here as well or instead
            // NotificationCenter.default.post(name: .didCompleteCheckout, object: nil)
        }
    }
}

#Preview {
    NavigationView { // Wrap in NavigationView for preview
        OrderSuccessView()
    }
} 