//
//  Utilities.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI

// MARK: - Design System Utilities

struct AppHaptics {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

struct AppMotion {
    static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
    static let interactive = Animation.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    static let subtle = Animation.easeInOut(duration: 0.25)
}

// Legacy compatibility
func hapticFeedback() {
    AppHaptics.selection()
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var hex: String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        
        if a == 1.0 {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(r * 255)),
                          lroundf(Float(g * 255)),
                          lroundf(Float(b * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(a * 255)),
                          lroundf(Float(r * 255)),
                          lroundf(Float(g * 255)),
                          lroundf(Float(b * 255)))
        }
    }
}

// MARK: - Scroll Discovery Utilities
// MARK: - Codable Basic Types Wrappers
struct CodablePoint: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
}

struct CodableRect: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    
    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
    
    init(_ rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.width
        self.height = rect.height
    }
}

struct CodableSize: Codable, Equatable {
    var width: CGFloat
    var height: CGFloat
    
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
    
    init(_ size: CGSize) {
        self.width = size.width
        self.height = size.height
    }
}

extension View {
    func fadedEdge(leading: Bool = true, trailing: Bool = true) -> some View {
        self.mask(
            HStack(spacing: 0) {
                if leading {
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 24)
                }
                
                Color.black
                
                if trailing {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 24)
                }
            }
        )
    }
    
    func scrollDiscoveryNudge() -> some View {
        self.modifier(OnAppearNudge())
    }
}

struct OnAppearNudge: ViewModifier {
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onAppear {
                // Subtle 'peek' animation
                withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6).delay(0.5)) {
                    offset = -20
                }
                withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6).delay(0.9)) {
                    offset = 0
                }
            }
    }
}
// MARK: - Sharing Utilities
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - System Color Picker Wrapper
struct SystemColorPicker: UIViewControllerRepresentable {
    @Binding var color: Color
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.delegate = context.coordinator
        picker.selectedColor = UIColor(color)
        picker.supportsAlpha = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        // No-op: We don't want to override the picker's state from outside while it's open
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: SystemColorPicker
        
        init(_ parent: SystemColorPicker) {
            self.parent = parent
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            parent.color = Color(viewController.selectedColor)
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            // Dismissal handled by system
        }
    }
}

// MARK: - Custom Spectrum Color Picker
struct SpectrumColorPickerView: View {
    @Binding var color: Color
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hue: Double = 0.0
    @State private var saturation: Double = 1.0
    @State private var brightness: Double = 1.0
    
    init(color: Binding<Color>) {
        self._color = color
        // Initialize HSB from the binding color
        if let components = UIColor(color.wrappedValue).hsba {
            _hue = State(initialValue: components.hue)
            _saturation = State(initialValue: components.saturation)
            _brightness = State(initialValue: components.brightness)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Farbe wählen")
                    .font(.headline)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Hue & Saturation Spectrum
            GeometryReader { geometry in
                ZStack {
                    // Spectrum Gradient (Hue)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 0, saturation: 1, brightness: 1),
                            Color(hue: 0.1, saturation: 1, brightness: 1),
                            Color(hue: 0.2, saturation: 1, brightness: 1),
                            Color(hue: 0.3, saturation: 1, brightness: 1),
                            Color(hue: 0.4, saturation: 1, brightness: 1),
                            Color(hue: 0.5, saturation: 1, brightness: 1),
                            Color(hue: 0.6, saturation: 1, brightness: 1),
                            Color(hue: 0.7, saturation: 1, brightness: 1),
                            Color(hue: 0.8, saturation: 1, brightness: 1),
                            Color(hue: 0.9, saturation: 1, brightness: 1),
                            Color(hue: 1, saturation: 1, brightness: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Saturation Gradient (White to Transparent)
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .white.opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Thumb
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .shadow(radius: 1)
                        .frame(width: 20, height: 20)
                        .position(
                            x: CGFloat(hue) * geometry.size.width,
                            y: CGFloat(saturation) * geometry.size.height
                        )
                }
                .cornerRadius(12)
                .drawingGroup()
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateColor(at: value.location, in: geometry.size)
                        }
                )
            }
            .frame(height: 200)
            .padding(.horizontal)
            
            // Brightness Slider
            HStack {
                Image(systemName: "sun.min.fill").foregroundColor(.gray)
                Slider(value: $brightness, in: 0...1)
                    .accentColor(color)
                    .onChange(of: brightness) { _ in
                        updateColorOutput()
                    }
                Image(systemName: "sun.max.fill").foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func updateColor(at location: CGPoint, in size: CGSize) {
        let x = min(max(location.x, 0), size.width)
        let y = min(max(location.y, 0), size.height)
        
        hue = Double(x / size.width)
        saturation = Double(y / size.height)
        
        updateColorOutput()
    }
    
    private func updateColorOutput() {
        color = Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

extension UIColor {
    var hsba: (hue: Double, saturation: Double, brightness: Double, alpha: Double)? {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return (Double(h), Double(s), Double(b), Double(a))
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIApplication {
    static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
