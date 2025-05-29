//
//  PersonalInfo.swift
//  re-brick-app-1
//
//  Created by Ali YILMAZ on 25.05.2025.
//

import SwiftUI

// Kişisel Bilgilerim detay sayfası
struct UserProfilePersonalInfoView: View {
    @State private var firstName: String = "Ali"
    @State private var lastName: String = "Yılmaz"
    @State private var email: String = "ylmzali@gmail.com"
    @State private var isEmailVerified: Bool = true
    @State private var showEmailVerify: Bool = false
    @State private var emailChanged: Bool = false
    @State private var showSaved: Bool = false
    @State private var phone: String = "+90 555 123 45 67"
    @State private var navigateToPhoneVerification: Bool = false
    @State private var showDeleteAccountAlert = false
    @StateObject private var sessionManager = SessionManager.shared

    var body: some View {
        Form {
            Section(header: Text("Kişisel Bilgiler")) {
                TextField("Ad", text: $firstName)
                TextField("Soyad", text: $lastName)
                HStack {
                    TextField("E-posta", text: $email, onEditingChanged: { editing in
                        if !editing { emailChanged = true }
                    })
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    if isEmailVerified && !emailChanged {
                        Label("Onaylandı", systemImage: "checkmark.seal.fill")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.green)
                            .accessibilityLabel("E-posta onaylandı")
                    } else {
                        Button(action: { showEmailVerify = true }) {
                            Text("Onayla")
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                HStack {
                    Text(phone)
                        .foregroundColor(.primary)
                    Spacer()
                    NavigationLink(destination: ProfilePhoneChangeView(currentPhone: $phone), isActive: $navigateToPhoneVerification) {
                        Button(action: { navigateToPhoneVerification = true }) {
                            Text("Telefonu Değiştir")
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    .buttonStyle(.plain)
                }
                HStack {
                    Button(action: {
                        showSaved = true
                    }) {
                        Text("Kaydet")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            Section {
                Button(action: {
                    showDeleteAccountAlert = true
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.minus")
                            .foregroundColor(.red)
                        Text("Hesabımı Sil")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Kişisel Bilgilerim")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEmailVerify) {
            VerificationSheet(title: "E-posta Doğrulama", onDismiss: { showEmailVerify = false })
        }
        .alert("Bilgiler kaydedildi", isPresented: $showSaved) {
            Button("Tamam", role: .cancel) {}
        }
        .alert("Hesabı Sil", isPresented: $showDeleteAccountAlert) {
            Button("İptal", role: .cancel) { }
            Button("Hesabı Sil", role: .destructive) {
                sessionManager.clearSession()
            }
        } message: {
            Text("Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.")
        }
    }
}

struct VerificationSheet: View {
    let title: String
    var onDismiss: () -> Void
    @State private var verificationCode: String = ""
    @State private var isLoading: Bool = false
    @State private var verificationStatusMessage: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(title)
                    .font(.title2)
                    .padding(.top)

                Text("Lütfen e-posta adresinize gönderilen 6 haneli doğrulama kodunu girin.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                TextField("Doğrulama Kodu", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                if let message = verificationStatusMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(message.contains("başarılı") ? .green : .red)
                }

                Button(action: {
                    isLoading = true
                    verificationStatusMessage = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                        if verificationCode == "123456" {
                            verificationStatusMessage = "E-posta başarıyla doğrulandı!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                onDismiss()
                                dismiss()
                            }
                        } else {
                            verificationStatusMessage = "Doğrulama kodu yanlış. Lütfen tekrar deneyin."
                        }
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Text("Doğrula")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .disabled(isLoading || verificationCode.count != 6)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CountryCode: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var code: String
    var flag: String
    var format: String
}

struct CountryPickerView: View {
    @Binding var selectedCountry: CountryCode
    let countries: [CountryCode]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(countries, id: \.self) { country in
                HStack {
                    Text(country.flag)
                    Text(country.name)
                    Spacer()
                    if country.code == selectedCountry.code {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCountry = country
                    dismiss()
                }
            }
            .navigationTitle("Ülke Seç")
            .navigationBarItems(trailing: Button("Kapat") {
                dismiss()
            })
        }
    }
}



struct ProfilePhoneChangeView: View {
    @Binding var currentPhone: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCountry = CountryCode(
        name: "Türkiye",
        code: "+90",
        flag: "🇹🇷",
        format: "### ### ## ##"
    )
    @State private var newPhone: String = ""
    @State private var code: String = ""
    @State private var codeSent: Bool = false
    @State private var verified: Bool = false
    @State private var showError: Bool = false
    @State private var showCountryPicker = false
    @FocusState private var isPhoneFieldFocused: Bool

    let countries = [
        CountryCode(name: "Türkiye", code: "+90", flag: "🇹🇷", format: "### ### ## ##"),
        CountryCode(name: "United States", code: "+1", flag: "🇺🇸", format: "(###) ###-####"),
        CountryCode(name: "United Kingdom", code: "+44", flag: "🇬🇧", format: "#### ######"),
        CountryCode(name: "Germany", code: "+49", flag: "🇩🇪", format: "#### ######"),
        CountryCode(name: "France", code: "+33", flag: "🇫🇷", format: "## ## ## ## ##")
    ]

    var body: some View {
        VStack(spacing: 32) {
            Text("Telefon Numarası Değiştir")
                .font(.title2).bold()
                .padding(.top, 32)
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    Button(action: { showCountryPicker = true }) {
                        HStack {
                            Text(selectedCountry.flag)
                            Text(selectedCountry.code)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 52)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showCountryPicker) {
                        CountryPickerView(selectedCountry: $selectedCountry, countries: countries)
                    }
                    TextField(selectedCountry.format, text: $newPhone)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 0)
                        .padding(.horizontal, 12)
                        .frame(height: 52)
                        .background(Color.clear)
                        .focused($isPhoneFieldFocused)
                        .onChange(of: newPhone) { _, newValue in
                            newPhone = formatPhoneNumber(newValue, format: selectedCountry.format)
                        }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.purple, lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)
            if codeSent {
                VStack(spacing: 16) {
                    Text("Telefonunuza gelen kodu girin")
                        .font(.subheadline)
                    TextField("Kod", text: $code)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    Button("Doğrula") {
                        if code == "1234" && !newPhone.isEmpty {
                            currentPhone = selectedCountry.code + " " + newPhone
                            verified = true
                            dismiss()
                        } else {
                            showError = true
                        }
                    }
                    .disabled(code.isEmpty)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.purple)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
            } else {
                Button("Kod Gönder") {
                    codeSent = true
                }
                .disabled(newPhone.filter { $0.isNumber }.count < 10)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(newPhone.filter { $0.isNumber }.count >= 10 ? Color.purple : Color.gray)
                .cornerRadius(12)
                .padding(.horizontal, 24)
            }
            Spacer()
        }
        .navigationTitle("Telefon Doğrulama")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Kod yanlış veya eksik!", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        }
    }

    private func formatPhoneNumber(_ number: String, format: String) -> String {
        let digits = number.filter { $0.isNumber }
        var result = ""
        var index = digits.startIndex
        for ch in format where index < digits.endIndex {
            if ch == "#" {
                result.append(digits[index])
                index = digits.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

#Preview {
    UserProfilePersonalInfoView()
}
