import SwiftUI

struct MainPageOrderStatusSection: View {
    @State private var showTracking = false
    
    var body: some View {
        VStack(spacing: 16) {
            OrderStatusPreparingCard {
                showTracking = true
            }
            OrderStatusShippedCard {
                showTracking = true
            }
            OrderStatusLast5DaysCard {
                showTracking = true
            }
        }
        .sheet(isPresented: $showTracking) {
            OrderTrackingPage()
        }
    }
}

#Preview {
    MainPageOrderStatusSection()
} 
