import SwiftUI

// Card styling extensions and modifiers

// MARK: - Card Header Modifier
struct CardHeaderStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cardHeader(color: Color) -> some View {
        self.modifier(CardHeaderStyle(color: color))
    }
}

// MARK: - Card Style Modifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}

// MARK: - Rounded Corners
struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}