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

enum EditorTab: String, CaseIterable, Identifiable {
    case unsplash, stickers, shadow, crop, filter, colors, adjust
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .unsplash: return "Hintergrund"
        case .stickers: return "Sticker"
        case .shadow: return "Schatten"
        case .crop: return "Zuschneiden"
        case .filter: return "Filter"
        case .colors: return "Farben"
        case .adjust: return "Anpassen"
        }
    }
    
    var iconName: String {
        switch self {
        case .crop: return "crop"
        case .filter: return "sparkles"
        case .colors: return "paintpalette.fill"
        case .adjust: return "slider.horizontal.3"
        case .shadow: return "circle.lefthalf.striped.horizontal"
        case .unsplash: return "photo.stack"
        case .stickers: return "face.smiling.fill"
        }
    }
}

enum StickerFlowStep: String, CaseIterable {
    case size, export
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
    // ADDED: Sticker State
    var stickerSize: CGFloat
    var stickerOutlineWidth: CGFloat
    var stickerOutlineColor: Color
    // ADDED: UI Transformation State
    var fgScale: CGFloat
    var fgOffset: CGSize
    var bgScale: CGFloat
    var bgOffset: CGSize
    var canvasScale: CGFloat
    var canvasOffset: CGSize
    var version: Int // Increment this on every change-inducing action
    
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
            lhs.stickerSize == rhs.stickerSize &&
            lhs.stickerOutlineWidth == rhs.stickerOutlineWidth &&
            lhs.stickerOutlineColor == rhs.stickerOutlineColor &&
            lhs.fgScale == rhs.fgScale &&
            lhs.fgOffset == rhs.fgOffset &&
            lhs.bgScale == rhs.bgScale &&
            lhs.bgOffset == rhs.bgOffset &&
            lhs.canvasScale == rhs.canvasScale &&
            lhs.canvasOffset == rhs.canvasOffset &&
            lhs.version == rhs.version
    }
}

enum ImageFormat {
    case png
    case jpg
}

class EditorViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // setupAutoSave() // Disabled per user request
    }
    
    @Published var originalImage: UIImage?
    @Published var foregroundImage: UIImage? // The image with background removed
    @Published var backgroundImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var fullProcessedImage: UIImage? // The image with all adjustments but NO CROP
    
    @Published var selectedTab: EditorTab? = nil {
        didSet {
            if selectedTab == .stickers {
                isStickerModeActive = true
            }
        }
    }
    
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
    @Published var targetEditorScale: CGFloat? = nil // Scale to apply after destructive crop
    
    // Sticker State
    @Published var stickers: [Sticker] = []
    @Published var selectedStickerId: UUID? = nil
    @Published var showingEmojiPicker = false
    @Published var stickerFlowStep: StickerFlowStep = .size
    
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
    @Published var uiCanvasSize: CGSize = .zero // ADDED: Capture UI size for WYSIWYG export
    
    // ADDED: Project tracking
    var currentProjectId: UUID? = nil
    
    // ADDED: Save Status
    @Published var saveStatus: SaveStatus = .idle
    private var stateVersion: Int = 0
    
    // Undo/Redo Stacks
    private var undoStack: [EditorState] = []
    private var redoStack: [EditorState] = []
    private var lastSavedState: EditorState? = nil
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
        shadowRadius > 0 || shadowX != 0 || shadowY != 0
    }
    
    var currentProcessingParameters: ProcessingParameters {
        ProcessingParameters(
            filter: selectedFilter,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation,
            blur: blur,
            rotation: rotation,
            aspectRatio: selectedAspectRatio.ratio,
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
            shouldIncludeShadow: true,
            fgScale: fgScale,
            fgOffset: fgOffset,
            bgScale: bgScale,
            bgOffset: bgOffset,
            uiCanvasSize: uiCanvasSize,
            referenceSize: originalImage?.size,
            outlineWidth: stickerOutlineWidth,
            outlineColor: stickerOutlineColor
        )
    }
    
    var isBackgroundTransparent: Bool {
        backgroundColor == nil && gradientColors == nil && backgroundImage == nil
    }
    
    var hasChanges: Bool {
        // Prefer comparing current state to last saved state if available
        if let last = lastSavedState {
            return currentState() != last
        }
        
        // Fallback for new projects
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
    @Published var stickerSize: CGFloat = 512 { // Default to 512x512
        didSet { 
            didChange() 
            if !isStickerModeActive { isStickerModeActive = true }
        }
    }
    @Published var isStickerModeActive = false

    @Published var stickerOutlineWidth: CGFloat = 0 {
        didSet { updateProcessedImage() }
    }
    @Published var stickerOutlineColor: Color = .white {
        didSet {
            // Dispatch to next runloop to prevent "Modifying state during view update" crash
            // resulting from ColorPicker binding updates triggering other published property changes.
            DispatchQueue.main.async {
                self.updateProcessedImage()
            }
        }
    }
    
    var stickerUIScale: CGFloat {
        // 512 is our reference "full" size for the UI canvas
        // 96 is the small size. Let's make it visually distinct but readable.
        if stickerSize == 21 {
            return 0.3 // 30% of container size (very small)
        } else if stickerSize == 96 {
            return 0.6 // 60% of container size
        }
        return 1.0 // 100% of container size
    }
    
    private let imageProcessor = ImageProcessor()
    private let removalService = BackgroundRemovalService()
    
    func setImage(_ image: UIImage) {
        self.originalImage = image
        self.foregroundImage = nil
        self.backgroundImage = nil
        self.currentProjectId = nil // Reset project tracking for new images
        self.stickerSize = 512 // Reset sticker size default
        self.isStickerModeActive = false
        
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
        stateVersion = 0
        lastSavedState = currentState()
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
            stickerSize: stickerSize,
            stickerOutlineWidth: stickerOutlineWidth,
            stickerOutlineColor: stickerOutlineColor,
            fgScale: fgScale,
            fgOffset: fgOffset,
            bgScale: bgScale,
            bgOffset: bgOffset,
            canvasScale: canvasScale,
            canvasOffset: canvasOffset,
            version: stateVersion
        )
    }
    
    func didChange() {
        stateVersion += 1
        saveState()
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
        
        stickerSize = state.stickerSize
        stickerOutlineWidth = state.stickerOutlineWidth
        stickerOutlineColor = state.stickerOutlineColor
        
        fgScale = state.fgScale
        fgOffset = state.fgOffset
        bgScale = state.bgScale
        bgOffset = state.bgOffset
        canvasScale = state.canvasScale
        canvasOffset = state.canvasOffset
        stateVersion = state.version
    }
    
    func setBackgroundImage(_ image: UIImage) {
        didChange()
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
        // "rect" is normalized (0.0 to 1.0) relative to the image being cropped.
        guard let baseImage = foregroundImage ?? originalImage else { return }
        
        didChange()
        
        // 1. CALCULATE TARGET SCALE BEFORE CROPPING
        let targetScale = rect.width
        
        // 2. CALCULATE POSITION SHIFT TO PRESERVE LOCATION
        // Calculate the current visual dimensions on the canvas
        let widthRatio = uiCanvasSize.width / baseImage.size.width
        let heightRatio = uiCanvasSize.height / baseImage.size.height
        let baseFitScale = min(widthRatio, heightRatio)
        
        // We use the same stable scale logic as in ZoomableImageView
        // If we have a previous targetEditorScale, we should account for it, 
        // but normally editorScale starts at baseFitScale.
        let currentVisualW = baseImage.size.width * baseFitScale * (targetEditorScale ?? 1.0) * fgScale
        let currentVisualH = baseImage.size.height * baseFitScale * (targetEditorScale ?? 1.0) * fgScale
        
        // Calculate how much the center has moved in visual pixels
        let shiftX = (rect.midX - 0.5) * currentVisualW
        let shiftY = (rect.midY - 0.5) * currentVisualH
        
        if let newImage = imageProcessor.cropImageNormalized(image: baseImage, normalizedRect: rect) {
            // DESTRUCTIVE CROP:
            self.foregroundImage = newImage
            self.appliedCropRect = nil
            
            // Set the target scale for ZoomableImageView to use
            self.targetEditorScale = (targetEditorScale ?? 1.0) * targetScale
            
            // ADJUST POSITION: Instead of resetting to .zero, we add the shift
            // This compensates for the fact that the new image center is the old crop center
            self.fgOffset = CGSize(
                width: self.fgOffset.width + shiftX,
                height: self.fgOffset.height + shiftY
            )
            
            // Reset fgScale because the crop is now "baked in" at the new base size
            self.fgScale = 1.0
            
            print("✅ Destructive Crop Applied: New Size \(newImage.size), Target Scale: \(self.targetEditorScale ?? 1.0), Shift: \(shiftX), \(shiftY)")
        }
        
        isCropping = false
        updateProcessedImage()
    }
    
    // MARK: - Sticker Management
    
    func addSticker(_ content: String, type: StickerType = .emoji, color: Color = .white) {
        didChange()
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
        didChange()
    }
    
    func removeSticker(id: UUID) {
        didChange()
        if selectedStickerId == id {
            selectedStickerId = nil
        }
        stickers.removeAll(where: { $0.id == id })
        updateProcessedImage()
    }
    
    func applyStickerSize(_ size: CGFloat) {
        self.stickerSize = size
        updateProcessedImage()
    }
    
    // MARK: - Text Management
    
    func addTextItem(_ item: TextItem) {
        didChange()
        textItems.append(item)
        updateProcessedImage()
    }
    
    func updateTextItem(_ item: TextItem) {
        if let index = textItems.firstIndex(where: { $0.id == item.id }) {
            didChange()
            textItems[index] = item
            updateProcessedImage()
        }
    }
    
    func removeTextItem(id: UUID) {
        didChange()
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
        didChange()
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
                        // Trim transparency immediately to find new corners
                        self.foregroundImage = self.imageProcessor.trimTransparency(from: processed) ?? processed
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
        didChange()
        selectedFilter = filter
        updateProcessedImage()
    }
    
    func updateAdjustment() {
        updateProcessedImage()
    }
    
    func finishAdjustment() {
        didChange()
    }
    
    func rotateLeft() {
        didChange()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            rotation -= 90
            if rotation < 0 {
                rotation += 360
            }
            updateProcessedImage()
        }
    }
    
    func rotateRight() {
        didChange()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            rotation += 90
            if rotation >= 360 {
                rotation -= 360
            }
            updateProcessedImage()
        }
    }
    
    func resetAdjustments() {
        didChange()
        brightness = 1.0
        contrast = 1.0
        saturation = 1.0
        blur = 0.0
        backgroundColor = nil
        gradientColors = nil
        backgroundImage = nil // Also reset background if needed
        updateProcessedImage()
    }
    
    // ADDED: Task for debouncing image processing
    private var processingTask: Task<Void, Never>?

    private func updateProcessedImage() {
        // Cancel any pending processing to prevent backlog and memory spikes
        processingTask?.cancel()
        
        // Use foreground if available, otherwise original
        guard let foreground = foregroundImage ?? originalImage else { return }
        
        // Capture specific values needed for processing to avoid data races
        let fullParams = self.currentProcessingParameters
        let imageProcessor = self.imageProcessor
        
        processingTask = Task.detached(priority: .userInitiated) {
            // Debounce: Wait a short time to see if another update comes in
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            
            if Task.isCancelled { return }
            
            // 1. Generate FULL processed image (no crop)
            var fullParamsForProcessing = fullParams
            fullParamsForProcessing.aspectRatio = nil
            fullParamsForProcessing.customSize = nil
            fullParamsForProcessing.cropRect = nil
            fullParamsForProcessing.shouldIncludeShadow = true 
            // IMPORTANT: Reset user transforms for the LIVE preview image
            // because ZoomableImageView applies these via SwiftUI .offset/.scaleEffect.
            // Baking them in here would cause "double transformation".
            fullParamsForProcessing.fgScale = 1.0
            fullParamsForProcessing.fgOffset = .zero
            fullParamsForProcessing.bgScale = 1.0
            fullParamsForProcessing.bgOffset = .zero
            
            // EXCLUDE: Items that are rendered as interactive overlays to avoid duplication
            fullParamsForProcessing.stickers = []
            fullParamsForProcessing.textItems = []
            
            let full = imageProcessor.processImageWithCrop(original: foreground, params: fullParamsForProcessing)
            
            if Task.isCancelled { return }
            
            // 2. Generate CROPPED processed image
            var croppedParamsForProcessing = fullParams
            croppedParamsForProcessing.shouldIncludeShadow = true 
            // Reset transforms here too for consistency
            croppedParamsForProcessing.fgScale = 1.0
            croppedParamsForProcessing.fgOffset = .zero
            croppedParamsForProcessing.bgScale = 1.0
            croppedParamsForProcessing.bgOffset = .zero

            // EXCLUDE: Items that are rendered as interactive overlays to avoid duplication
            croppedParamsForProcessing.stickers = []
            croppedParamsForProcessing.textItems = []
            
            let cropped = imageProcessor.processImageWithCrop(original: foreground, params: croppedParamsForProcessing)
            
            if Task.isCancelled { return }
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.fullProcessedImage = full ?? foreground
                    self.processedImage = cropped ?? foreground
                }
            }
        }
    }
    
    func saveToGallery(format: ImageFormat = .png, completion: @escaping (Bool, LocalizedStringKey) -> Void) {
        // Fallback to original if foreground is missing, ensuring we always have something to save
        // This addresses "should save what is in photo editor area if empty"
        guard let foreground = foregroundImage ?? originalImage else {
            completion(false, "Kein Bild zum Speichern")
            return
        }
        
        // Generate final image with stickers burned in
        var params = self.currentProcessingParameters
        params.outlineWidth = 0 // No outline for general save
        
        let finalImage = self.imageProcessor.processImageWithCrop(original: foreground, params: params) ?? foreground

        print("💾 Saving High-Res Image: \(finalImage.size) points @ \(finalImage.scale)x scale = \(finalImage.size.width * finalImage.scale)x\(finalImage.size.height * finalImage.scale) pixels")
        let data: Data?
        let fileExtension: String
        
        switch format {
        case .png:
            data = finalImage.pngData()
            fileExtension = "png"
        case .jpg:
            data = finalImage.jpegData(compressionQuality: 0.8)
            fileExtension = "jpg"
        }
        
        guard let finalData = data else {
            completion(false, "Fehler bei der Bildverarbeitung")
            return
        }
        
        // Save to temporary file first to enforce format/transparency
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "saved_image_\(UUID().uuidString).\(fileExtension)"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try finalData.write(to: fileURL)
        } catch {
            completion(false, "Dateifehler beim Speichern")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(false, "Keine Berechtigung für Fotobibliothek")
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                // Request creating asset from the FILE, not the UIImage, to preserve exact format (PNG transparency)
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
            }, completionHandler: { success, error in
                // Cleanup temp file
                try? FileManager.default.removeItem(at: fileURL)
                
                DispatchQueue.main.async {
                    if success {
                        completion(true, "Foto gespeichert")
                    } else {
                        print("Save error: \(String(describing: error))")
                        completion(false, "Fehler beim Speichern")
                    }
                }
            })
        }
    }
    
    func shareImage() {
        guard let foreground = foregroundImage ?? originalImage else { return }
        
        var params = self.currentProcessingParameters
        params.outlineWidth = 0 // No outline for sharing
        
        let finalImage = self.imageProcessor.processImageWithCrop(original: foreground, params: params) ?? foreground
        
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
        guard var baseImage = foregroundImage ?? originalImage else { return }
        
        // 1. Physically CROP the image if a crop rect exists
        // This ensures the sticker is based ONLY on the visible part.
        if let rect = appliedCropRect {
            let imageSize = baseImage.size
            let cropZone = CGRect(
                x: rect.minX * imageSize.width,
                y: rect.minY * imageSize.height,
                width: rect.width * imageSize.width,
                height: rect.height * imageSize.height
            )
            
            let scale = baseImage.scale
            let scaledCropZone = CGRect(
                x: cropZone.origin.x * scale,
                y: cropZone.origin.y * scale,
                width: cropZone.size.width * scale,
                height: cropZone.size.height * scale
            )
            
            if let cgImage = baseImage.cgImage,
               let croppedCg = cgImage.cropping(to: scaledCropZone) {
                baseImage = UIImage(cgImage: croppedCg, scale: scale, orientation: baseImage.imageOrientation)
            }
        }
        
        // 2. Apply Filters/Adjustments (but NO visual masking/composite here)
        let params = self.currentProcessingParameters
        let processedBase = self.imageProcessor.processImage(
            original: baseImage,
            filter: params.filter,
            brightness: params.brightness,
            contrast: params.contrast,
            saturation: params.saturation,
            blur: params.blur,
            rotation: params.rotation
        ) ?? baseImage
        
        // 3. Generate final sticker with Outline and Padding
        // We pass the stickerOutlineWidth explicitly here
        if let stickerImage = imageProcessor.generateStickerImage(
            from: processedBase,
            targetSize: self.stickerSize,
            outlineWidth: stickerOutlineWidth,
            outlineColor: stickerOutlineColor
        ) {
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
    
    func saveProject(completion: @escaping (Bool, LocalizedStringKey) -> Void) {
        guard let original = originalImage else {
            completion(false, "Kein Bild zum Speichern")
            return
        }
        
        saveStatus = .saving
        
        let projectId = currentProjectId ?? UUID()
        
        guard let originalName = saveImageToDocuments(original, name: "original_\(projectId.uuidString)") else {
            completion(false, "Speicherfehler: Disk")
            return
        }
        
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
            canvasOffset: CodablePoint(CGPoint(x: canvasOffset.width, y: canvasOffset.height)),
            version: stateVersion,
            stickerOutlineWidth: stickerOutlineWidth,
            stickerOutlineColorHex: stickerOutlineColor.hex,
            stickerSize: stickerSize // ADDED
        )
        
        // Generate thumbnail
        let finalImage = self.imageProcessor.processImageWithCrop(original: foregroundImage ?? original, params: self.currentProcessingParameters) ?? original

        let project = Project(
            id: projectId,
            thumbnail: finalImage,
            originalImageName: originalName,
            state: state
        )
        
        self.currentProjectId = projectId
        self.lastSavedState = currentState()
        ProjectManager.shared.saveProject(project)
        
        print("✅ EditorViewModel: Project \(projectId) saved successfully")
        
        self.saveStatus = .saved
        // Return to idle after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.saveStatus == .saved {
                self?.saveStatus = .idle
            }
        }
        
        completion(true, "Projekt gespeichert")
    }
    
    func saveAsSticker(completion: @escaping (UIImage?) -> Void) {
        guard let foreground = foregroundImage ?? originalImage else {
            completion(nil)
            return
        }
        
        self.saveStatus = .saving
        
        // Create the sticker image
        // 1. Process the image with the outline and square aspect ratio
        var stickerParams = self.currentProcessingParameters
        stickerParams.aspectRatio = 1.0
        stickerParams.customSize = CGSize(width: stickerSize, height: stickerSize)
        stickerParams.backgroundColor = nil
        stickerParams.shadowRadius = 0
        stickerParams.shadowOpacity = 0
        stickerParams.shouldIncludeShadow = false
        stickerParams.bgScale = 1.0
        stickerParams.bgOffset = .zero
        stickerParams.referenceSize = CGSize(width: stickerSize, height: stickerSize)
        
        let sticker = self.imageProcessor.processImageWithCrop(original: foreground, params: stickerParams) ?? foreground
        
        // Save to photo library as PNG
        guard let data = sticker.pngData() else {
            completion(nil)
            self.saveStatus = .idle
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        
        do {
            try data.write(to: tempURL)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: tempURL)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.saveStatus = .saved
                        completion(sticker) // Return the image for sharing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if self.saveStatus == .saved {
                                self.saveStatus = .idle
                            }
                        }
                    } else {
                        self.saveStatus = .idle
                        completion(nil)
                    }
                    try? FileManager.default.removeItem(at: tempURL)
                }
            }
        } catch {
            self.saveStatus = .idle
            completion(nil)
        }
    }
    
    func deleteCurrentProject() {
        if let projectId = currentProjectId {
            ProjectManager.shared.deleteProject(withId: projectId)
            currentProjectId = nil
        }
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
            self.stateVersion = state.version
            
            // Restore sticker outline
            self.stickerOutlineWidth = state.stickerOutlineWidth
            if let hex = state.stickerOutlineColorHex {
                self.stickerOutlineColor = Color(hex: hex)
            }
            self.stickerSize = state.stickerSize // ADDED
            
            self.updateAdjustment()
            self.lastSavedState = currentState()
            self.isApplyingState = false
        }
    }
    
    private func setupAutoSave() {
        // Auto-save disabled as per user request
    }
}
