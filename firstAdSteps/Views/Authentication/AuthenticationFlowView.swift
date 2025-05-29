import SwiftUI

struct AuthenticationFlowView: View {
    enum Step {
        case phone, otp, register, main
    }
    
    @State private var step: Step = .phone
    @State private var phoneNumber: String = ""
    @State private var otpCode: String = ""
    @StateObject private var sessionManager = SessionManager.shared
    
    var body: some View {
        Group {
            switch step {
            case .phone:
                PhoneVerificationView(
                    onContinue: { enteredPhone in
                        phoneNumber = enteredPhone
                        step = .otp
                    }
                )
            case .otp:
                OTPView(
                    onSubmit: { code in
                        // Burada kodu kontrol et (ör: 1234)
                        if code == "1234" {
                            otpCode = code
                            step = .register
                        }
                    },
                    onEditPhone: {
                        step = .phone
                    }
                )
            case .register:
                RegisterFormView(
                    onRegister: { userInfo in
                        // Kayıt başarılı, session ata
                        sessionManager.saveUserData(name: userInfo.name, phoneNumber: phoneNumber)
                        step = .main
                    }
                )
            case .main:
                MainPageView()
            }
        }
        .onAppear {
            print("AuthFlow appeared, session: \(sessionManager.hasSession)") // Debug için
            if sessionManager.hasSession {
                step = .main
            } else {
                step = .phone
            }
        }
        .onChange(of: sessionManager.hasSession) { _, hasSession in
            print("AuthFlow session changed: \(hasSession)") // Debug için
            withAnimation {
                if hasSession {
                    step = .main
                } else {
                    step = .phone
                }
            }
        }
    }
}

// PhoneVerificationView, OTPView ve RegisterFormView'a ilgili closure parametrelerini eklemeniz gerekecek. 
