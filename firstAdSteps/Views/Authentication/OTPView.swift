import SwiftUI

// Color+Theme extension'ını import et
@_exported import struct SwiftUI.Color

struct OTPView: View {
    var onSubmit: ((String) -> Void)? = nil
    var onEditPhone: (() -> Void)? = nil
    @State private var otpCode = ""
    @State private var timeRemaining = 60
    @State private var isTimerRunning = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var showResendInfo = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isOTPFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.yellow400.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: keyboardHeight)
                        // Üst %35 transparan alan ve ortada resim
                        VStack {
                            Image("icon-legos")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                        }
                        .padding(.top, 45)
                        .frame(height: geometry.size.height * 0.35)
                        // Alt %65 scroll edilebilir beyaz sheet
                        VStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Size 4 haneli bir sifreyi SMS olarak gonderdik.")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.navy400)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer().frame(height: 12)
                                Text("Size gelen kodu aşağıya giriniz.")
                                    .font(.system(size: 16))
                                    .fontWeight(.light)
                                    .foregroundColor(Theme.navy400)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 10)
                            // OTP Input
                            HStack {
                                TextField("4 haneli kod", text: $otpCode)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal, 12)
                                    .frame(height: 52)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Theme.purple400, lineWidth: 1)
                                    )
                                    .focused($isOTPFieldFocused)
                                    .onChange(of: otpCode) { _, newValue in
                                        if newValue.count > 4 {
                                            otpCode = String(newValue.prefix(4))
                                        }
                                    }
                            }
                            // Timer veya Resend
                            if isTimerRunning {
                                Text("Kodu yeniden gönderebilmek için \(timeRemaining) saniye bekleyin.")
                                    .multilineTextAlignment(.center)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.gray400)
                            } else {
                                Button(action: {
                                    timeRemaining = 60
                                    isTimerRunning = true
                                    showResendInfo = true
                                }) {
                                    Text("Kodu Yeniden Gönder")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.blue400)
                                }
                            }
                            if showResendInfo {
                                Text("Kod tekrar gönderildi.")
                                    .font(.footnote)
                                    .foregroundColor(Theme.green400)
                            }
                            // Devam Et Butonu
                            Button(action: {
                                if otpCode.count == 4 {
                                    onSubmit?(otpCode)
                                }
                            }) {
                                Text("Devam Et")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(otpCode.count == 4 ? Theme.purple400 : Theme.gray300)
                                    .cornerRadius(12)
                            }
                            .disabled(otpCode.count != 4)
                            // Numarayı Düzenle Butonu
                            Button(action: {
                                onEditPhone?()
                            }) {
                                Text("Numarayı Düzenle")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.blue400)
                                    .padding(.top, 8)
                            }
                            Spacer()
                        }
                        .padding(.top, geometry.size.height * 0.65 * 0.05)
                        .frame(height: geometry.size.height * 0.65)
                        .padding(.horizontal, 24)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .background(
                            Color.white
                                .cornerRadius(32, corners: [.topLeft, .topRight])
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: -2)
                        )
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .contentShape(Rectangle())
                .onTapGesture {
                    isOTPFieldFocused = false
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(timer) { _ in
            if isTimerRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isTimerRunning = false
            }
        }
    }
}

#Preview {
    OTPView()
} 
