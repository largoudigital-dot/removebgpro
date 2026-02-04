import SwiftUI
import Combine

enum SelectedLayer {
    case foreground
    case background
    case canvas
}

struct ZoomableImageView: View {
    let foreground: UIImage?
    let background: UIImage?
    let original: UIImage?
    let backgroundColor: Color?
    let gradientColors: [Color]?
    let activeLayer: SelectedLayer
    let rotation: CGFloat
    let isCropping: Bool
    let appliedCropRect: CGRect? // ADDED: Cumulative applied crop
    let onCropCommit: ((CGRect) -> Void)?
    @Binding var stickers: [Sticker]
    @Binding var selectedStickerId: UUID?
    let onDeleteSticker: (UUID) -> Void
    
    @Binding var textItems: [TextItem]
    @Binding var selectedTextId: UUID?
    let onDeleteText: (UUID) -> Void
    let onEditText: (TextItem) -> Void
    let isEditingText: Bool
    
    // Shadow Properties
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    let shadowColor: Color
    let shadowOpacity: Double
    
    init(foreground: UIImage?, background: UIImage?, original: UIImage?, backgroundColor: Color?, gradientColors: [Color]?, activeLayer: SelectedLayer, rotation: CGFloat, isCropping: Bool = false, appliedCropRect: CGRect? = nil, onCropCommit: ((CGRect) -> Void)? = nil, stickers: Binding<[Sticker]>, selectedStickerId: Binding<UUID?>, onDeleteSticker: @escaping (UUID) -> Void, textItems: Binding<[TextItem]>, selectedTextId: Binding<UUID?>, onDeleteText: @escaping (UUID) -> Void, onEditText: @escaping (TextItem) -> Void, isEditingText: Bool = false, shadowRadius: CGFloat = 0, shadowX: CGFloat = 0, shadowY: CGFloat = 0, shadowColor: Color = .black, shadowOpacity: Double = 0.3) {
        self.foreground = foreground
        self.background = background
        self.original = original
        self.backgroundColor = backgroundColor
        self.gradientColors = gradientColors
        self.activeLayer = activeLayer
        self.rotation = rotation
        self.isCropping = isCropping
        self.appliedCropRect = appliedCropRect
        self.onCropCommit = onCropCommit
        self._stickers = stickers
        self._selectedStickerId = selectedStickerId
        self.onDeleteSticker = onDeleteSticker
        
        self._textItems = textItems
        self._selectedTextId = selectedTextId
        self.onDeleteText = onDeleteText
        self.onEditText = onEditText
        self.isEditingText = isEditingText
        
        self.shadowRadius = shadowRadius
        self.shadowX = shadowX
        self.shadowY = shadowY
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
    }
    
    // Foreground State
    @State private var fgScale: CGFloat = 1.0
    @State private var fgLastScale: CGFloat = 1.0
    @State private var fgOffset: CGSize = .zero
    @State private var fgLastOffset: CGSize = .zero
    
    // Background State
    @State private var bgScale: CGFloat = 1.0
    @State private var bgLastScale: CGFloat = 1.0
    @State private var bgOffset: CGSize = .zero
    @State private var bgLastOffset: CGSize = .zero
    
    // Canvas State (Affects both)
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasLastScale: CGFloat = 1.0
    @State private var canvasOffset: CGSize = .zero
    @State private var canvasLastOffset: CGSize = .zero
    
    @State private var showVGuide = false
    @State private var showHGuide = false
    @State private var activeSnapX: CGFloat? = nil
    @State private var activeSnapY: CGFloat? = nil
    @State private var guideColor: Color = .yellow // Default to yellow
    @State private var interactingLayer: SelectedLayer? = nil
    
    private let snapThreshold: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // --- BACKGROUND DESELECTION LAYER ---
                // This layer captures taps outside the stickers to deselect them
                // without letting the tap reach the image layers.
                if selectedStickerId != nil {
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            print("DEBUG: Deselection area touched")
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedStickerId = nil
                                selectedTextId = nil
                            }
                        }
                        .zIndex(500)
                }
                
                if selectedTextId != nil {
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTextId = nil
                                selectedStickerId = nil
                            }
                        }
                        .zIndex(500)
                }
                
                // --- PHOTO CONTENT CONTAINER ---
                ZStack {
                    // 1. Background Layer (Bottom)
                    Group {
                        if let bgImage = background {
                            Image(uiImage: bgImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.blue, lineWidth: (interactingLayer == .background || (interactingLayer == .canvas && activeLayer == .canvas)) ? 3 : 0)
                                )
                                .scaleEffect(bgScale)
                                .offset(bgOffset)
                        } else if let colors = gradientColors {
                            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.blue, lineWidth: (interactingLayer == .background || (interactingLayer == .canvas && activeLayer == .canvas)) ? 3 : 0)
                                )
                                .scaleEffect(bgScale)
                                .offset(bgOffset)
                        } else if let color = backgroundColor {
                            color
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.blue, lineWidth: (interactingLayer == .background || (interactingLayer == .canvas && activeLayer == .canvas)) ? 3 : 0)
                                )
                                .scaleEffect(bgScale)
                                .offset(bgOffset)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .gesture(layerGesture(for: .background, containerSize: geometry.size))
                    
                    // 2. Foreground Layer (Middle)
                    if let displayImage = (foreground ?? original) {
                        let uiScale = max(geometry.size.width, geometry.size.height) / 1000.0
                        
                        ZStack {
                            Image(uiImage: displayImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            if isCropping, let commit = onCropCommit {
                                CropOverlayView(initialRect: appliedCropRect ?? CGRect(x: 0, y: 0, width: 1, height: 1), onCommit: commit)
                            }
                        }
                        .overlay(
                            Rectangle()
                                .stroke(Color.blue, lineWidth: (interactingLayer == .foreground || (interactingLayer == .canvas && activeLayer == .canvas)) ? 3 : 0)
                        )
                        // Visual Crop Mask: Applied when NOT cropping to show the "cut" effect
                        // without changing the underlying image size or position.
                        .mask(
                            GeometryReader { imageGeo in
                                if let crop = appliedCropRect, !isCropping {
                                    Rectangle()
                                        .frame(
                                            width: crop.width * imageGeo.size.width,
                                            height: crop.height * imageGeo.size.height
                                        )
                                        .position(
                                            x: (crop.minX + crop.width/2) * imageGeo.size.width,
                                            y: (crop.minY + crop.height/2) * imageGeo.size.height
                                        )
                                } else {
                                    Rectangle()
                                }
                            }
                        )
                        .shadow(
                            color: shadowColor.opacity(max(shadowOpacity, 0.4)), // Ensure it's slightly more visible in preview
                            radius: shadowRadius * uiScale,
                            x: shadowX * uiScale,
                            y: shadowY * uiScale
                        )
                        .scaleEffect(fgScale)
                        .offset(fgOffset)
                        .gesture(layerGesture(for: .foreground, containerSize: geometry.size))
                    }
                }
                .rotationEffect(.degrees(rotation))
                .scaleEffect(canvasScale)
                .offset(canvasOffset)
                // Disable hit-testing for the photo when a sticker or text is selected
                // This prevents photo gestures from firing.
                .allowsHitTesting(selectedStickerId == nil && selectedTextId == nil)
                .zIndex(1)
                // --- END CANVAS CONTAINER ---
                
                // --- STICKER OVERLAY LAYER ---
                ZStack {
                    ForEach($stickers) { $sticker in
                        StickerView(
                            sticker: $sticker,
                            containerSize: geometry.size,
                            isSelected: selectedStickerId == sticker.id,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTextId = nil
                                    selectedStickerId = sticker.id
                                }
                            },
                            onDelete: {
                                onDeleteSticker(sticker.id)
                            },
                            parentTransform: getCurrentPhotoTransform(geometry: geometry),
                            calculateSnap: { translation, size in
                                // Switch to Blue guides for Stickers
                                if guideColor != .blue { guideColor = .blue }
                                
                                let transform = getCurrentPhotoTransform(geometry: geometry)
                                let totalScale = transform.canvasScale * transform.fgScale
                                let angle = -transform.rotation * .pi / 180
                                
                                let dx = translation.width / (geometry.size.width * totalScale)
                                let dy = translation.height / (geometry.size.height * totalScale)
                                
                                let projectedCenterX = sticker.position.x + dx * cos(angle) - dy * sin(angle)
                                let projectedCenterY = sticker.position.y + dx * sin(angle) + dy * cos(angle)
                                
                                let normWidth = (size.width * sticker.scale) / (geometry.size.width * totalScale)
                                let normHeight = (size.height * sticker.scale) / (geometry.size.height * totalScale)
                                
                                let halfW = normWidth / 2
                                let halfH = normHeight / 2
                                
                                let edgeMargin: CGFloat = 0.0
                                let snapThreshold: CGFloat = 0.02
                                
                                var snappedCenterX = projectedCenterX
                                var snappedCenterY = projectedCenterY
                                
                                var newShowV = false
                                var newShowH = false
                                var newActiveSnapX: CGFloat? = nil
                                var newActiveSnapY: CGFloat? = nil
                                
                                // X Snapping
                                if abs(projectedCenterX - 0.5) < snapThreshold {
                                    snappedCenterX = 0.5; newShowV = true; newActiveSnapX = 0.5
                                } else {
                                    let projectedLeft = projectedCenterX - halfW
                                    if abs(projectedLeft - 0.0) < snapThreshold {
                                        snappedCenterX = 0.0 + halfW; newShowV = true; newActiveSnapX = 0.0
                                    } else {
                                        let projectedRight = projectedCenterX + halfW
                                        if abs(projectedRight - 1.0) < snapThreshold {
                                            snappedCenterX = 1.0 - halfW; newShowV = true; newActiveSnapX = 1.0
                                        }
                                    }
                                }
                                
                                // Y Snapping
                                if abs(projectedCenterY - 0.5) < snapThreshold {
                                    snappedCenterY = 0.5; newShowH = true; newActiveSnapY = 0.5
                                } else {
                                    let projectedTop = projectedCenterY - halfH
                                    if abs(projectedTop - 0.0) < snapThreshold {
                                        snappedCenterY = 0.0 + halfH; newShowH = true; newActiveSnapY = 0.0
                                    } else {
                                        let projectedBottom = projectedCenterY + halfH
                                        if abs(projectedBottom - 1.0) < snapThreshold {
                                            snappedCenterY = 1.0 - halfH; newShowH = true; newActiveSnapY = 1.0
                                        }
                                    }
                                }
                                
                                let wasV = showVGuide
                                let wasH = showHGuide
                                if (newShowV && !wasV) || (newShowH && !wasH) { hapticFeedback() }
                               
                                DispatchQueue.main.async {
                                    if showVGuide != newShowV { showVGuide = newShowV }
                                    if showHGuide != newShowH { showHGuide = newShowH }
                                    if activeSnapX != newActiveSnapX { activeSnapX = newActiveSnapX }
                                    if activeSnapY != newActiveSnapY { activeSnapY = newActiveSnapY }
                                }
                                
                                let deltaX = snappedCenterX - sticker.position.x
                                let deltaY = snappedCenterY - sticker.position.y
                                let screenDxRatio = deltaX * cos(-angle) - deltaY * sin(-angle)
                                let screenDyRatio = deltaX * sin(-angle) + deltaY * cos(-angle)
                                
                                return CGSize(width: screenDxRatio * (geometry.size.width * totalScale),
                                              height: screenDyRatio * (geometry.size.height * totalScale))
                            },
                            onDragEnd: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showVGuide = false; showHGuide = false
                                    activeSnapX = nil; activeSnapY = nil
                                }
                            }
                        )
                    }
                    // --- ALIGNMENT GUIDES ---
                // --- ALIGNMENT GUIDES ---
                
                // Vertical Lines (Dynamic Position)
                if showVGuide, let snapX = activeSnapX {
                    Rectangle()
                        .fill(guideColor)
                        .frame(width: 1.5, height: geometry.size.height)
                        .position(x: snapX * geometry.size.width, y: geometry.size.height / 2)
                        .transition(.opacity)
                        .zIndex(1001)
                }
                
                // Horizontal Lines (Dynamic Position)
                if showHGuide, let snapY = activeSnapY {
                    Rectangle()
                        .fill(guideColor)
                        .frame(width: geometry.size.width, height: 1.5)
                        .position(x: geometry.size.width / 2, y: snapY * geometry.size.height)
                        .transition(.opacity)
                        .zIndex(1001)
                }
                
                // --- TEXT ITEMS ---
                ForEach($textItems) { $item in
                    TextItemOverlayView(
                        item: $item,
                        containerSize: geometry.size,
                        isSelected: selectedTextId == item.id,
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedStickerId = nil
                                selectedTextId = item.id
                            }
                        },
                        onDelete: { onDeleteText(item.id) },
                        onEdit: { onEditText(item) },
                        isEditing: isEditingText,
                        parentTransform: getCurrentPhotoTransform(geometry: geometry),
                        calculateSnap: { translation, size in
                            // Switch to Yellow guides for Text
                            if guideColor != .yellow { guideColor = .yellow }
                            
                            let transform = getCurrentPhotoTransform(geometry: geometry)
                            let totalScale = transform.canvasScale * transform.fgScale
                            let angle = -transform.rotation * .pi / 180
                            
                            // 1. Calculate Expected Center Position (0.0 to 1.0 coords)
                            let dx = translation.width / (geometry.size.width * totalScale)
                            let dy = translation.height / (geometry.size.height * totalScale)
                            
                            let projectedCenterX = item.position.x + dx * cos(angle) - dy * sin(angle)
                            let projectedCenterY = item.position.y + dx * sin(angle) + dy * cos(angle)
                            
                            // 2. Calculate Item Dimensions in Normalized Coordinates
                            // We need the size of the item relative to the canvas
                            // item.scale affects the size visually
                            let normWidth = (size.width * item.scale) / (geometry.size.width * totalScale)
                            let normHeight = (size.height * item.scale) / (geometry.size.height * totalScale)
                            
                            let halfW = normWidth / 2
                            let halfH = normHeight / 2
                            
                            // 3. Define Potential Snap Points
                            // For X: Center (0.5), Left Edge (0.0 + margin), Right Edge (1.0 - margin)
                            // For Y: Center (0.5), Top Edge (0.0 + margin), Bottom Edge (1.0 - margin)
                            
                            // Margin for "safe area" snapping if desired, or just 0.0/1.0 for strict edges
                            let edgeMargin: CGFloat = 0.0 // 0.05 for 5% margin
                            
                            let snapThreshold: CGFloat = 0.02 // ~2% tolerance
                            
                            var snappedCenterX = projectedCenterX
                            var snappedCenterY = projectedCenterY
                            
                            var newShowV = false
                            var newShowH = false
                            var newActiveSnapX: CGFloat? = nil
                            var newActiveSnapY: CGFloat? = nil
                            
                            // --- X Snapping ---
                            // Strict priority: Center > Edges
                            
                            // 1. Check Center Snap
                            if abs(projectedCenterX - 0.5) < snapThreshold {
                                snappedCenterX = 0.5
                                newShowV = true
                                newActiveSnapX = 0.5
                            } else {
                                // 2. Check Left Edge Snap
                                let projectedLeft = projectedCenterX - halfW
                                let targetLeft = 0.0 + edgeMargin
                                if abs(projectedLeft - targetLeft) < snapThreshold {
                                    snappedCenterX = targetLeft + halfW
                                    newShowV = true
                                    newActiveSnapX = targetLeft
                                } else {
                                    // 3. Check Right Edge Snap
                                    let projectedRight = projectedCenterX + halfW
                                    let targetRight = 1.0 - edgeMargin
                                    if abs(projectedRight - targetRight) < snapThreshold {
                                        snappedCenterX = targetRight - halfW
                                        newShowV = true
                                        newActiveSnapX = targetRight
                                    }
                                }
                            }
                            
                            // --- Y Snapping ---
                            // 1. Check Center Snap
                            if abs(projectedCenterY - 0.5) < snapThreshold {
                                snappedCenterY = 0.5
                                newShowH = true
                                newActiveSnapY = 0.5
                            } else {
                                // 2. Check Top Edge Snap
                                let projectedTop = projectedCenterY - halfH
                                let targetTop = 0.0 + edgeMargin
                                if abs(projectedTop - targetTop) < snapThreshold {
                                    snappedCenterY = targetTop + halfH
                                    newShowH = true
                                    newActiveSnapY = targetTop
                                } else {
                                    // 3. Check Bottom Edge Snap
                                    let projectedBottom = projectedCenterY + halfH
                                    let targetBottom = 1.0 - edgeMargin
                                    if abs(projectedBottom - targetBottom) < snapThreshold {
                                        snappedCenterY = targetBottom - halfH
                                        newShowH = true
                                        newActiveSnapY = targetBottom
                                    }
                                }
                            }
                            
                            // Update Visual State (with animation/haptics)
                            let wasV = showVGuide
                            let wasH = showHGuide
                            
                            if (newShowV && !wasV) || (newShowH && !wasH) {
                                hapticFeedback()
                            }
                           
                            DispatchQueue.main.async {
                                if showVGuide != newShowV { showVGuide = newShowV }
                                if showHGuide != newShowH { showHGuide = newShowH }
                                if activeSnapX != newActiveSnapX { activeSnapX = newActiveSnapX }
                                if activeSnapY != newActiveSnapY { activeSnapY = newActiveSnapY }
                            }
                            
                            // Reverse Calculation
                            let deltaX = snappedCenterX - item.position.x
                            let deltaY = snappedCenterY - item.position.y
                            
                            let screenDxRatio = deltaX * cos(-angle) - deltaY * sin(-angle)
                            let screenDyRatio = deltaX * sin(-angle) + deltaY * cos(-angle)
                            
                            let finalTranslationX = screenDxRatio * (geometry.size.width * totalScale)
                            let finalTranslationY = screenDyRatio * (geometry.size.height * totalScale)
                            
                            return CGSize(width: finalTranslationX, height: finalTranslationY)
                        },
                        onDragEnd: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showVGuide = false
                                showHGuide = false
                                activeSnapX = nil
                                activeSnapY = nil
                            }
                        }
                    )
                    .zIndex(selectedTextId == item.id ? 1000 : 900)
                }
                }
                .coordinateSpace(name: "StickerContainer")
                .zIndex(1000) // Ensure stickers are always on top (Z-index high)
                .allowsHitTesting(!isCropping)
                
                // 3. Guidelines (Top)
                if showVGuide || showHGuide {
                    ZStack {
                        if showVGuide {
                            Rectangle()
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: 1.5)
                                .shadow(color: .blue.opacity(0.5), radius: 5)
                        }
                        
                        if showHGuide {
                            Rectangle()
                                .fill(Color.blue.opacity(0.8))
                                .frame(height: 1.5)
                                .shadow(color: .blue.opacity(0.5), radius: 5)
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
    }
    
    @State private var previousCropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    // MARK: - Gesture Logic
    
    private func layerGesture(for layer: SelectedLayer, containerSize: CGSize) -> some Gesture {
        // If the Canvas tab is active, we force interactions to be Canvas-level 
        // unless the user specifically has a need for individual layers.
        // But the user said "leinwand soll an hintergrand und vordergrand zusammen betreffen",
        // so when activeLayer is .canvas, we should probably prefer canvas gestures.
        
        let targetLayer = (activeLayer == .canvas) ? .canvas : layer
        
        let drag = DragGesture(minimumDistance: 0)
            .onChanged { value in
                if interactingLayer == nil {
                    print("DEBUG: Photo Drag Start on \(targetLayer)")
                    interactingLayer = targetLayer
                    hapticFeedback()
                    
                    // Deselect stickers and text when starting to interact with any image layer
                    if selectedStickerId != nil || selectedTextId != nil {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStickerId = nil
                            selectedTextId = nil
                        }
                    }
                }
                updatePosition(for: targetLayer, translation: value.translation, containerSize: containerSize)
            }
            .onEnded { _ in
                print("DEBUG: Photo Drag End on \(targetLayer)")
                finalizeOffset(for: targetLayer)
                interactingLayer = nil
                withAnimation(.easeOut(duration: 0.2)) {
                    showVGuide = false
                    showHGuide = false
                }
            }
            
        let zoom = MagnificationGesture()
            .onChanged { value in
                // If a sticker or text is selected, we do NOT allow zooming the background
                if selectedStickerId != nil || selectedTextId != nil { 
                    print("DEBUG: Photo Zoom BLOCKED (sticker/text selected)")
                    return 
                }
                
                if interactingLayer == nil {
                    print("DEBUG: Photo Zoom Start on \(targetLayer)")
                    interactingLayer = targetLayer
                    hapticFeedback()
                }
                updateScale(for: targetLayer, value: value)
            }
            .onEnded { _ in
                if selectedStickerId != nil || selectedTextId != nil { return }
                
                print("DEBUG: Photo Zoom End on \(targetLayer)")
                finalizeScale(for: targetLayer)
                interactingLayer = nil
            }
            
        let doubleTap = TapGesture(count: 2)
            .onEnded {
                resetTransform(for: targetLayer)
            }
            
        return drag.simultaneously(with: zoom).simultaneously(with: doubleTap)
    }
    
    private func updatePosition(for layer: SelectedLayer, translation: CGSize, containerSize: CGSize) {
        let newX: CGFloat
        let newY: CGFloat
        
        // Calculate current base offset
        let baseOffsetX: CGFloat
        let baseOffsetY: CGFloat
        
        switch layer {
        case .foreground:
            baseOffsetX = fgLastOffset.width
            baseOffsetY = fgLastOffset.height
        case .background:
            baseOffsetX = bgLastOffset.width
            baseOffsetY = bgLastOffset.height
        case .canvas:
            baseOffsetX = canvasLastOffset.width
            baseOffsetY = canvasLastOffset.height
        }
        
        let predictedX = baseOffsetX + translation.width
        let predictedY = baseOffsetY + translation.height
        
        var finalX = predictedX
        var finalY = predictedY
        
        // --- Snapping Logic for Photo Layers ---
        if layer == .foreground || layer == .background {
            // Switch to Blue Guides for Photos
            if guideColor != .blue { guideColor = .blue }
            
            // 1. Determine Frame Size
            var layerSize = containerSize
            if layer == .foreground, let img = (foreground ?? original) {
                // Foreground is Aspect Fit
                // Calculate projected size
                let widthRatio = containerSize.width / img.size.width
                let heightRatio = containerSize.height / img.size.height
                let scale = min(widthRatio, heightRatio)
                // Also account for user scale (fgScale)
                let currentScale = (layer == .foreground ? fgScale : bgScale) // Use current interactive scale?
                // Actually updatePosition is called WHILE dragging, but fgScale might be updated by zoom as well.
                // Assuming fgScale is the scale applied.
                
                layerSize = CGSize(width: img.size.width * scale * (layer == .foreground ? fgScale : bgScale),
                                   height: img.size.height * scale * (layer == .foreground ? fgScale : bgScale))
            } else {
                 // Background is Aspect Fill - harder to snap edges unless we calculate exact coverage.
                 // For now, let's treat Background center snapping as primary.
                 let currentScale = (layer == .foreground ? fgScale : bgScale)
                 layerSize = CGSize(width: containerSize.width * currentScale, height: containerSize.height * currentScale)
            }
            
            // 2. Calculate projected center position relative to canvas center
            // offset is translation from center.
            let centerX = containerSize.width / 2 + predictedX
            let centerY = containerSize.height / 2 + predictedY
            
            let halfW = layerSize.width / 2
            let halfH = layerSize.height / 2
            
            let snapThreshold: CGFloat = 10.0 // Screen pixels
            
            var snappedX = predictedX
            var snappedY = predictedY
            
            var newShowV = false
            var newShowH = false
            var newActiveSnapX: CGFloat? = nil
            var newActiveSnapY: CGFloat? = nil
            
            // X Snapping
             // Center
            if abs(predictedX) < snapThreshold {
                snappedX = 0
                newShowV = true; newActiveSnapX = 0.5
            } else {
                // Left Edge relative to Canvas Left
                // Canvas Left is 0. Projected Left is centerX - halfW.
                let projectedLeft = centerX - halfW
                if abs(projectedLeft) < snapThreshold {
                    snappedX = predictedX - projectedLeft // shift back to make projectedLeft 0
                    newShowV = true; newActiveSnapX = 0.0
                } else {
                    // Right Edge relative to Canvas Right
                    let projectedRight = centerX + halfW
                    if abs(projectedRight - containerSize.width) < snapThreshold {
                         snappedX = predictedX - (projectedRight - containerSize.width)
                         newShowV = true; newActiveSnapX = 1.0
                    }
                }
            }
            
            // Y Snapping
             // Center
            if abs(predictedY) < snapThreshold {
                snappedY = 0
                newShowH = true; newActiveSnapY = 0.5
            } else {
                // Top Edge
                let projectedTop = centerY - halfH
                if abs(projectedTop) < snapThreshold {
                    snappedY = predictedY - projectedTop
                    newShowH = true; newActiveSnapY = 0.0
                } else {
                     // Bottom Edge
                     let projectedBottom = centerY + halfH
                     if abs(projectedBottom - containerSize.height) < snapThreshold {
                         snappedY = predictedY - (projectedBottom - containerSize.height)
                         newShowH = true; newActiveSnapY = 1.0
                     }
                }
            }
            
            let wasV = showVGuide
            let wasH = showHGuide
            if (newShowV && !wasV) || (newShowH && !wasH) { hapticFeedback() }
            
            // Update UI State on Main Thread if needed, or directly since we are in a closure?
            // Drag onChanged is usually on main thread.
            if showVGuide != newShowV { showVGuide = newShowV }
            if showHGuide != newShowH { showHGuide = newShowH }
            if activeSnapX != newActiveSnapX { activeSnapX = newActiveSnapX }
            if activeSnapY != newActiveSnapY { activeSnapY = newActiveSnapY }
            
            finalX = snappedX
            finalY = snappedY
        }
        
        switch layer {
        case .foreground:
            fgOffset = CGSize(width: finalX, height: finalY)
        case .background:
            bgOffset = CGSize(width: finalX, height: finalY)
        case .canvas:
            canvasOffset = CGSize(width: finalX, height: finalY)
        }
    }
    
    private func finalizeOffset(for layer: SelectedLayer) {
        switch layer {
        case .foreground: fgLastOffset = fgOffset
        case .background: bgLastOffset = bgOffset
        case .canvas: canvasLastOffset = canvasOffset
        }
    }
    
    private func updateScale(for layer: SelectedLayer, value: CGFloat) {
        switch layer {
        case .foreground: fgScale = fgLastScale * value
        case .background: bgScale = bgLastScale * value
        case .canvas: canvasScale = canvasLastScale * value
        }
    }
    
    private func finalizeScale(for layer: SelectedLayer) {
        switch layer {
        case .foreground: fgLastScale = fgScale
        case .background: bgLastScale = bgScale
        case .canvas: canvasLastScale = canvasScale
        }
    }
    
    private func resetTransform(for layer: SelectedLayer) {
        withAnimation(.spring()) {
            switch layer {
            case .foreground:
                fgScale = 1.0; fgLastScale = 1.0; fgOffset = .zero; fgLastOffset = .zero
            case .background:
                bgScale = 1.0; bgLastScale = 1.0; bgOffset = .zero; bgLastOffset = .zero
            case .canvas:
                canvasScale = 1.0; canvasLastScale = 1.0; canvasOffset = .zero; canvasLastOffset = .zero
            }
            showVGuide = false
            showHGuide = false
        }
        hapticFeedback()
    }
    
    // Helper to calculate the current transformation state of the photo content
    private func getCurrentPhotoTransform(geometry: GeometryProxy) -> PhotoTransform {
        // Combined transformation: Rotation -> Canvas Scale/Offset -> FG Scale/Offset
        // For positions, we need to know how a normalized (0-1) point in the PHOTO 
        // maps to the SCREEN.
        
        return PhotoTransform(
            canvasOffset: canvasOffset,
            canvasScale: canvasScale,
            fgOffset: fgOffset,
            fgScale: fgScale,
            rotation: rotation
        )
    }
}

struct PhotoTransform: Equatable {
    let canvasOffset: CGSize
    let canvasScale: CGFloat
    let fgOffset: CGSize
    let fgScale: CGFloat
    let rotation: CGFloat
}

struct StickerView: View {
    @Binding var sticker: Sticker
    let containerSize: CGSize
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let parentTransform: PhotoTransform
    let calculateSnap: (CGSize, CGSize) -> CGSize
    let onDragEnd: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    
    // Content Measurement
    @State private var contentSize: CGSize = .zero
    
    // For single-finger resize handle
    @State private var initialHandleDistance: CGFloat = 1.0
    @State private var initialHandleAngle: Angle = .zero
    @State private var initialStickerScale: CGFloat = 1.0
    @State private var initialStickerRotation: Angle = .zero
    
    // Calculate the actual screen position based on photo transformation
    private var screenPosition: CGPoint {
        // 1. Center of the container
        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2
        
        // 2. Relative position of the sticker on the photo (0...1) converted to -0.5...0.5
        let rx = sticker.position.x - 0.5
        let ry = sticker.position.y - 0.5
        
        // 3. Apply scales (photo's own scale and canvas scale)
        let totalScale = parentTransform.canvasScale * parentTransform.fgScale
        let sx = rx * containerSize.width * totalScale
        let sy = ry * containerSize.height * totalScale
        
        // 4. Apply rotation (if the parent content is rotated)
        let angle = parentTransform.rotation * .pi / 180
        let cosA = cos(angle)
        let sinA = sin(angle)
        
        let rotatedX = sx * cosA - sy * sinA
        let rotatedY = sx * sinA + sy * cosA
        
        // 5. Apply offsets (fgOffset and canvasOffset)
        // We need to account for the fact that offsets are scaled by the canvasScale? 
        // Actually, ZoomableImageView applies offset(canvasOffset).scaleEffect(canvasScale).
        // So canvasOffset is in unscaled points.
        
        let tx = centerX + rotatedX + parentTransform.fgOffset.width * parentTransform.canvasScale + parentTransform.canvasOffset.width + dragOffset.width
        let ty = centerY + rotatedY + parentTransform.fgOffset.height * parentTransform.canvasScale + parentTransform.canvasOffset.height + dragOffset.height
        
        return CGPoint(x: tx, y: ty)
    }
    
    var body: some View {
        ZStack {
            // Content Group (Hit Area + Text) - This listens for MOVE gestures
            ZStack {
                // Invisible larger hit area for easier selection
                Color.black.opacity(0.001)
                    .frame(width: 100, height: 100)
                    .contentShape(Rectangle())
                
                Text(sticker.content)
                    .font(.system(size: 60))
                    .padding(15)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { contentSize = proxy.size }
                                .onChange(of: sticker.content) { _ in contentSize = proxy.size }
                        }
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.clear, style: StrokeStyle(lineWidth: 3, dash: [8, 4]))
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    )
            }
            // Apply scale/rotation to the visuals
            .scaleEffect(sticker.scale * currentScale)
            .rotationEffect(sticker.rotation + currentRotation)
            // Apply MOVE gesture ONLY to this content group
            .onTapGesture {
                print("DEBUG: Sticker tapped (\(sticker.content))")
                onSelect()
                hapticFeedback()
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("StickerContainer"))
                    .onChanged { value in
                        if dragOffset == .zero {
                            print("DEBUG: Sticker Drag Start (\(sticker.content))")
                            onSelect()
                            hapticFeedback()
                        }
                        
                        // Calculate snapped offset via parent
                        // Pass current Size to the snap function
                        let snappedTranslation = calculateSnap(value.translation, contentSize)
                        dragOffset = snappedTranslation
                    }
                    .onEnded { value in
                        print("DEBUG: Sticker Drag End (\(sticker.content))")
                        let totalScale = parentTransform.canvasScale * parentTransform.fgScale
                        let angle = -parentTransform.rotation * .pi / 180
                        
                        // Use dragOffset (snapped)
                        let dx = dragOffset.width / (containerSize.width * totalScale)
                        let dy = dragOffset.height / (containerSize.height * totalScale)
                        
                        let rotatedDX = dx * cos(angle) - dy * sin(angle)
                        let rotatedDY = dx * sin(angle) + dy * cos(angle)
                        sticker.position.x += rotatedDX
                        sticker.position.y += rotatedDY
                        dragOffset = .zero
                        
                        onDragEnd()
                    }

                .simultaneously(with: 
                    MagnificationGesture()
                        .onChanged { value in
                            if !isSelected { return }
                            if currentScale == 1.0 { print("DEBUG: Sticker Zoom Start (\(sticker.content))") }
                            currentScale = value
                        }
                        .onEnded { value in
                            if !isSelected { return }
                            print("DEBUG: Sticker Zoom End (\(sticker.content))")
                            sticker.scale *= value
                            currentScale = 1.0
                        }
                )
                .simultaneously(with: 
                    RotationGesture()
                        .onChanged { value in
                            if !isSelected { return }
                            if currentRotation == .zero { print("DEBUG: Sticker Rotation Start (\(sticker.content))") }
                            currentRotation = value
                        }
                        .onEnded { value in
                            if !isSelected { return }
                            print("DEBUG: Sticker Rotation End (\(sticker.content))")
                            sticker.rotation += value
                            currentRotation = .zero
                        }
                )
            )
            
            // Handles are overlayed but NOT affected by the move gesture above.
            // They need to track the position/rotation/scale of the sticker visually.
            if isSelected {
                selectionHandles
                    .scaleEffect(sticker.scale * currentScale)
                    .rotationEffect(sticker.rotation + currentRotation)
            }
        }
        .position(screenPosition)
    }
    
    private var selectionHandles: some View {
        ZStack {
            // Visualize 3 corners
            Circle().fill(.white).frame(width: 8, height: 8).offset(x: 45, y: -45)
            Circle().fill(.white).frame(width: 8, height: 8).offset(x: -45, y: 45)
            
            // Top Left Handle: Delete Button
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 28, height: 28)
                    .shadow(radius: 2)
                
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: -45, y: -45)
            .onTapGesture {
                print("DEBUG: Delete handle tapped")
                hapticFeedback()
                onDelete()
            }
            
            // Bottom Right Handle: Interactive Resize & Rotate
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 28, height: 28)
                    .shadow(radius: 2)
                
                Image(systemName: "arrow.up.left.and.arrow.down.right.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.white)
            }
            .offset(x: 45, y: 45)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("StickerContainer"))
                    .onChanged { value in
                        let center = screenPosition
                        let touch = value.location
                        
                        // Calculate vector from center to touch point
                        let dx = touch.x - center.x
                        let dy = touch.y - center.y
                        
                        let distance = sqrt(dx*dx + dy*dy)
                        let angle = Angle(radians: Double(atan2(dy, dx)))
                        
                        if initialHandleDistance == 1.0 { // Start of gesture
                            print("DEBUG: Resize Handle Start")
                            initialHandleDistance = distance
                            initialHandleAngle = angle
                            initialStickerScale = sticker.scale
                            initialStickerRotation = sticker.rotation
                            hapticFeedback()
                        }
                        
                        // 1. Update Scale (relative to initial distance)
                        // Guard against division by zero
                        if initialHandleDistance > 0 {
                            let newScale = initialStickerScale * (distance / initialHandleDistance)
                            sticker.scale = max(0.1, min(10.0, newScale))
                        }
                        
                        // 2. Update Rotation (relative to initial angle)
                        let deltaAngle = angle - initialHandleAngle
                        sticker.rotation = initialStickerRotation + deltaAngle
                    }
                    .onEnded { _ in
                        print("DEBUG: Resize Handle End")
                        initialHandleDistance = 1.0
                        initialHandleAngle = .zero
                        hapticFeedback()
                    }
            )
        }
    }
}
struct TextItemOverlayView: View {
    @Binding var item: TextItem
    let containerSize: CGSize
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let isEditing: Bool
    let parentTransform: PhotoTransform
    let calculateSnap: (CGSize, CGSize) -> CGSize
    let onDragEnd: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    
    // For single-finger resize handle
    @State private var initialHandleDistance: CGFloat = 1.0
    @State private var initialHandleAngle: Angle = .zero
    @State private var initialItemScale: CGFloat = 1.0
    @State private var initialItemRotation: Angle = .zero
    
    // Size for handle positioning
    @State private var contentSize: CGSize = .zero
    
    private var screenPosition: CGPoint {
        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2
        let rx = item.position.x - 0.5
        let ry = item.position.y - 0.5
        let totalScale = parentTransform.canvasScale * parentTransform.fgScale
        let sx = rx * containerSize.width * totalScale
        let sy = ry * containerSize.height * totalScale
        let angle = parentTransform.rotation * .pi / 180
        let cosA = cos(angle)
        let sinA = sin(angle)
        let rotatedX = sx * cosA - sy * sinA
        let rotatedY = sx * sinA + sy * cosA
        let tx = centerX + rotatedX + parentTransform.fgOffset.width * parentTransform.canvasScale + parentTransform.canvasOffset.width + dragOffset.width
        let ty = centerY + rotatedY + parentTransform.fgOffset.height * parentTransform.canvasScale + parentTransform.canvasOffset.height + dragOffset.height
        return CGPoint(x: tx, y: ty)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Text(item.text)
                    .font(.custom(item.fontName, size: 40))
                    .foregroundColor(item.color)
                    .multilineTextAlignment(mapAlignment(item.alignment))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if item.backgroundStyle != .none {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(item.backgroundColor.opacity(item.backgroundStyle == .solid ? 1.0 : 0.6))
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected && !isEditing ? Color.white : Color.clear, style: StrokeStyle(lineWidth: 3, dash: [8, 4]))
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    )
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { contentSize = proxy.size }
                                .onChange(of: item.text) { _ in contentSize = proxy.size }
                                .onChange(of: item.fontName) { _ in contentSize = proxy.size }
                        }
                    )
                    .contentShape(Rectangle()) // Ensure the whole area is tappable
            }
            .opacity(isSelected && isEditing ? 0 : 1) // Hide when editing to avoid duplicates
            .scaleEffect(item.scale * currentScale)
            .rotationEffect(item.rotation + currentRotation)
            .onTapGesture {
                if isSelected {
                    onEdit()
                } else {
                    onSelect()
                }
                hapticFeedback()
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .named("StickerContainer"))
                    .onChanged { value in
                        if dragOffset == .zero {
                            onSelect()
                            hapticFeedback()
                            hapticFeedback()
                        }
                        
                        
                        // Calculate snapped offset via parent
                        // Pass current Size to the snap function
                        let snappedTranslation = calculateSnap(value.translation, contentSize)
                        dragOffset = snappedTranslation
                    }
                    .onEnded { value in
                        // Use the final snapped translation for the commit
                        // Re-calculate one last time or store the last snapped value?
                        // Better to re-calculate to be safe, or just use dragOffset which IS the snapped value now.
                        
                        let totalScale = parentTransform.canvasScale * parentTransform.fgScale
                        let angle = -parentTransform.rotation * .pi / 180
                        
                        // Use dragOffset (which is snapped) instead of value.translation (raw)
                        let dx = dragOffset.width / (containerSize.width * totalScale)
                        let dy = dragOffset.height / (containerSize.height * totalScale)
                        
                        item.position.x += dx * cos(angle) - dy * sin(angle)
                        item.position.y += dx * sin(angle) + dy * cos(angle)
                        dragOffset = .zero
                        
                        onDragEnd()
                    }
                .simultaneously(with: 
                    MagnificationGesture()
                        .onChanged { value in
                            if !isSelected { return }
                            currentScale = value
                        }
                        .onEnded { value in
                            if !isSelected { return }
                            item.scale *= value
                            currentScale = 1.0
                        }
                )
                .simultaneously(with: 
                    RotationGesture()
                        .onChanged { value in
                            if !isSelected { return }
                            currentRotation = value
                        }
                        .onEnded { value in
                            if !isSelected { return }
                            item.rotation += value
                            currentRotation = .zero
                        }
                )
            )
            
            if isSelected && !isEditing {
                selectionHandles
                    .scaleEffect(item.scale * currentScale)
                    .rotationEffect(item.rotation + currentRotation)
            }
        }
        .position(screenPosition)
    }
    
    private var selectionHandles: some View {
        ZStack {
            ZStack {
                Circle().fill(Color.red).frame(width: 28, height: 28).shadow(radius: 2)
                Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            }
            .offset(x: -contentSize.width/2, y: -contentSize.height/2)
            .onTapGesture {
                hapticFeedback()
                onDelete()
            }
            
            ZStack {
                Circle().fill(Color.blue).frame(width: 28, height: 28).shadow(radius: 2)
                Image(systemName: "arrow.up.left.and.arrow.down.right.circle.fill")
                    .resizable().frame(width: 28, height: 28).foregroundColor(.white)
            }
            .offset(x: contentSize.width/2, y: contentSize.height/2)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("StickerContainer"))
                    .onChanged { value in
                        let center = screenPosition
                        let touch = value.location
                        let dx = touch.x - center.x
                        let dy = touch.y - center.y
                        let distance = sqrt(dx*dx + dy*dy)
                        let angle = Angle(radians: Double(atan2(dy, dx)))
                        
                        if initialHandleDistance == 1.0 {
                            initialHandleDistance = distance
                            initialHandleAngle = angle
                            initialItemScale = item.scale
                            initialItemRotation = item.rotation
                            hapticFeedback()
                        }
                        
                        if initialHandleDistance > 0 {
                            item.scale = max(0.1, min(10.0, initialItemScale * (distance / initialHandleDistance)))
                        }
                        item.rotation = initialItemRotation + (angle - initialHandleAngle)
                    }
                    .onEnded { _ in
                        initialHandleDistance = 1.0
                        hapticFeedback()
                    }
            )
        }
    }
    
    private func mapAlignment(_ alignment: TextAlignment) -> SwiftUI.TextAlignment {
        switch alignment {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}
