import SwiftUI

struct InteractiveButtonStyle: ButtonStyle {
    let haptic: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppMotion.interactive, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed && haptic {
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
        .buttonStyle(InteractiveButtonStyle(haptic: haptic))
    }
}
