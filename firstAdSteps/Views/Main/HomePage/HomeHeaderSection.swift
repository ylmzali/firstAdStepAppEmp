import SwiftUI

struct HomeHeaderSection: View {
    var userName: String = "Ali Yılmaz" // Örnek kullanıcı adı
    @State private var showNotifications: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Logo veya uygulama adı
                HStack(spacing: 8) {
                    Image(systemName: "megaphone.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.blue)
                    Text("AdSteps")
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                }
                Spacer()
                // Bildirim/mesaj ikonu
                NavigationLink(destination: NotificationsAlertsView()) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
                // Kullanıcı profil ikonu
                Button(action: {
                    // Profil sayfasına git
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
            if showNotifications {
                NotificationsAlertsView()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    HomeHeaderSection()
} 
