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
}

// MARK: - Scroll Discovery Utilities
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
