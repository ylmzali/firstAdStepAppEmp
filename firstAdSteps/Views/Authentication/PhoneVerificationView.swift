import SwiftUI

// Color+Theme extension'ını import et
@_exported import struct SwiftUI.Color

// struct CountryCode: Identifiable { // Removed this redeclaration
//     let id = UUID()
//     let name: String
//     let code: String
//     let flag: String
//     let format: String
// }

struct PhoneVerificationView: View {
    var onContinue: ((String) -> Void)? = nil
    @State private var selectedCountry = CountryCode(
        name: "Türkiye",
        code: "+90",
        flag: "🇹🇷",
        format: "### ### ## ##"
    )
    @State private var phoneNumber = ""
    @State private var isPhoneValid = false
    @State private var showCountryPicker = false
    @State private var kvkkAccepted = false
    @State private var termsAccepted = false
    @State private var campaignAccepted = false
    @State private var showKvkkSheet = false
    @State private var showTermsSheet = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isPhoneFieldFocused: Bool
    @StateObject private var sessionManager = SessionManager.shared
    
    let countries = [
        CountryCode(name: "Türkiye", code: "+90", flag: "🇹🇷", format: "### ### ## ##"),
        CountryCode(name: "United States", code: "+1", flag: "🇺🇸", format: "(###) ###-####"),
        CountryCode(name: "United Kingdom", code: "+44", flag: "🇬🇧", format: "#### ######"),
        CountryCode(name: "Germany", code: "+49", flag: "🇩🇪", format: "#### ######"),
        CountryCode(name: "France", code: "+33", flag: "🇫🇷", format: "## ## ## ## ##")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.yellow400.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: keyboardHeight)
                        // Üst %35 transparan alan ve ortada resim
                        VStack {
                            // Arka plan yok, transparan
                            Image("icon-legos")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                        }
                        .padding(.top, 45)
                        .frame(height: geometry.size.height * 0.35)
                        // Alt %65 scroll edilebilir beyaz sheet
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Telefon Numaranızı Girin")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.navy400)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 10)
                            // Input group
                            HStack(spacing: 0) {
                                Button(action: { showCountryPicker = true }) {
                                    HStack {
                                        Text(selectedCountry.flag)
                                        Text(selectedCountry.code)
                                            .foregroundColor(Theme.gray600)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14))
                                            .foregroundColor(Theme.gray400)
                                    }
                                    .padding(.horizontal, 12)
                                    .frame(height: 52)
                                    .background(Theme.gray100)
                                    .cornerRadius(8)
                                }
                                .sheet(isPresented: $showCountryPicker) {
                                    CountryPickerView(selectedCountry: $selectedCountry, countries: countries)
                                }
                                TextField("5xx xxx xx xx", text: $phoneNumber)
                                    .keyboardType(.numberPad)
                                    .padding(.vertical, 0)
                                    .padding(.horizontal, 12)
                                    .frame(height: 52)
                                    .background(Color.clear)
                                    .focused($isPhoneFieldFocused)
                                    .onChange(of: phoneNumber) { _, newValue in
                                        validatePhoneNumber(newValue)
                                    }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.purple400, lineWidth: 1)
                            )
                            // KVKK ve Şartlar
                            VStack(alignment: .leading, spacing: 20) {
                                Toggle(isOn: $kvkkAccepted) {
                                    HStack(spacing: 0) {
                                        Button(action: { showKvkkSheet = true }) {
                                            Text("KVKK Aydınlatma Metni'ni okudum kabul ediyorum.").underline()
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Theme.purple400))
                                .font(.subheadline)
                                .foregroundColor(Theme.gray600)
                                .sheet(isPresented: $showKvkkSheet) {
                                    KvkkSheetView()
                                }
                                Toggle(isOn: $termsAccepted) {
                                    HStack(spacing: 0) {
                                        Button(action: { showTermsSheet = true }) {
                                            Text("Kullanım Şartları'nı okudum kabul ediyorum.").underline()
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Theme.purple400))
                                .font(.subheadline)
                                .foregroundColor(Theme.gray600)
                                .sheet(isPresented: $showTermsSheet) {
                                    TermsSheetView()
                                }
                                Toggle(isOn: $campaignAccepted) {
                                    Text("Kampanya ve yeniliklerden haberdar olmak istiyorum.")
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Theme.purple400))
                                .font(.subheadline)
                                .foregroundColor(Theme.gray600)
                            }
                            // Devam Et Butonu
                            Button(action: {
                                if isFormValid {
                                    sessionManager.phoneNumber = phoneNumber
                                    onContinue?(phoneNumber)
                                }
                            }) {
                                Text("Devam Et")
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
                    isPhoneFieldFocused = false
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    private var isFormValid: Bool {
        isPhoneValid && kvkkAccepted && termsAccepted
    }
    
    private func validatePhoneNumber(_ number: String) {
        let digits = number.filter { $0.isNumber }
        isPhoneValid = digits.count == 10
    }
}

struct KvkkSheetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("KVKK Aydınlatma Metni")
                .font(.headline)
                .padding(.bottom, 8)
            ScrollView {
                Text("Buraya KVKK Aydınlatma metni gelecek. Kullanıcıya gerekli bilgilendirme burada gösterilecek.")
                    .font(.body)
            }
            Spacer()
            Button("Kapat") {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
    }
}

struct TermsSheetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kullanım Şartları")
                .font(.headline)
                .padding(.bottom, 8)
            ScrollView {
                Text("Buraya Kullanım Şartları metni gelecek. Kullanıcıya gerekli bilgilendirme burada gösterilecek.")
                    .font(.body)
            }
            Spacer()
            Button("Kapat") {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
    }
}

// Köşe yuvarlama için yardımcı extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// struct CountryPickerView: View { // Removed this redeclaration
//     @Binding var selectedCountry: CountryCode
//     let countries: [CountryCode]
//     @Environment(\.dismiss) var dismiss
// 
//     var body: some View {
//         NavigationView {
//             List(countries, id: \.self) { country in
//                 HStack {
//                     Text(country.flag)
//                     Text(country.name)
//                     Spacer()
//                     if country.code == selectedCountry.code {
//                         Image(systemName: "checkmark")
//                             .foregroundColor(.blue)
//                     }
//                 }
//                 .contentShape(Rectangle())
//                 .onTapGesture {
//                     selectedCountry = country
//                     dismiss()
//                 }
//             }
//             .navigationTitle("Ülke Seç")
//             .navigationBarItems(trailing: Button("Kapat") {
//                 dismiss()
//             })
//         }
//     }
// }

#Preview {
    PhoneVerificationView()
} 
