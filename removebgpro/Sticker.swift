
import Foundation
import SwiftUI
import Combine

enum StickerType: Equatable {
    case emoji
    case systemImage
    case imageAsset // New type for local assets
}

struct Sticker: Identifiable, Equatable {
    let id: UUID
    let content: String
    var type: StickerType
    var position: CGPoint
    var scale: CGFloat
    var rotation: Angle
    var color: Color // New: For system images
    
    init(id: UUID = UUID(), content: String, type: StickerType = .emoji, position: CGPoint = CGPoint(x: 0.5, y: 0.5), scale: CGFloat = 1.0, rotation: Angle = .zero, color: Color = .white) {
        self.id = id
        self.content = content
        self.type = type
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.color = color
    }
}
