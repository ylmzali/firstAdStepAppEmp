import SwiftUI
import UserNotifications

struct AppFlowView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @State private var currentView: AppView = .splash
    @State private var showNotificationSheet = false
    
    enum AppView {
        case splash
        case auth
        case main
    }
    
    var body: some View {
        Group {
            switch currentView {
            case .splash:
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                if sessionManager.hasSession {
                                    currentView = .main
                                } else {
                                    currentView = .auth
                                }
                            }
                        }
                    }
            case .auth:
                AuthenticationFlowView()
            case .main:
                MainTabBar()
            }
        }
        .onAppear {
            checkNotificationPermission()
            if !sessionManager.hasSession {
                currentView = .auth
            }
        }
        .onChange(of: sessionManager.hasSession) { _, hasSession in
            print("Session changed: \(hasSession)")
            withAnimation {
                if hasSession {
                    currentView = .main
                } else {
                    currentView = .auth
                }
            }
        }
        .sheet(isPresented: $showNotificationSheet) {
            NotificationPermissionView(isPresented: $showNotificationSheet)
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    showNotificationSheet = true
                }
            }
        }
    }
}

struct NotificationPermissionView: View {
    @Binding var isPresented: Bool
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "bell.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Theme.yellow400)
            Text("Bildirimler Kapalı")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.navy400)
            Text("Uygulamanın tam verimli çalışabilmesi için bildirimlere izin vermeniz önerilir. Ayarlardan bildirimleri açabilirsiniz.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.gray600)
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Text("Devam Et")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            
        }
        .padding()
    }
}

#Preview {
    AppFlowView()
}
