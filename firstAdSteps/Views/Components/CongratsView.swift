import SwiftUI

struct CongratsView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Theme.green400)
            Text("Tebrikler!")
                .font(.title)
                .fontWeight(.bold)
            Text("Lütfen mailinizi onaylayın.")
                .font(.title3)
                .foregroundColor(.secondary)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Theme.blue400))
                .scaleEffect(1.5)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    CongratsView()
} 
