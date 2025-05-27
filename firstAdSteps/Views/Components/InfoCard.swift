import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.xs) {
            Label(title, systemImage: icon)
                .font(.system(size: AntTypography.caption))
                .foregroundColor(AntColors.secondaryText)
            
            Text(value)
                .font(.system(size: AntTypography.paragraph))
                .foregroundColor(AntColors.text)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AntSpacing.md)
        .background(AntColors.background)
        .cornerRadius(AntCornerRadius.md)
    }
} 
