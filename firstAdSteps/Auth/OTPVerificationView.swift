//
//  v.swift
//  firstAdSteps
//
//  Created by Ali YILMAZ on 28.05.2025.
//

import SwiftUI

struct OTPVerificationView: View {
    @State private var otp: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            TextField("OTP", text: $otp)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: verifyOTP) {
                Text("Doğrula")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isLoading)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }

    func verifyOTP() {
        isLoading = true
        // API isteği burada yapılacak
        // Örnek: AuthService.verifyOTP(otp: otp) { result in ... }
    }
}

#Preview {
    OTPVerificationView()
}
