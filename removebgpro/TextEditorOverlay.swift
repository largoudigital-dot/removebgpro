
import SwiftUI

enum TextEditorMode: String, CaseIterable, Identifiable {
    case keyboard, color, font, formatting
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .keyboard: return "keyboard"
        case .color: return "circle.fill"
        case .font: return "textformat"
        case .formatting: return "text.alignleft"
        }
    }
}

struct TextEditorOverlay: View {
    @Binding var textItem: TextItem
    let onDone: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentMode: TextEditorMode = .keyboard
    
    var body: some View {
        ZStack {
            // Transparent background to show image below
            Color.black.opacity(0.4)
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    onDone()
                }
            
            VStack(spacing: 0) {
                // Top Toolbar
                HStack(spacing: 30) {
                    InteractiveButton(action: { onCancel() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        ForEach(TextEditorMode.allCases) { mode in
                            InteractiveButton(action: {
                                AppHaptics.light()
                                withAnimation(AppMotion.snappy) {
                                    currentMode = mode
                                    isTextFieldFocused = (mode == .keyboard)
                                }
                            }) {
                                if mode == .color {
                                    Circle()
                                        .fill(AngularGradient(colors: [.red, .yellow, .green, .blue, .purple, .red], center: .center))
                                        .frame(width: 24, height: 24)
                                        .overlay(Circle().stroke(Color.white, lineWidth: currentMode == .color ? 2 : 0))
                                } else {
                                    Image(systemName: mode.iconName)
                                        .font(.system(size: 22, weight: currentMode == mode ? .bold : .medium))
                                        .foregroundColor(currentMode == mode ? .white : .white.opacity(0.6))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    InteractiveButton(action: { onDone() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Text Input Area
                TextField("", text: $textItem.text, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .font(.custom(textItem.fontName, size: 28 + textItem.scale * 10)) // Scale preview font size
                    .fontWeight(textItem.isBold ? .bold : .regular)
                    .italic(textItem.isItalic)
                    .underline(textItem.isUnderlined)
                    .kerning(textItem.kerning)
                    .lineSpacing(textItem.lineSpacing)
                    .foregroundColor(textItem.color)
                    .multilineTextAlignment(mapAlignment(textItem.alignment))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if textItem.backgroundStyle != .none {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(textItem.backgroundColor.opacity(textItem.backgroundStyle == .solid ? 1.0 : 0.6))
                            }
                        }
                    )
                    .tint(textItem.color)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom Panels
                if currentMode != .keyboard {
                    VStack {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 4)
                            .padding(.top, 10)
                        
                        panelContent
                            .padding(.bottom, 40)
                    }
                    .background(
                        Color(white: 0.15)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    @ViewBuilder
    private var panelContent: some View {
        switch currentMode {
        case .keyboard:
            EmptyView()
        case .color:
            colorPanel
        case .font:
            fontPanel
        case .formatting:
            formattingPanel
        }
    }
    
    private var colorPanel: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Text Farbe")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                InteractiveButton(action: { toggleBackground() }) {
                    HStack {
                        Image(systemName: textItem.backgroundStyle.iconName)
                        Text(textItem.backgroundStyle == .none ? "Hintergrund An" : "Hintergrund Aus")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(textItem.backgroundStyle != .none ? .black : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(textItem.backgroundStyle != .none ? Color.white : Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TextEditorStyles.colors, id: \.self) { color in
                        InteractiveButton(action: {
                            AppHaptics.light()
                            withAnimation(AppMotion.bouncy) {
                                if textItem.backgroundStyle != .none {
                                    textItem.backgroundColor = color
                                    textItem.color = shouldShowBlackText(on: color) ? .black : .white
                                } else {
                                    textItem.color = color
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: (textItem.backgroundStyle != .none ? textItem.backgroundColor : textItem.color) == color ? 3 : 0)
                                    )
                                    .scaleEffect((textItem.backgroundStyle != .none ? textItem.backgroundColor : textItem.color) == color ? 1.1 : 1.0)
                            }
                        }
                    }
                    
                    ColorPicker("", selection: Binding(
                        get: { textItem.backgroundStyle != .none ? textItem.backgroundColor : textItem.color },
                        set: { newColor in
                            if textItem.backgroundStyle != .none {
                                textItem.backgroundColor = newColor
                                textItem.color = shouldShowBlackText(on: newColor) ? .black : .white
                            } else {
                                textItem.color = newColor
                            }
                        }
                    ))
                    .labelsHidden()
                    .scaleEffect(1.3)
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 10)
    }
    
    private var fontPanel: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Schriftart")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 14, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(TextEditorStyles.fonts) { font in
                        InteractiveButton(action: {
                            AppHaptics.light()
                            withAnimation(AppMotion.snappy) {
                                textItem.fontName = font.name
                            }
                        }) {
                            VStack {
                                Text(font.displayName)
                                    .font(.custom(font.name, size: 18))
                                    .foregroundColor(textItem.fontName == font.name ? .black : .white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(textItem.fontName == font.name ? Color.white : Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 10)
    }
    
    private var formattingPanel: some View {
        VStack(spacing: 25) {
            // Sliders
            VStack(spacing: 15) {
                formattingSlider(icon: "textformat.size", value: $textItem.scale, range: 0.5...3.0, label: "Größe")
                formattingSlider(icon: "line.horizontal.3", value: $textItem.lineSpacing, range: -10...30, label: "Abstand")
                formattingSlider(icon: "arrow.left.and.right", value: $textItem.kerning, range: -2...15, label: "Kerning")
            }
            .padding(.horizontal, 24)
            
            // Buttons
            HStack(spacing: 20) {
                InteractiveButton(action: { 
                    AppHaptics.light()
                    toggleAlignment() 
                }) {
                    Image(systemName: textItem.alignment.iconName)
                        .font(.system(size: 20))
                }
                
                Divider().frame(height: 20).background(Color.white.opacity(0.3))
                
                Group {
                    formatToggle(icon: "bold", isActive: textItem.isBold) { textItem.isBold.toggle() }
                    formatToggle(icon: "italic", isActive: textItem.isItalic) { textItem.isItalic.toggle() }
                    formatToggle(icon: "underline", isActive: textItem.isUnderlined) { textItem.isUnderlined.toggle() }
                    formatToggle(icon: "textformat.abc.capslock", isActive: textItem.isAllCaps) { textItem.isAllCaps.toggle() }
                }
                
                Divider().frame(height: 20).background(Color.white.opacity(0.3))
                
                InteractiveButton(action: { AppHaptics.light() }) {
                    Image(systemName: "skew")
                        .font(.system(size: 20))
                        .opacity(0.5) // Placeholder for curve
                }
                .overlay(Text(">").font(.caption2).offset(x: 15))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
        }
        .padding(.top, 10)
    }
    
    private func formattingSlider(icon: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, label: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 24)
            
            Slider(value: value, in: range)
                .accentColor(.white)
            
            Text(String(format: "%.1f", value.wrappedValue))
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 30)
        }
    }
    
    private func formatToggle(icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        InteractiveButton(action: {
            AppHaptics.light()
            withAnimation(.snappy) { action() }
        }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? .white : .white.opacity(0.4))
                .frame(width: 32, height: 32)
                .background(isActive ? Color.white.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func toggleAlignment() {
        let cases = TextAlignment.allCases
        if let index = cases.firstIndex(of: textItem.alignment) {
            let nextIndex = (index + 1) % cases.count
            textItem.alignment = cases[nextIndex]
        }
    }
    
    private func toggleBackground() {
        let cases = TextBackgroundStyle.allCases
        if let index = cases.firstIndex(of: textItem.backgroundStyle) {
            let nextIndex = (index + 1) % cases.count
            textItem.backgroundStyle = cases[nextIndex]
            if textItem.backgroundStyle != .none {
                textItem.color = shouldShowBlackText(on: textItem.backgroundColor) ? .black : .white
            }
        }
    }
    
    private func shouldShowBlackText(on color: Color) -> Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.6
    }
    
    private func mapAlignment(_ alignment: TextAlignment) -> SwiftUI.TextAlignment {
        switch alignment {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
