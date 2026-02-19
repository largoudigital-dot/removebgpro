
import Foundation
import SwiftUI
import Combine

enum StickerType: String, Codable, Equatable {
    case emoji
    case systemImage
    case imageAsset // New type for local assets
    case giphy
}

struct Sticker: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    var type: StickerType
    var codablePosition: CodablePoint
    var scale: CGFloat
    var rotationDegrees: Double
    var colorHex: String?
    
    var position: CGPoint {
        get { codablePosition.cgPoint }
        set { codablePosition = CodablePoint(newValue) }
    }
    
    var rotation: Angle {
        get { .degrees(rotationDegrees) }
        set { rotationDegrees = newValue.degrees }
    }
    
    var color: Color {
        get { colorHex.map { Color(hex: $0) } ?? .white }
        set { colorHex = newValue.hex }
    }
    
    init(id: UUID = UUID(), content: String, type: StickerType = .emoji, position: CGPoint = CGPoint(x: 0.5, y: 0.5), scale: CGFloat = 1.0, rotation: Angle = .zero, color: Color = .white) {
        self.id = id
        self.content = content
        self.type = type
        self.codablePosition = CodablePoint(position)
        self.scale = scale
        self.rotationDegrees = rotation.degrees
        self.colorHex = color.hex
    }
    
    enum CodingKeys: String, CodingKey {
        case id, content, type, codablePosition, scale, rotationDegrees, colorHex
    }
}
