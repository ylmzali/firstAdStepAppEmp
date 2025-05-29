//
//  LoginView.swift
//  firstAdSteps
//
//  Created by Ali YILMAZ on 28.05.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            
            TextField("E-posta", text: $email)
                .textFieldStyle(AntTextFieldStyle())
                .padding(.horizontal)

            TextField("E-posta", text: $email)
                .textFieldStyle(AntTextFieldStyle())
                .padding(.horizontal)

            TextField("Telefon", text: $phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: sendOTP) {
                Text("OTP Gönder")
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

    func sendOTP() {
        isLoading = true
        // API isteği burada yapılacak
        // Örnek: AuthService.sendOTP(email: email, phone: phone) { result in ... }
    }
}


#Preview {
    LoginView()
}
