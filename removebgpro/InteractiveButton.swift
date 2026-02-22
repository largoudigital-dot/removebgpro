import SwiftUI

struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.8, blendDuration: 0), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    AppHaptics.light()
                }
            }
    }
}

struct InteractiveButton<Content: View>: View {
    let action: () -> Void
    let haptic: Bool
    let content: Content
    
    init(haptic: Bool = true, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.haptic = haptic
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            content
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}
