import SwiftUI
import Foundation

struct CodableEditorState: Codable {
    var selectedFilter: FilterType
    var brightness: Double
    var contrast: Double
    var saturation: Double
    var blur: Double
    var rotation: CGFloat
    var selectedAspectRatio: AspectRatio
    var customWidth: CGFloat?
    var customHeight: CGFloat?
    var backgroundColorHex: String?
    var gradientColorsHex: [String]?
    var backgroundImageName: String?
    var foregroundImageName: String? // ADDED: For immediate resumption without re-processing
    var appliedCropRect: CodableRect?
    var stickers: [Sticker]
    var textItems: [TextItem]
    var shadowRadius: CGFloat
    var shadowX: CGFloat
    var shadowY: CGFloat
    var shadowColorHex: String
    var shadowOpacity: Double
    
    // ADDED: UI Transformation State
    var fgScale: CGFloat
    var fgOffset: CodablePoint
    var bgScale: CGFloat
    var bgOffset: CodablePoint
    var canvasScale: CGFloat
    var canvasOffset: CodablePoint
    var version: Int
    var stickerOutlineWidth: CGFloat
    var stickerOutlineColorHex: String?
    var stickerSize: CGFloat // ADDED
    
    enum CodingKeys: String, CodingKey {
        case selectedFilter, brightness, contrast, saturation, blur, rotation
        case selectedAspectRatio, customWidth, customHeight, backgroundColorHex, gradientColorsHex
        case backgroundImageName, foregroundImageName, appliedCropRect, stickers, textItems
        case shadowRadius, shadowX, shadowY, shadowColorHex, shadowOpacity
        case fgScale, fgOffset, bgScale, bgOffset, canvasScale, canvasOffset, version
        case stickerOutlineWidth, stickerOutlineColorHex, stickerSize // ADDED
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedFilter = try container.decode(FilterType.self, forKey: .selectedFilter)
        self.brightness = try container.decode(Double.self, forKey: .brightness)
        self.contrast = try container.decode(Double.self, forKey: .contrast)
        self.saturation = try container.decode(Double.self, forKey: .saturation)
        self.blur = try container.decode(Double.self, forKey: .blur)
        self.rotation = try container.decode(CGFloat.self, forKey: .rotation)
        self.selectedAspectRatio = try container.decode(AspectRatio.self, forKey: .selectedAspectRatio)
        self.customWidth = try container.decodeIfPresent(CGFloat.self, forKey: .customWidth)
        self.customHeight = try container.decodeIfPresent(CGFloat.self, forKey: .customHeight)
        self.backgroundColorHex = try container.decodeIfPresent(String.self, forKey: .backgroundColorHex)
        self.gradientColorsHex = try container.decodeIfPresent([String].self, forKey: .gradientColorsHex)
        self.backgroundImageName = try container.decodeIfPresent(String.self, forKey: .backgroundImageName)
        self.foregroundImageName = try container.decodeIfPresent(String.self, forKey: .foregroundImageName)
        self.appliedCropRect = try container.decodeIfPresent(CodableRect.self, forKey: .appliedCropRect)
        self.stickers = try container.decode([Sticker].self, forKey: .stickers)
        self.textItems = try container.decode([TextItem].self, forKey: .textItems)
        self.shadowRadius = try container.decode(CGFloat.self, forKey: .shadowRadius)
        self.shadowX = try container.decode(CGFloat.self, forKey: .shadowX)
        self.shadowY = try container.decode(CGFloat.self, forKey: .shadowY)
        self.shadowColorHex = try container.decode(String.self, forKey: .shadowColorHex)
        self.shadowOpacity = try container.decode(Double.self, forKey: .shadowOpacity)
        
        // Backward compatibility for transformation state
        self.fgScale = try container.decodeIfPresent(CGFloat.self, forKey: .fgScale) ?? 1.0
        self.fgOffset = try container.decodeIfPresent(CodablePoint.self, forKey: .fgOffset) ?? CodablePoint(.zero)
        self.bgScale = try container.decodeIfPresent(CGFloat.self, forKey: .bgScale) ?? 1.0
        self.bgOffset = try container.decodeIfPresent(CodablePoint.self, forKey: .bgOffset) ?? CodablePoint(.zero)
        self.canvasScale = try container.decodeIfPresent(CGFloat.self, forKey: .canvasScale) ?? 1.0
        self.canvasOffset = try container.decodeIfPresent(CodablePoint.self, forKey: .canvasOffset) ?? CodablePoint(.zero)
        self.version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 0
        self.stickerOutlineWidth = try container.decodeIfPresent(CGFloat.self, forKey: .stickerOutlineWidth) ?? 0
        self.stickerOutlineColorHex = try container.decodeIfPresent(String.self, forKey: .stickerOutlineColorHex)
        self.stickerSize = try container.decodeIfPresent(CGFloat.self, forKey: .stickerSize) ?? 512 // Default
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedFilter, forKey: .selectedFilter)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(contrast, forKey: .contrast)
        try container.encode(saturation, forKey: .saturation)
        try container.encode(blur, forKey: .blur)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(selectedAspectRatio, forKey: .selectedAspectRatio)
        try container.encodeIfPresent(customWidth, forKey: .customWidth)
        try container.encodeIfPresent(customHeight, forKey: .customHeight)
        try container.encodeIfPresent(backgroundColorHex, forKey: .backgroundColorHex)
        try container.encodeIfPresent(gradientColorsHex, forKey: .gradientColorsHex)
        try container.encodeIfPresent(backgroundImageName, forKey: .backgroundImageName)
        try container.encodeIfPresent(foregroundImageName, forKey: .foregroundImageName)
        try container.encodeIfPresent(appliedCropRect, forKey: .appliedCropRect)
        try container.encode(stickers, forKey: .stickers)
        try container.encode(textItems, forKey: .textItems)
        try container.encode(shadowRadius, forKey: .shadowRadius)
        try container.encode(shadowX, forKey: .shadowX)
        try container.encode(shadowY, forKey: .shadowY)
        try container.encode(shadowColorHex, forKey: .shadowColorHex)
        try container.encode(shadowOpacity, forKey: .shadowOpacity)
        
        try container.encode(fgScale, forKey: .fgScale)
        try container.encode(fgOffset, forKey: .fgOffset)
        try container.encode(bgScale, forKey: .bgScale)
        try container.encode(bgOffset, forKey: .bgOffset)
        try container.encode(canvasScale, forKey: .canvasScale)
        try container.encode(canvasOffset, forKey: .canvasOffset)
        try container.encode(version, forKey: .version)
        try container.encode(stickerOutlineWidth, forKey: .stickerOutlineWidth)
        try container.encodeIfPresent(stickerOutlineColorHex, forKey: .stickerOutlineColorHex)
        try container.encode(stickerSize, forKey: .stickerSize)
    }
    
    // Initializer used during saving
    init(
        selectedFilter: FilterType,
        brightness: Double,
        contrast: Double,
        saturation: Double,
        blur: Double,
        rotation: CGFloat,
        selectedAspectRatio: AspectRatio,
        customWidth: CGFloat?,
        customHeight: CGFloat?,
        backgroundColorHex: String?,
        gradientColorsHex: [String]?,
        backgroundImageName: String?,
        foregroundImageName: String?,
        appliedCropRect: CodableRect?,
        stickers: [Sticker],
        textItems: [TextItem],
        shadowRadius: CGFloat,
        shadowX: CGFloat,
        shadowY: CGFloat,
        shadowColorHex: String,
        shadowOpacity: Double,
        fgScale: CGFloat,
        fgOffset: CodablePoint,
        bgScale: CGFloat,
        bgOffset: CodablePoint,
        canvasScale: CGFloat,
        canvasOffset: CodablePoint,
        version: Int,
        stickerOutlineWidth: CGFloat,
        stickerOutlineColorHex: String?,
        stickerSize: CGFloat // ADDED
    ) {
        self.selectedFilter = selectedFilter
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.blur = blur
        self.rotation = rotation
        self.selectedAspectRatio = selectedAspectRatio
        self.customWidth = customWidth
        self.customHeight = customHeight
        self.backgroundColorHex = backgroundColorHex
        self.gradientColorsHex = gradientColorsHex
        self.backgroundImageName = backgroundImageName
        self.foregroundImageName = foregroundImageName
        self.appliedCropRect = appliedCropRect
        self.stickers = stickers
        self.textItems = textItems
        self.shadowRadius = shadowRadius
        self.shadowX = shadowX
        self.shadowY = shadowY
        self.shadowColorHex = shadowColorHex
        self.shadowOpacity = shadowOpacity
        self.fgScale = fgScale
        self.fgOffset = fgOffset
        self.bgScale = bgScale
        self.bgOffset = bgOffset
        self.canvasScale = canvasScale
        self.canvasOffset = canvasOffset
        self.version = version
        self.stickerOutlineWidth = stickerOutlineWidth
        self.stickerOutlineColorHex = stickerOutlineColorHex
        self.stickerSize = stickerSize
    }
}

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var thumbnailData: Data?
    var originalImageName: String? // Name of the file in Documents directory
    var state: CodableEditorState?
    
    var thumbnail: UIImage? {
        if let data = thumbnailData {
            return UIImage(data: data)
        }
        return nil
    }
    
    init(id: UUID = UUID(), date: Date = Date(), thumbnail: UIImage? = nil, originalImageName: String? = nil, state: CodableEditorState? = nil) {
        self.id = id
        self.date = date
        self.thumbnailData = thumbnail?.jpegData(compressionQuality: 0.5)
        self.originalImageName = originalImageName
        self.state = state
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id && lhs.date == rhs.date
    }
}
