//
//  EditorView.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI
import Combine



enum ColorPickerTab: String, CaseIterable, Identifiable {
    case presets, gradients, transparent
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .presets: return "Presets"
        case .gradients: return "Verläufe"
        case .transparent: return "Transparent"
        }
    }
    
    var iconName: String {
        switch self {
        case .presets: return "circle.grid.2x2"
        case .gradients: return "slider.horizontal.2.square"
        case .transparent: return "circle.dotted"
        }
    }
}

struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
    @State private var selectedAdjustmentParameter: AdjustmentParameter? = nil
    @State private var selectedColorPicker: ColorPickerTab? = nil
    @State private var selectedShadowParameter: ShadowParameter? = nil
    @State private var showingSaveAlert = false
    @State private var saveMessage: LocalizedStringKey = ""
    @State private var showingUnsplashPicker = false
    @State private var showingExitAlert = false
    @State private var isShowingOriginal = false
    @State private var tempTextItem: TextItem? = nil
    @Environment(\.dismiss) private var dismiss
    
    let selectedImage: UIImage?
    let project: Project?
    
    init(image: UIImage? = nil, project: Project? = nil) {
        self.selectedImage = image
        self.project = project
    }
    
    var body: some View {
        ZStack {
            photoArea
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 0) // Full bleed
                .safeAreaInset(edge: .top, spacing: 0) {
                    navigationBar
                        .opacity(viewModel.showingTextEditor ? 0 : 1)
                        .allowsHitTesting(!viewModel.showingTextEditor)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    bottomBar
                        .opacity(viewModel.showingTextEditor ? 0 : 1)
                        .allowsHitTesting(!viewModel.showingTextEditor)
                }
                .background(Color.white.ignoresSafeArea())
                .ignoresSafeArea(.keyboard)
                .navigationBarHidden(true)
                .preferredColorScheme(.light)
                .onAppear {
                    if let project = project {
                        viewModel.loadProject(project)
                    } else if let image = selectedImage {
                        viewModel.setImage(image)
                    }
                }
            
            // Save Status HUD removed as per user request
            // VStack { ... }
            
            if viewModel.showingTextEditor, let item = tempTextItem {
                TextEditorOverlay(
                    textItem: Binding(
                        get: { tempTextItem ?? item },
                        set: { tempTextItem = $0 }
                    ),
                    onDone: {
                        if let updated = tempTextItem {
                            // Always update since we add the item immediately when creating
                            if !updated.text.isEmpty {
                                viewModel.updateTextItem(updated)
                            } else {
                                // If text is empty, remove the item
                                viewModel.removeTextItem(id: updated.id)
                            }
                        }
                        withAnimation(AppMotion.snappy) {
                            viewModel.showingTextEditor = false
                        }
                        tempTextItem = nil
                    },
                    onCancel: {
                        // Remove the item if user cancels
                        if let item = tempTextItem {
                            viewModel.removeTextItem(id: item.id)
                        }
                        withAnimation(AppMotion.snappy) {
                            viewModel.showingTextEditor = false
                        }
                        tempTextItem = nil
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2000)
            }
        }
        .alert("Editor verlassen?", isPresented: $showingExitAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Speichern & Schließen", role: .destructive) {
                viewModel.saveProject { _, _ in
                    dismiss()
                }
            }
            Button("Projekt löschen", role: .destructive) {
                viewModel.deleteCurrentProject()
                dismiss()
            }
        } message: {
            Text("Möchten Sie die Bearbeitung beenden? Ihre Änderungen werden beim Schließen gespeichert.")
        }
        .sheet(isPresented: $viewModel.showingEmojiPicker) {
            EmojiPickerView(onSelected: { content, type, color in
                viewModel.addSticker(content, type: type, color: color)
                viewModel.showingEmojiPicker = false
            })
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingUnsplashPicker) {
            UnsplashPickerView(onSelect: { image in
                viewModel.setBackgroundImage(image)
                showingUnsplashPicker = false
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var bottomBar: some View {
        ZStack {
            if let tab = viewModel.selectedTab {
                // Detail Bar
                HStack(spacing: 0) {
                    // Separated Back Button
                    InteractiveButton(haptic: false, action: {
                        withAnimation(AppMotion.snappy) {
                            if let _ = selectedAdjustmentParameter {
                                selectedAdjustmentParameter = nil
                            } else if let _ = selectedColorPicker {
                                selectedColorPicker = nil
                            } else if let _ = selectedShadowParameter {
                                selectedShadowParameter = nil
                            } else {
                                if viewModel.selectedTab == .crop {
                                    viewModel.cancelCropping()
                                }
                                viewModel.selectedTab = nil
                            }
                        }
                    }) {
                        HStack(spacing: 0) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 50, height: 90)
                            
                            Divider()
                                .frame(height: 30)
                                .background(Color.primary.opacity(0.1))
                        }
                        .background(Color.white.opacity(0.4))
                        .background(.ultraThinMaterial)
                    }
                    
                    tabContent(for: tab)
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .trailing))
                }
            } else {
                // Main Tab Bar
                tabBar
                    .transition(.move(edge: .leading))
            }
        }
        .frame(height: 90)
        .background(Color.white.opacity(0.8).ignoresSafeArea(edges: .bottom))
        .background(.ultraThinMaterial, ignoresSafeAreaEdges: .bottom)
    }
    
    private var saveStatusHUD: some View {
        Group {
            if viewModel.saveStatus != .idle {
                HStack(spacing: 8) {
                    if viewModel.saveStatus == .saving {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14, weight: .bold))
                    }
                    
                    Text(viewModel.saveStatus == .saving ? "Speichere..." : "Änderungen gespeichert")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.saveStatus)
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                InteractiveButton(action: {
                    AppHaptics.medium()
                    showingExitAlert = true
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }

                InteractiveButton(action: {
                    viewModel.saveProject { success, message in
                        if !success {
                            saveMessage = message
                            showingSaveAlert = true
                        } else {
                            AppHaptics.success()
                        }
                    }
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                InteractiveButton(action: {
                    viewModel.shareImage()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                
                Menu {
                    InteractiveButton(haptic: false, action: {
                        viewModel.saveToGallery(format: .png) { success, message in
                            saveMessage = message
                            showingSaveAlert = true
                            if success { AppHaptics.success() }
                        }
                    }) {
                        Label {
                            Text("Als PNG speichern") + (viewModel.isBackgroundTransparent ? (Text(" (") + Text("Sticker") + Text(")")) : Text(""))
                        } icon: {
                            Image(systemName: "doc.richtext")
                        }
                    }
                    
                    InteractiveButton(haptic: false, action: {
                        viewModel.saveToGallery(format: .jpg) { success, message in
                            saveMessage = message
                            showingSaveAlert = true
                            if success { AppHaptics.success() }
                        }
                    }) {
                        Label {
                            Text("Als JPG speichern") + (!viewModel.isBackgroundTransparent ? (Text(" (") + Text("Empfohlen") + Text(")")) : Text(""))
                        } icon: {
                            Image(systemName: "photo")
                        }
                    }
                    

                } label: {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
            }
            
            Text("Bearbeiten")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        .zIndex(100) // Ensure nav bar stays on top of content
    }
    
    private var photoArea: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 2 // Considering horizontal padding
            let availableHeight = geometry.size.height
            
            // Base image aspect ratio (stable, using original image)
            let rawOriginalAspectRatio = (viewModel.originalImage?.size ?? CGSize(width: 1, height: 1)).width / (viewModel.originalImage?.size ?? CGSize(width: 1, height: 1)).height
            let originalImageAspectRatio = (Int(viewModel.rotation) % 180 != 0) ? (1.0 / rawOriginalAspectRatio) : rawOriginalAspectRatio

            // Current display image (might be cropped)
            // Use fullProcessedImage specifically when CROPPING to allow boundary adjustments
            let displayImage: UIImage? = {
                if isShowingOriginal { return viewModel.originalImage }
                // Always use the FULL processed image in the editor display
                // to keep dimensions stable. ZoomableImageView will mask it.
                return viewModel.fullProcessedImage ?? viewModel.originalImage
            }() ?? viewModel.originalImage
            
            // Determine the target aspect ratio for the CANVAS container
            let isStickerMode = viewModel.selectedTab == .stickers || (viewModel.selectedAspectRatio == .original && viewModel.isStickerModeActive)
            let targetAspectRatio: CGFloat = {
                if isStickerMode {
                    return 1.0 // Force square for stickers (active or legacy)
                }
                if let ratio = viewModel.selectedAspectRatio.ratio {
                    return ratio
                }
                // Use the ORIGINAL image aspect ratio as the base for the canvas
                // to prevent it from resizing when the processed image (crop) changes.
                return originalImageAspectRatio
            }()
            
            let containerAspectRatio = availableWidth / availableHeight
            
            let baseFitSize: CGSize = {
                if targetAspectRatio > containerAspectRatio {
                    // Width is limiting
                    return CGSize(width: availableWidth, height: availableWidth / targetAspectRatio)
                } else {
                    // Height is limiting
                    return CGSize(width: availableHeight * targetAspectRatio, height: availableHeight)
                }
            }()
            
            // Apply sticker UI scaling if in sticker mode
            let fitSize = isStickerMode ? CGSize(width: baseFitSize.width * viewModel.stickerUIScale, height: baseFitSize.height * viewModel.stickerUIScale) : baseFitSize
            
            ZStack {
                Color.clear
                
                ZStack {
                    // ADDED: Sticker Container Background
                    if isStickerMode {
                        ZStack {
                            // Checkerboard
                            Image(systemName: "checkerboard.rectangle")
                                .resizable()
                                .foregroundColor(.gray.opacity(0.1))
                                .background(Color.white)
                            
                            // Visual border
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        }
                        .frame(width: fitSize.width, height: fitSize.height)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }

                    if let original = viewModel.originalImage {
                        ZoomableImageView(
                            foreground: displayImage, // Show the processed foreground (without background baked in)
                            background: viewModel.backgroundImage,
                            original: original,
                            backgroundColor: viewModel.backgroundColor,
                            gradientColors: viewModel.gradientColors,
                            activeLayer: .foreground, // Treat as single layer
                            rotation: viewModel.rotation,
                            isCropping: viewModel.isCropping,
                            appliedCropRect: viewModel.appliedCropRect,
                            onCropCommit: { rect in
                                viewModel.applyCrop(rect)
                            },
                            stickers: $viewModel.stickers,
                            selectedStickerId: $viewModel.selectedStickerId,
                            onDeleteSticker: { id in
                                viewModel.removeSticker(id: id)
                            },
                            textItems: $viewModel.textItems,
                            selectedTextId: $viewModel.selectedTextId,
                            onDeleteText: { id in
                                viewModel.removeTextItem(id: id)
                            },
                            onEditText: { item in
                                tempTextItem = item
                                withAnimation(AppMotion.snappy) {
                                    viewModel.showingTextEditor = true
                                }
                            },
                            isEditingText: viewModel.showingTextEditor,
                            persistentSelection: viewModel.selectedTab == .stickers || viewModel.selectedTab == .crop,
                            shadowRadius: viewModel.shadowRadius,
                            shadowX: viewModel.shadowX,
                            shadowY: viewModel.shadowY,
                            shadowColor: viewModel.shadowColor,
                            shadowOpacity: viewModel.shadowOpacity,
                            fgScale: $viewModel.fgScale,
                            fgOffset: $viewModel.fgOffset,
                            bgScale: $viewModel.bgScale,
                            bgOffset: $viewModel.bgOffset,
                            canvasScale: $viewModel.canvasScale,
                            canvasOffset: $viewModel.canvasOffset,
                            targetEditorScale: viewModel.targetEditorScale
                        )
                        .id("photo-\(viewModel.rotation)-\(viewModel.originalImage?.hashValue ?? 0)")
                    }
                    
                    if viewModel.isRemovingBackground {
                        ZStack {
                            Color.white.opacity(0.7)
                            
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                                    .scaleEffect(1.2)
                                
                                Text("Hintergrund wird entfernt...")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                    }
                }
                .frame(width: fitSize.width, height: fitSize.height)
                .background(Color(white: 0.95))
                .clipped()
                .onChange(of: fitSize) { newSize in
                    viewModel.uiCanvasSize = newSize
                }
                .onAppear {
                    viewModel.uiCanvasSize = fitSize
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                rotationControls
                    .padding(.bottom, 24)
                    .opacity(viewModel.showingTextEditor ? 0 : 1)
                    .allowsHitTesting(!viewModel.showingTextEditor)
            }
            .overlay(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    compareButton
                    textButton
                    stickerButton
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                .opacity(viewModel.showingTextEditor ? 0 : 1)
                .allowsHitTesting(!viewModel.showingTextEditor)
            }
        }
    }
    
    private var rotationControls: some View {
        HStack(spacing: 8) {
            // History Group
            HStack(spacing: 0) {
                InteractiveButton(action: {
                    viewModel.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.canUndo ? .primary : .primary.opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                .disabled(!viewModel.canUndo)
                
                Divider()
                    .frame(height: 20)
                    .background(Color.primary.opacity(0.2))
                
                InteractiveButton(action: {
                    viewModel.redo()
                }) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.canRedo ? .primary : .primary.opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                .disabled(!viewModel.canRedo)
            }
            .background(Color.white.opacity(0.7))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Rotation Group
            HStack(spacing: 0) {
                InteractiveButton(action: {
                    viewModel.rotateLeft()
                }) {
                    Image(systemName: "rotate.left")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                
                Divider()
                    .frame(height: 20)
                    .background(Color.primary.opacity(0.2))
                
                InteractiveButton(action: {
                    viewModel.rotateRight()
                }) {
                    Image(systemName: "rotate.right")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
            }
            .background(Color.white.opacity(0.7))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var compareButton: some View {
        ZStack {
            Image(systemName: "square.split.2x1")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isShowingOriginal ? .blue : .primary)
                .frame(width: 44, height: 44)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isShowingOriginal {
                        AppHaptics.medium()
                        withAnimation(AppMotion.snappy) {
                            isShowingOriginal = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(AppMotion.snappy) {
                        isShowingOriginal = false
                    }
                }
        )
    }
    
    private var textButton: some View {
        InteractiveButton(action: {
            let newItem = TextItem()
            tempTextItem = newItem
            viewModel.addTextItem(newItem) // Add immediately so it appears on canvas
            withAnimation(AppMotion.snappy) {
                viewModel.showingTextEditor = true
            }
        }) {
            Image(systemName: "t.square")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
    
    private var stickerButton: some View {
        InteractiveButton(action: {
            viewModel.showingEmojiPicker = true
        }) {
            Image(systemName: "face.smiling")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
    
    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(EditorTab.allCases) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: viewModel.selectedTab == tab,
                        isActive: isTabActive(tab),
                        action: {
                            viewModel.cancelCropping() // Reset crop mode on tab change
                            withAnimation(AppMotion.snappy) {
                                if tab == .unsplash {
                                    showingUnsplashPicker = true
                                } else {
                                    viewModel.selectedTab = tab
                                    if tab == .stickers {
                                        viewModel.stickerFlowStep = .size
                                    }
                                }
                            }
                        }
                    )
                    .frame(width: UIScreen.main.bounds.width / 5) // Ensure 5 units fit or slightly less for peeking
                }
            }
            .padding(.horizontal, 10)
            .scrollDiscoveryNudge()
        }
        .fadedEdge(leading: false, trailing: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    
    private func isTabActive(_ tab: EditorTab) -> Bool {
        switch tab {
        case .crop: return viewModel.isCanvasActive
        case .filter: return viewModel.isFilterActive
        case .adjust: return viewModel.isAdjustActive
        case .colors: return viewModel.isColorActive
        case .shadow: return viewModel.isShadowActive
        case .stickers: return viewModel.stickerOutlineWidth > 0
        case .unsplash: return false
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: EditorTab) -> some View {
        switch tab {
        case .crop:
            CanvasTabView(viewModel: viewModel)
        case .filter:
            FilterTabView(viewModel: viewModel)
        case .adjust:
            AdjustmentTabView(viewModel: viewModel, selectedParameter: $selectedAdjustmentParameter)
        case .colors:
            ColorsTabView(viewModel: viewModel, selectedPicker: $selectedColorPicker)
        case .shadow:
            ShadowTabView(viewModel: viewModel, selectedParameter: $selectedShadowParameter)
        case .stickers:
            StickerExportTabView(viewModel: viewModel)
        case .unsplash:
            EmptyView()
        }
    }


    

}

struct StickerExportTabView: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var shareSheetItem: ShareItem?
    @State private var showingColorPicker = false
    
    struct ShareItem: Identifiable {
        let id = UUID()
        let image: UIImage
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            
            HStack(spacing: 6) {
                sizeButton(size: 512, label: "512*512 px")
                sizeButton(size: 96, label: "96*96 px")
                sizeButton(size: 21, label: "21*21 px")
                
                // System Color Picker Button
                InteractiveButton(action: {
                    showingColorPicker = true
                }) {
                    ZStack {
                        // Visual Indicator
                        Circle()
                            .fill(AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red], center: .center))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .sheet(item: $shareSheetItem) { item in
            ShareSheet(activityItems: [item.image])
        }
        .sheet(isPresented: $showingColorPicker) {
            SpectrumColorPickerView(color: $viewModel.stickerOutlineColor)
                .presentationDetents([.fraction(0.45), .medium])
                .presentationDragIndicator(.visible)
        }
    }
    private func sizeButton(size: CGFloat, label: String) -> some View {
        InteractiveButton(action: {
            withAnimation(AppMotion.snappy) {
                viewModel.applyStickerSize(size)
            }
            AppHaptics.light()
        }) {
            Text(label)
                .font(.system(size: 11, weight: .bold)) // Compact font for single-screen fit
                .foregroundColor(viewModel.stickerSize == size ? .white : .primary)
                .frame(width: 76, height: 44)
                .background(
                    ZStack {
                        if viewModel.stickerSize == size {
                            LinearGradient(colors: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        } else {
                            Color.primary.opacity(0.06)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.stickerSize == size ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: viewModel.stickerSize == size ? Color.blue.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
        }
    }
}

struct TabButton: View {
    let tab: EditorTab
    let isSelected: Bool
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        InteractiveButton(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.iconName)
                        .font(.system(size: isSelected ? 24 : 22, weight: isSelected ? .semibold : .regular))
                        .frame(width: 28, height: 28)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(AppMotion.bouncy, value: isSelected)
                    
                    if isActive {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                            .offset(x: 4, y: -4)
                    }
                }
                
                Text(tab.localizedName)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .blue : .primary.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

struct PlaceholderTabView: View {
    let tabName: String
    
    var body: some View {
        VStack {
            Text("\(tabName) - Bald verfügbar")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#9CA3AF"))
                .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(hex: "#374151"))
    }
}
