//
//  EditorViewModel.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI
import Photos
import Combine

enum SaveStatus {
    case idle
    case saving
    case saved
}

struct EditorState: Equatable {
    var selectedFilter: FilterType
    var brightness: Double
    var contrast: Double
    var saturation: Double
    var blur: Double
    var rotation: CGFloat
    var selectedAspectRatio: AspectRatio
    var customSize: CGSize?
    var backgroundColor: Color?
    var gradientColors: [Color]?
    var backgroundImage: UIImage?
    var cropRect: CGRect? // Normalized applied crop
    var stickers: [Sticker]
    var textItems: [TextItem]
    var shadowRadius: CGFloat
    var shadowX: CGFloat
    var shadowY: CGFloat
    var shadowColor: Color
    var shadowOpacity: Double
    
    // ADDED: UI Transformation State
    var fgScale: CGFloat
    var fgOffset: CGSize
    var bgScale: CGFloat
    var bgOffset: CGSize
    var canvasScale: CGFloat
    var canvasOffset: CGSize
    
    static func == (lhs: EditorState, rhs: EditorState) -> Bool {
        return lhs.selectedFilter == rhs.selectedFilter &&
            lhs.brightness == rhs.brightness &&
            lhs.contrast == rhs.contrast &&
            lhs.saturation == rhs.saturation &&
            lhs.blur == rhs.blur &&
            lhs.rotation == rhs.rotation &&
            lhs.selectedAspectRatio == rhs.selectedAspectRatio &&
            lhs.customSize == rhs.customSize &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.gradientColors == rhs.gradientColors &&
            lhs.backgroundImage === rhs.backgroundImage &&
            lhs.cropRect == rhs.cropRect &&
            lhs.stickers == rhs.stickers &&
            lhs.textItems == rhs.textItems &&
            lhs.shadowRadius == rhs.shadowRadius &&
            lhs.shadowX == rhs.shadowX &&
            lhs.shadowY == rhs.shadowY &&
            lhs.shadowColor == rhs.shadowColor &&
            lhs.shadowOpacity == rhs.shadowOpacity &&
            lhs.fgScale == rhs.fgScale &&
            lhs.fgOffset == rhs.fgOffset &&
            lhs.bgScale == rhs.bgScale &&
            lhs.bgOffset == rhs.bgOffset &&
            lhs.canvasScale == rhs.canvasScale &&
            lhs.canvasOffset == rhs.canvasOffset
    }
}

enum ImageFormat {
    case png
    case jpg
}

class EditorViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAutoSave()
    }
    
    @Published var originalImage: UIImage?
    @Published var foregroundImage: UIImage? // The image with background removed
    @Published var backgroundImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var fullProcessedImage: UIImage? // The image with all adjustments but NO CROP
    
    @Published var selectedFilter: FilterType = .none
    // ... rest of properties
    @Published var brightness: Double = 1.0
    @Published var contrast: Double = 1.0
    @Published var saturation: Double = 1.0
    @Published var blur: Double = 0.0
    @Published var rotation: CGFloat = 0.0
    @Published var isRemovingBackground = false
    @Published var selectedAspectRatio: AspectRatio = .original
    @Published var customSize: CGSize? = nil
    @Published var backgroundColor: Color? = nil
    @Published var gradientColors: [Color]? = nil
    
    // Crop State
    @Published var isCropping = false
    @Published var appliedCropRect: CGRect? = nil
    
    // Sticker State
    @Published var stickers: [Sticker] = []
    @Published var selectedStickerId: UUID? = nil
    @Published var showingEmojiPicker = false
    
    // Text State
    @Published var textItems: [TextItem] = []
    @Published var selectedTextId: UUID? = nil
    @Published var showingTextEditor = false
    
    // Shadow State
    @Published var shadowRadius: CGFloat = 0
    @Published var shadowX: CGFloat = 0
    @Published var shadowY: CGFloat = 0
    @Published var shadowColor: Color = .black
    @Published var shadowOpacity: Double = 0.3
    
    // ADDED: UI Transformation State (Moved from ZoomableImageView)
    @Published var fgScale: CGFloat = 1.0
    @Published var fgOffset: CGSize = .zero
    @Published var bgScale: CGFloat = 1.0
    @Published var bgOffset: CGSize = .zero
    @Published var canvasScale: CGFloat = 1.0
    @Published var canvasOffset: CGSize = .zero
    
    // ADDED: Project tracking
    var currentProjectId: UUID? = nil
    
    // ADDED: Save Status
    @Published var saveStatus: SaveStatus = .idle
    
    // Undo/Redo Stacks
    private var undoStack: [EditorState] = []
    private var redoStack: [EditorState] = []
    private var isApplyingState = false
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    
    // Status indicators
    var isCanvasActive: Bool {
        selectedAspectRatio != .original || rotation != 0 || customSize != nil || isCropping || !textItems.isEmpty
    }
    
    var isFilterActive: Bool {
        selectedFilter != .none
    }
    
    var isAdjustActive: Bool {
        brightness != 1.0 || contrast != 1.0 || saturation != 1.0 || blur != 0.0
    }
    
    var isColorActive: Bool {
        backgroundColor != nil || gradientColors != nil
    }
    
    var isShadowActive: Bool {
        shadowRadius != 0 || shadowX != 0 || shadowY != 0 || shadowOpacity != 0.3 || shadowColor != .black
    }
    
    var isBackgroundTransparent: Bool {
        backgroundColor == nil && gradientColors == nil && backgroundImage == nil
    }
    
    var hasChanges: Bool {
        // Any undo history or active non-default state indicates changes
        return !undoStack.isEmpty || 
               selectedFilter != .none || 
               brightness != 1.0 || 
               contrast != 1.0 || 
               saturation != 1.0 || 
               blur != 0.0 || 
               rotation != 0 || 
               selectedAspectRatio != .original || 
               !stickers.isEmpty ||
               backgroundColor != nil ||
               gradientColors != nil ||
               backgroundImage != nil ||
               appliedCropRect != nil ||
               isShadowActive
    }
    
    @Published var showingStickerPreview = false
    @Published var stickerPreviewImage: UIImage? = nil
    @Published var stickerSize: CGFloat = 512 // Default WhatsApp Sticker size
    
    private let imageProcessor = ImageProcessor()
    private let removalService = BackgroundRemovalService()
    
    func setImage(_ image: UIImage) {
        self.originalImage = image
        self.foregroundImage = nil
        self.backgroundImage = nil
        self.currentProjectId = nil // Reset project tracking for new images
        
        // Reset transformations
        self.fgScale = 1.0
        self.fgOffset = .zero
        self.bgScale = 1.0
        self.bgOffset = .zero
        self.canvasScale = 1.0
        self.canvasOffset = .zero
        
        updateProcessedImage()
        removeBackgroundFromCurrent()
        
        // Initial state
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    private func currentState() -> EditorState {
        EditorState(
            selectedFilter: selectedFilter,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation,
            blur: blur,
            rotation: rotation,
            selectedAspectRatio: selectedAspectRatio,
            customSize: customSize,
            backgroundColor: backgroundColor,
            gradientColors: gradientColors,
            backgroundImage: backgroundImage,
            cropRect: appliedCropRect,
            stickers: stickers,
            textItems: textItems,
            shadowRadius: shadowRadius,
            shadowX: shadowX,
            shadowY: shadowY,
            shadowColor: shadowColor,
            shadowOpacity: shadowOpacity,
            fgScale: fgScale,
            fgOffset: fgOffset,
            bgScale: bgScale,
            bgOffset: bgOffset,
            canvasScale: canvasScale,
            canvasOffset: canvasOffset
        )
    }
    
    func saveState() {
        guard !isApplyingState else { return }
        let state = currentState()
        if undoStack.last != state {
            undoStack.append(state)
            redoStack.removeAll()
            // Keep stack size reasonable
            if undoStack.count > 20 {
                undoStack.removeFirst()
            }
        }
    }
    
    func undo() {
        guard undoStack.count > 1 else { return }
        isApplyingState = true
        
        // Current state goes to redo
        if let current = undoStack.popLast() {
            redoStack.append(current)
        }
        
        // Previous state becomes current
        if let previous = undoStack.last {
            applyState(previous)
        }
        
        isApplyingState = false
        updateProcessedImage()
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        isApplyingState = true
        
        undoStack.append(next)
        applyState(next)
        
        isApplyingState = false
        updateProcessedImage()
    }
    
    private func applyState(_ state: EditorState) {
        selectedFilter = state.selectedFilter
        brightness = state.brightness
        contrast = state.contrast
        saturation = state.saturation
        blur = state.blur
        rotation = state.rotation
        selectedAspectRatio = state.selectedAspectRatio
        customSize = state.customSize
        backgroundColor = state.backgroundColor
        gradientColors = state.gradientColors
        backgroundImage = state.backgroundImage
        appliedCropRect = state.cropRect
        stickers = state.stickers
        textItems = state.textItems
        shadowRadius = state.shadowRadius
        shadowX = state.shadowX
        shadowY = state.shadowY
        shadowColor = state.shadowColor
        shadowOpacity = state.shadowOpacity
        
        fgScale = state.fgScale
        fgOffset = state.fgOffset
        bgScale = state.bgScale
        bgOffset = state.bgOffset
        canvasScale = state.canvasScale
        canvasOffset = state.canvasOffset
    }
    
    func setBackgroundImage(_ image: UIImage) {
        saveState()
        self.backgroundImage = image
        self.backgroundColor = nil
        self.gradientColors = nil
        updateProcessedImage()
    }
    
    // MARK: - Crop Management
    
    func startCropping() {
        // Just enter mode, no state save yet
        isCropping = true
    }
    
    func cancelCropping() {
        isCropping = false
    }
    
    func applyCrop(_ rect: CGRect) {
        // Now "rect" is relative to the FULL processed image,
        // because we show the full image in crop mode.
        saveState()
        appliedCropRect = rect
        isCropping = false // Exit crop mode so the cropped image becomes visible
        updateProcessedImage()
    }
    
    // MARK: - Sticker Management
    
    func addSticker(_ content: String, type: StickerType = .emoji, color: Color = .white) {
        saveState()
        let newSticker = Sticker(content: content, type: type, color: color)
        stickers.append(newSticker)
        updateProcessedImage()
    }
    
    func updateSticker(_ sticker: Sticker) {
        if let index = stickers.firstIndex(where: { $0.id == sticker.id }) {
            // We don't save state on every drag update, but we might want to on end
            stickers[index] = sticker
            updateProcessedImage()
        }
    }
    
    func finalizeStickerUpdate() {
        saveState()
    }
    
    func removeSticker(id: UUID) {
        saveState()
        if selectedStickerId == id {
            selectedStickerId = nil
        }
        stickers.removeAll(where: { $0.id == id })
        updateProcessedImage()
    }
    
    // MARK: - Text Management
    
    func addTextItem(_ item: TextItem) {
        saveState()
        textItems.append(item)
        updateProcessedImage()
    }
    
    func updateTextItem(_ item: TextItem) {
        if let index = textItems.firstIndex(where: { $0.id == item.id }) {
            textItems[index] = item
            updateProcessedImage()
        }
    }
    
    func removeTextItem(id: UUID) {
        saveState()
        if selectedTextId == id {
            selectedTextId = nil
        }
        textItems.removeAll(where: { $0.id == id })
        updateProcessedImage()
    }
    
    func selectTextItem(id: UUID) {
        selectedTextId = id
        selectedStickerId = nil // Exclusivity
    }
    
    func deselectTextItem() {
        selectedTextId = nil
    }
    
    func finalizeTextUpdate() {
        saveState()
    }
    
    func selectSticker(id: UUID) {
        selectedStickerId = id
    }
    
    func deselectSticker() {
        selectedStickerId = nil
    }
    
    func removeBackgroundFromCurrent() {
        guard let image = originalImage else { return }
        
        isRemovingBackground = true
        
        Task {
            do {
                if let processed = try await removalService.removeBackground(from: image) {
                    await MainActor.run {
                        self.foregroundImage = processed
                        self.updateProcessedImage()
                        self.isRemovingBackground = false
                    }
                } else {
                    await MainActor.run {
                        self.isRemovingBackground = false
                    }
                }
            } catch {
                print("❌ EditorViewModel: Background removal failed - \(error.localizedDescription)")
                await MainActor.run {
                    self.isRemovingBackground = false
                }
            }
        }
    }
    
    func applyFilter(_ filter: FilterType) {
        saveState()
        selectedFilter = filter
        updateProcessedImage()
    }
    
    func updateAdjustment() {
        updateProcessedImage()
    }
    
    func finishAdjustment() {
        saveState()
    }
    
    func rotateLeft() {
        saveState()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            rotation -= 90
            if rotation < 0 {
                rotation += 360
            }
            updateProcessedImage()
        }
    }
    
    func rotateRight() {
        saveState()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            rotation += 90
            if rotation >= 360 {
                rotation -= 360
            }
            updateProcessedImage()
        }
    }
    
    func resetAdjustments() {
        saveState()
        brightness = 1.0
        contrast = 1.0
        saturation = 1.0
        blur = 0.0
        backgroundColor = nil
        gradientColors = nil
        backgroundImage = nil // Also reset background if needed
        updateProcessedImage()
    }
    
    private func updateProcessedImage() {
        // Use foreground if available, otherwise original
        guard let foreground = foregroundImage ?? originalImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1. Generate FULL processed image (no crop)
            let full = self.imageProcessor.processImageWithCrop(
                original: foreground,
                filter: self.selectedFilter,
                brightness: self.brightness,
                contrast: self.contrast,
                saturation: self.saturation,
                blur: self.blur,
                rotation: self.rotation,
                aspectRatio: nil, // No aspect ratio crop here
                customSize: nil,   // No custom size crop here
                backgroundColor: nil,
                gradientColors: nil,
                backgroundImage: nil,
                cropRect: nil,     // No free crop here
                stickers: [],
                textItems: [],
                shadowRadius: self.shadowRadius,
                shadowX: self.shadowX,
                shadowY: self.shadowY,
                shadowColor: self.shadowColor,
                shadowOpacity: self.shadowOpacity,
                shouldIncludeShadow: false
            )
            
            // 2. Generate CROPPED processed image
            let cropped = self.imageProcessor.processImageWithCrop(
                original: foreground,
                filter: self.selectedFilter,
                brightness: self.brightness,
                contrast: self.contrast,
                saturation: self.saturation,
                blur: self.blur,
                rotation: self.rotation,
                aspectRatio: self.selectedAspectRatio.ratio,
                customSize: self.customSize,
                backgroundColor: nil,
                gradientColors: nil,
                backgroundImage: nil,
                cropRect: self.appliedCropRect,
                stickers: [],
                textItems: self.textItems, // Render text items in preview
                shadowRadius: self.shadowRadius,
                shadowX: self.shadowX,
                shadowY: self.shadowY,
                shadowColor: self.shadowColor,
                shadowOpacity: self.shadowOpacity,
                shouldIncludeShadow: false
            )
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.fullProcessedImage = full ?? foreground
                    self.processedImage = cropped ?? foreground
                }
            }
        }
    }
    
    func saveToGallery(format: ImageFormat = .png, completion: @escaping (Bool, String) -> Void) {
        guard let foreground = foregroundImage ?? originalImage else {
            completion(false, "Kein Bild zum Speichern")
            return
        }
        
        // Generate final image with stickers burned in
        let finalImage = self.imageProcessor.processImageWithCrop(
            original: foreground,
            filter: self.selectedFilter,
            brightness: self.brightness,
            contrast: self.contrast,
            saturation: self.saturation,
            blur: self.blur,
            rotation: self.rotation,
            aspectRatio: self.selectedAspectRatio.ratio,
            customSize: self.customSize,
            backgroundColor: self.backgroundColor,
            gradientColors: self.gradientColors,
            backgroundImage: self.backgroundImage,
            cropRect: self.appliedCropRect,
            stickers: self.stickers, // Burn them in here
            textItems: self.textItems, // Burn text items in final image
            shadowRadius: self.shadowRadius,
            shadowX: self.shadowX,
            shadowY: self.shadowY,
            shadowColor: self.shadowColor,
            shadowOpacity: self.shadowOpacity
        ) ?? foreground

        let data: Data?
        switch format {
        case .png:
            data = finalImage.pngData()
        case .jpg:
            data = finalImage.jpegData(compressionQuality: 0.8)
        }
        
        guard let finalData = data, let finalImage = UIImage(data: finalData) else {
            completion(false, "Fehler bei der Bildverarbeitung")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(false, "Keine Berechtigung für Fotobibliothek")
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(true, "Foto als \(format == .png ? "PNG" : "JPG") gespeichert")
                    } else {
                        completion(false, error?.localizedDescription ?? "Fehler beim Speichern")
                    }
                }
            }
        }
    }
    
    func shareImage() {
        guard let foreground = foregroundImage ?? originalImage else { return }
        
        let finalImage = self.imageProcessor.processImageWithCrop(
            original: foreground,
            filter: self.selectedFilter,
            brightness: self.brightness,
            contrast: self.contrast,
            saturation: self.saturation,
            blur: self.blur,
            rotation: self.rotation,
            aspectRatio: self.selectedAspectRatio.ratio,
            customSize: self.customSize,
            backgroundColor: self.backgroundColor,
            gradientColors: self.gradientColors,
            backgroundImage: self.backgroundImage,
            cropRect: self.appliedCropRect,
            stickers: self.stickers,
            textItems: self.textItems,
            shadowRadius: self.shadowRadius,
            shadowX: self.shadowX,
            shadowY: self.shadowY,
            shadowColor: self.shadowColor,
            shadowOpacity: self.shadowOpacity
        ) ?? foreground
        
        // Use PNG if there's transparency, JPG otherwise for sharing
        let data = isBackgroundTransparent ? finalImage.pngData() : finalImage.jpegData(compressionQuality: 0.8)
        guard let finalData = data, let finalImage = UIImage(data: finalData) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [finalImage], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad support
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func prepareStickerPreview() {
        guard let foreground = foregroundImage ?? originalImage else { return }
        
        let compositeImage = self.imageProcessor.processImageWithCrop(
            original: foreground,
            filter: self.selectedFilter,
            brightness: self.brightness,
            contrast: self.contrast,
            saturation: self.saturation,
            blur: self.blur,
            rotation: self.rotation,
            aspectRatio: self.selectedAspectRatio.ratio,
            customSize: self.customSize,
            backgroundColor: self.backgroundColor,
            gradientColors: self.gradientColors,
            backgroundImage: self.backgroundImage,
            cropRect: self.appliedCropRect,
            stickers: self.stickers,
            textItems: self.textItems,
            shadowRadius: self.shadowRadius,
            shadowX: self.shadowX,
            shadowY: self.shadowY,
            shadowColor: self.shadowColor,
            shadowOpacity: self.shadowOpacity
        ) ?? foreground
        
        if let stickerImage = imageProcessor.generateStickerImage(from: compositeImage, targetSize: self.stickerSize) {
            DispatchQueue.main.async {
                self.stickerPreviewImage = stickerImage
                self.showingStickerPreview = true
            }
        }
    }
    
    func shareAsSticker(completion: @escaping (Bool) -> Void) {
        guard let stickerImage = stickerPreviewImage else {
            completion(false)
            return
        }
        
        guard let webpData = WebPConverter.convertToWebP(image: stickerImage) else {
            completion(false)
            return
        }
        
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".webp")
        do {
            try webpData.write(to: tempURL)
            
            // Share the file
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                }
                
                rootVC.present(activityVC, animated: true) {
                    completion(true)
                }
            }
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Persistence Helpers
    
    private func saveImageToDocuments(_ image: UIImage, name: String) -> String? {
        guard let data = image.pngData() else { return nil }
        let filename = name + ".png"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    private func loadImageFromDocuments(_ name: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }
    
    func saveProject(completion: @escaping (Bool, String) -> Void) {
        guard let original = originalImage else {
            completion(false, "Kein Bild zum Speichern")
            return
        }
        
        saveStatus = .saving
        
        let projectId = currentProjectId ?? UUID()
        let originalName = saveImageToDocuments(original, name: "original_\(projectId.uuidString)")
        let backgroundName = backgroundImage.flatMap { saveImageToDocuments($0, name: "background_\(projectId.uuidString)") }
        let foregroundName = foregroundImage.flatMap { saveImageToDocuments($0, name: "foreground_\(projectId.uuidString)") }
        
        let state = CodableEditorState(
            selectedFilter: selectedFilter,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation,
            blur: blur,
            rotation: rotation,
            selectedAspectRatio: selectedAspectRatio,
            customWidth: customSize?.width,
            customHeight: customSize?.height,
            backgroundColorHex: backgroundColor?.hex,
            gradientColorsHex: gradientColors?.compactMap { $0.hex },
            backgroundImageName: backgroundName,
            foregroundImageName: foregroundName,
            appliedCropRect: appliedCropRect.map { CodableRect($0) },
            stickers: stickers,
            textItems: textItems,
            shadowRadius: shadowRadius,
            shadowX: shadowX,
            shadowY: shadowY,
            shadowColorHex: shadowColor.hex ?? "#000000",
            shadowOpacity: shadowOpacity,
            fgScale: fgScale,
            fgOffset: CodablePoint(CGPoint(x: fgOffset.width, y: fgOffset.height)),
            bgScale: bgScale,
            bgOffset: CodablePoint(CGPoint(x: bgOffset.width, y: bgOffset.height)),
            canvasScale: canvasScale,
            canvasOffset: CodablePoint(CGPoint(x: canvasOffset.width, y: canvasOffset.height))
        )
        
        // Generate thumbnail
        let finalImage = self.imageProcessor.processImageWithCrop(
            original: foregroundImage ?? original,
            filter: self.selectedFilter,
            brightness: self.brightness,
            contrast: self.contrast,
            saturation: self.saturation,
            blur: self.blur,
            rotation: self.rotation,
            aspectRatio: self.selectedAspectRatio.ratio,
            customSize: self.customSize,
            backgroundColor: self.backgroundColor,
            gradientColors: self.gradientColors,
            backgroundImage: self.backgroundImage,
            cropRect: self.appliedCropRect,
            stickers: self.stickers,
            textItems: self.textItems,
            shadowRadius: self.shadowRadius,
            shadowX: self.shadowX,
            shadowY: self.shadowY,
            shadowColor: self.shadowColor,
            shadowOpacity: self.shadowOpacity
        ) ?? original

        let project = Project(
            id: projectId,
            thumbnail: finalImage,
            originalImageName: originalName,
            state: state
        )
        
        self.currentProjectId = projectId
        ProjectManager.shared.saveProject(project)
        
        self.saveStatus = .saved
        // Return to idle after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.saveStatus == .saved {
                self?.saveStatus = .idle
            }
        }
        
        completion(true, "Projekt erfolgreich gespeichert")
    }
    
    func loadProject(_ project: Project) {
        guard let state = project.state, let originalName = project.originalImageName else { return }
        
        self.currentProjectId = project.id
        
        if let original = loadImageFromDocuments(originalName) {
            self.isApplyingState = true // Prevent auto-save while loading
            self.originalImage = original
            self.foregroundImage = state.foregroundImageName.flatMap { loadImageFromDocuments($0) }
            
            self.selectedFilter = state.selectedFilter
            self.brightness = state.brightness
            self.contrast = state.contrast
            self.saturation = state.saturation
            self.blur = state.blur
            self.rotation = state.rotation
            self.selectedAspectRatio = state.selectedAspectRatio
            
            if let w = state.customWidth, let h = state.customHeight {
                self.customSize = CGSize(width: w, height: h)
            } else {
                self.customSize = nil
            }
            
            self.backgroundColor = state.backgroundColorHex.map { Color(hex: $0) }
            self.gradientColors = state.gradientColorsHex?.map { Color(hex: $0) }
            self.backgroundImage = state.backgroundImageName.flatMap { loadImageFromDocuments($0) }
            self.appliedCropRect = state.appliedCropRect?.cgRect
            self.stickers = state.stickers
            self.textItems = state.textItems
            self.shadowRadius = state.shadowRadius
            self.shadowX = state.shadowX
            self.shadowY = state.shadowY
            self.shadowColor = Color(hex: state.shadowColorHex)
            self.shadowOpacity = state.shadowOpacity
            
            // Restore transformations
            self.fgScale = state.fgScale
            self.fgOffset = CGSize(width: state.fgOffset.x, height: state.fgOffset.y)
            self.bgScale = state.bgScale
            self.bgOffset = CGSize(width: state.bgOffset.x, height: state.bgOffset.y)
            self.canvasScale = state.canvasScale
            self.canvasOffset = CGSize(width: state.canvasOffset.x, height: state.canvasOffset.y)
            
            self.updateAdjustment()
            self.isApplyingState = false
        }
    }
    
    private func setupAutoSave() {
        objectWillChange
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self, self.hasChanges, !self.isApplyingState else { return }
                self.saveProject { _, _ in }
            }
            .store(in: &cancellables)
    }
}
