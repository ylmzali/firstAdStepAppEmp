import SwiftUI

struct MapButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
        .font(.system(size: AntTypography.caption))
    }
} 
