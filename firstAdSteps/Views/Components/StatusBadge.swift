import SwiftUI

struct StatusBadge: View {
    let status: RouteStatus
    
    private var statusColor: Color {
        switch status {
        case .active:
            return AntColors.primary
        case .completed:
            return AntColors.success
        case .cancelled:
            return AntColors.error
        }
    }
    
    private var statusText: String {
        switch status {
        case .active:
            return "Aktif"
        case .completed:
            return "Tamamlandı"
        case .cancelled:
            return "İptal Edildi"
        }
    }
    
    var body: some View {
        Text(statusText)
            .font(.system(size: AntTypography.caption))
            .foregroundColor(.white)
            .padding(.horizontal, AntSpacing.sm)
            .padding(.vertical, AntSpacing.xs)
            .background(statusColor)
            .cornerRadius(AntCornerRadius.sm)
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusBadge(status: .active)
        StatusBadge(status: .completed)
        StatusBadge(status: .cancelled)
    }
    .padding()
} 
