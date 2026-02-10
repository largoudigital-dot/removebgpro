import SwiftUI
import Foundation

enum TextAlignment: String, Codable, CaseIterable, Identifiable {
    case left, center, right
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .left: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .right: return "text.alignright"
        }
    }
}

enum TextBackgroundStyle: String, Codable, CaseIterable, Identifiable {
    case none, solid, semiTransparent
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .none: return "textformat"
        case .solid: return "a.square.fill"
        case .semiTransparent: return "a.square"
        }
    }
}

struct TextItem: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var fontName: String
    var colorHex: String
    var backgroundColorHex: String
    var backgroundStyle: TextBackgroundStyle
    var alignment: TextAlignment
    var codablePosition: CodablePoint // Normalized 0-1
    var scale: CGFloat
    var rotationDegrees: Double
    
    // Formatting Properties (New)
    var lineSpacing: CGFloat
    var kerning: CGFloat
    var isBold: Bool
    var isItalic: Bool
    var isUnderlined: Bool
    var isAllCaps: Bool
    
    var position: CGPoint {
        get { codablePosition.cgPoint }
        set { codablePosition = CodablePoint(newValue) }
    }
    
    // Non-stored properties or properties with custom logic
    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.hex ?? "#FFFFFF" }
    }
    
    var backgroundColor: Color {
        get { Color(hex: backgroundColorHex) }
        set { backgroundColorHex = newValue.hex ?? "#000000" }
    }
    
    var rotation: Angle {
        get { .degrees(rotationDegrees) }
        set { rotationDegrees = newValue.degrees }
    }
    
    init(
        id: UUID = UUID(),
        text: String = "",
        fontName: String = "Inter-Bold",
        color: Color = .white,
        backgroundColor: Color = .black,
        backgroundStyle: TextBackgroundStyle = .none,
        alignment: TextAlignment = .center,
        position: CGPoint = CGPoint(x: 0.5, y: 0.5),
        scale: CGFloat = 1.0,
        rotation: Angle = .zero,
        lineSpacing: CGFloat = 0,
        kerning: CGFloat = 0,
        isBold: Bool = false,
        isItalic: Bool = false,
        isUnderlined: Bool = false,
        isAllCaps: Bool = false
    ) {
        self.id = id
        self.text = text
        self.fontName = fontName
        self.colorHex = color.hex ?? "#FFFFFF"
        self.backgroundColorHex = backgroundColor.hex ?? "#000000"
        self.backgroundStyle = backgroundStyle
        self.alignment = alignment
        self.codablePosition = CodablePoint(position)
        self.scale = scale
        self.rotationDegrees = rotation.degrees
        self.lineSpacing = lineSpacing
        self.kerning = kerning
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
        self.isAllCaps = isAllCaps
    }
    
    enum CodingKeys: String, CodingKey {
        case id, text, fontName, colorHex, backgroundColorHex, backgroundStyle, alignment, codablePosition, scale, rotationDegrees
        case lineSpacing, kerning, isBold, isItalic, isUnderlined, isAllCaps
    }
}
