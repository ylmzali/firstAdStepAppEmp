import SwiftUI

struct OrderFailureView: View {
    @Environment(\.presentationMode) var presentationMode // To potentially dismiss or go back
    var onRetry: (() -> Void)? // Callback to signal a retry attempt

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "xmark.octagon.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            
            Text("Ödeme Başarısız")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Ödemeniz işlenirken bir hata oluştu. Lütfen bilgilerinizi kontrol edin ve tekrar deneyin veya farklı bir ödeme yöntemi kullanın.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                if let retryAction = onRetry {
                    retryAction()
                } else {
                    // Fallback if no retry action is provided (e.g., just dismiss)
                    // This might not be the ideal UX, depends on how CheckoutView is structured.
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text(onRetry != nil ? "Tekrar Dene" : "Geri Dön") // Dynamic button text
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationBarHidden(true) // Often failure screens also hide navigation
    }
}

#Preview {
    OrderFailureView(onRetry: { print("Retry Tapped") })
} 