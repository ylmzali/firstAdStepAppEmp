import SwiftUI

struct HomeHeaderSection: View {
    var userName: String = "Ali Yılmaz"
    var userEMail: String = "ali.yilmaz@itptech.de"
    @State private var showProfile: Bool = false

    @EnvironmentObject private var userViewModel: UserProfileViewViewModel

    var body: some View {
        ZStack(alignment: .top) {
            // Arka plan (gradient/lila, köşeleri yumuşak)
            
            Image("bazaar_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 310) // Yüksekliği ihtiyacına göre ayarla
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                        // Color.black.opacity(0.5) // Koyulaştırmak için siyah overlay ve opacity
                    )
            

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if let user = userViewModel.user {
                        
                        NavigationLink(destination: UserProfileView(), isActive: $showProfile) {
                            EmptyView()
                        }
                        Button(action: { showProfile = true }) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(user.name)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(user.email)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(8)
                            .padding(.trailing)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.black.opacity(1), Color.black.opacity(0)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        
                                    )
                                    .stroke(.orange.opacity(0.4), lineWidth: 1)
                                
                            )
                        }

                    } else {
                        ProgressView()
                            .padding()
                            .tint(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        
                                    )
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                                
                            )
                    }
                    

                    Spacer()
                    NavigationLink(destination: NotificationsAlertsView()) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading) {
                    HStack {
                        /*
                        Image(systemName: "play.circle")
                            .font(.system(size: 42))
                            .foregroundColor(.white)
                         */
                        Text("Yürüyen\ndijital reklam!")
                            .lineSpacing(0)
                            .font(.system(size: 36))
                            .bold()
                            .foregroundColor(.white)
                    }
                    /*
                    HStack {
                        Text("Gas terus..")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                        Spacer()
                    }
                     */
                }
                .padding(.top, 50)
            }
            .padding()
            .padding(.top, 50)
            .padding(.bottom, 20)
            /*
            .background(
                Color
                    .blue
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
             */
        }
        .onAppear {
            userViewModel.fetchUser()
        }
    }
}

#Preview {
    HomeHeaderSection()
        .environmentObject(UserProfileViewViewModel())
}
