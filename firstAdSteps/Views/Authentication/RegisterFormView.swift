import SwiftUI

// Color+Theme extension'ını import et
@_exported import struct SwiftUI.Color

struct RegisterFormView: View {
    struct UserInfo {
        let name: String
        let surname: String
        let email: String
    }
    var onRegister: ((UserInfo) -> Void)? = nil
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var isFormValid = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, surname, email
    }
    
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
                                Text("Kayıt Ol")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.navy400)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer().frame(height: 12)
                                Text("Hesabınızı oluşturmak için bilgilerinizi girin")
                                    .font(.system(size: 16))
                                    .fontWeight(.light)
                                    .foregroundColor(Theme.navy400)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 10)
                            
                            // Form Alanları
                            VStack(spacing: 16) {
                                TextField("Ad", text: $name)
                                    .textFieldStyle(ReBrickInputStyle())
                                    .textContentType(.givenName)
                                    .autocapitalization(.words)
                                    .focused($focusedField, equals: .name)
                                
                                TextField("Soyad", text: $surname)
                                    .textFieldStyle(ReBrickInputStyle())
                                    .textContentType(.familyName)
                                    .autocapitalization(.words)
                                    .focused($focusedField, equals: .surname)
                                
                                TextField("E-posta", text: $email)
                                    .textFieldStyle(ReBrickInputStyle())
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                            }
                            
                            // Kayıt Ol Butonu
                            Button(action: {
                                if isFormValid {
                                    onRegister?(UserInfo(name: name, surname: surname, email: email))
                                }
                            }) {
                                Text("Kayıt Ol")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(isFormValid ? Theme.purple400 : Theme.gray300)
                                    .cornerRadius(12)
                            }
                            .disabled(!isFormValid)
                            
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
                    focusedField = nil
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: name) { _, _ in validateForm() }
        .onChange(of: surname) { _, _ in validateForm() }
        .onChange(of: email) { _, _ in validateForm() }
    }
    
    private func validateForm() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        isFormValid = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                     !surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                     emailPredicate.evaluate(with: email)
    }
}

#Preview {
    RegisterFormView()
} 
