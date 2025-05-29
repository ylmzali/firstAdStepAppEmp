import SwiftUI

struct UserProfileView: View {
    @StateObject var viewModel = UserProfileViewViewModel()
    @StateObject private var sessionManager = SessionManager.shared
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let user = viewModel.user {
                        profile(user: user)
                    } else {
                        ProgressView()
                    }

                    List {
                        NavigationLink(destination: UserProfilePersonalInfoView()) {
                            Label("Kişisel Bilgilerim", systemImage: "person.fill")
                        }
                        NavigationLink(destination: UserProfileAddressView()) {
                            Label("Adreslerim", systemImage: "mappin.and.ellipse")
                        }
                        NavigationLink(destination: UserProfileOrderHistory()) {
                            Label("Sipariş Geçmişim", systemImage: "shippingbox.fill")
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: 150)
                    .scrollDisabled(true)

                    Spacer()
                    
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("Çıkış Yap")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Profilim")
            // .navigationBarTitleDisplayMode(.inline)
            .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
                Button("İptal", role: .cancel) { }
                Button("Çıkış Yap", role: .destructive) {
                    sessionManager.clearSession()
                }
            } message: {
                Text("Çıkış yapmak istediğinize emin misiniz?")
            }
        }
        .onAppear {
            viewModel.fetchUser()
        }
    }

    private func profile(user: User) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .background(Circle().fill(Color(.systemGray6)))
                .padding(4)
            Text(user.name ?? sessionManager.name ?? "")
                .font(.title2).bold()
            Text(user.phoneNumber ?? sessionManager.phoneNumber ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 32)
    }
}



#Preview {
    UserProfileView()
}
