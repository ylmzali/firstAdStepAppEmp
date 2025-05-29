import SwiftUI

struct ReBrickInputStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Theme.gray300.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.purple400, lineWidth: 1)
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Theme.navy400)
            .lineSpacing(2)
    }
}

struct ReBrickTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Theme.navy400)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ReBrickButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? Theme.purple400 : Theme.gray300)
            .cornerRadius(12)
    }
}

extension View {
    func reBrickInputStyle() -> some View {
        self.textFieldStyle(ReBrickInputStyle())
    }
    
    func reBrickTitleStyle() -> some View {
        self.modifier(ReBrickTitleStyle())
    }
    
    func reBrickButtonStyle(isEnabled: Bool = true) -> some View {
        self.modifier(ReBrickButtonStyle(isEnabled: isEnabled))
    }
} 
