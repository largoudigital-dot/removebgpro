//
//  CanvasTabView.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI

enum AspectRatio: String, Codable, CaseIterable, Identifiable {
    case free, square, fourFive, nineSixteen, sixteenNine, apple55, apple58, fourThree, threeFour, threeTwo, twoThree, original, custom
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .free: return "Frei"
        case .square: return "1:1"
        case .fourFive: return "4:5"
        case .nineSixteen: return "9:16"
        case .sixteenNine: return "16:9"
        case .apple55: return "5.5''"
        case .apple58: return "5.8''"
        case .fourThree: return "4:3"
        case .threeFour: return "3:4"
        case .threeTwo: return "3:2"
        case .twoThree: return "2:3"
        case .original: return "Original"
        case .custom: return "Eigene"
        }
    }
    
    var iconName: String {
        switch self {
        case .free: return "crop"
        case .square, .fourFive: return "instagram"
        case .nineSixteen: return "tiktok"
        case .sixteenNine: return "rectangle.ratio.16.to.9"
        case .apple55, .apple58: return "iphone"
        case .fourThree: return "facebook"
        case .threeFour: return "rectangle.portrait"
        case .threeTwo, .twoThree: return "rectangle.ratio.3.to.2"
        case .original: return "aspectratio"
        case .custom: return "slider.horizontal.2.square"
        }
    }
    
    var displayLabel: LocalizedStringKey {
        self.localizedName
    }
    
    var usesCustomImage: Bool {
        switch self {
        case .square, .fourFive, .nineSixteen, .fourThree, .threeFour:
            return true
        default:
            return false
        }
    }
    
    var ratio: CGFloat? {
        switch self {
        case .free: return nil
        case .original: return nil
        case .square: return 1.0
        case .fourFive: return 4.0 / 5.0
        case .fourThree: return 4.0 / 3.0
        case .threeFour: return 3.0 / 4.0
        case .threeTwo: return 3.0 / 2.0
        case .twoThree: return 2.0 / 3.0
        case .sixteenNine: return 16.0 / 9.0
        case .nineSixteen: return 9.0 / 16.0
        case .apple55: return 9.0 / 16.0
        case .apple58: return 1125.0 / 2436.0
        case .custom: return nil
        }
    }
}

struct CanvasTabView: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var showingCustomSizeDialog = false
    @State private var customWidth: String = "1080"
    @State private var customHeight: String = "1080"
    
    @State private var showingSaveAlert = false
    @State private var saveMessage: LocalizedStringKey = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Schnitt (Crop) Options - Only show aspect ratio scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AspectRatio.allCases) { ratio in
                        let isActuallySelected: Bool = {
                            if ratio == .free {
                                return viewModel.selectedAspectRatio == .free && viewModel.isCropping
                            }
                            return viewModel.selectedAspectRatio == ratio
                        }()
                        
                        InteractiveButton(action: {
                            if ratio == .custom {
                                showingCustomSizeDialog = true
                            } else if ratio == .free && isActuallySelected {
                                // Special "Commit & Save JPEG" action for Frei mode
                                AppHaptics.medium()
                                viewModel.saveToGallery(format: .jpg) { success, message in
                                    self.saveMessage = message
                                    self.showingSaveAlert = true
                                    if success { AppHaptics.success() }
                                }
                            } else {
                                viewModel.didChange()
                                withAnimation(AppMotion.snappy) {
                                    viewModel.selectedAspectRatio = ratio
                                    if ratio != .custom {
                                        viewModel.customSize = nil
                                    }
                                    
                                    if ratio == .free {
                                        viewModel.startCropping()
                                    } else {
                                        viewModel.cancelCropping()
                                        viewModel.updateAdjustment()
                                    }
                                }
                            }
                        }) {
                            RatioItemView(ratio: ratio, isActuallySelected: isActuallySelected)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 80)
            .padding(.bottom, 10)
        }
        .alert("Eigene Größe", isPresented: $showingCustomSizeDialog) {
            TextField("Breite (px)", text: $customWidth)
                .keyboardType(.numberPad)
            TextField("Höhe (px)", text: $customHeight)
                .keyboardType(.numberPad)
            Button("Abbrechen", role: .cancel) { }
            Button("OK") {
                if let width = Double(customWidth), let height = Double(customHeight), width > 0, height > 0 {
                    viewModel.didChange()
                    viewModel.selectedAspectRatio = .custom
                    viewModel.customSize = CGSize(width: width, height: height)
                    viewModel.cancelCropping()
                    viewModel.updateAdjustment()
                }
            }
        } message: {
            Text("Geben Sie die gewünschte Breite und Höhe in Pixeln ein.")
        }
        .alert("Speichern", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveMessage)
        }
    }
}

struct RatioItemView: View {
    let ratio: AspectRatio
    let isActuallySelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            AspectRatioIcon(ratio: ratio, isSelected: isActuallySelected)
                .scaleEffect(isActuallySelected ? 1.1 : 1.0)
                .animation(AppMotion.bouncy, value: isActuallySelected)
            
            Text(ratio == .free && isActuallySelected ? "JPEG Speichern" : ratio.displayLabel)
                .font(.system(size: 10, weight: isActuallySelected ? .bold : .medium))
        }
        .foregroundColor(isActuallySelected ? .blue : .primary)
        .frame(width: 70, height: 75)
        .background(isActuallySelected ? Color.blue.opacity(0.1) : Color.primary.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActuallySelected ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

struct AspectRatioIcon: View {
    let ratio: AspectRatio
    let isSelected: Bool
    
    var body: some View {
        let size: CGFloat = 20
        let displayRatio: CGFloat = {
            if let r = ratio.ratio {
                return r
            }
            return 1.0 // Default for Original/Free/Custom
        }()
        
        // Calculate icon dimensions to fit within a 20x20 bounding box
        let iconWidth: CGFloat = displayRatio > 1 ? size : size * displayRatio
        let iconHeight: CGFloat = displayRatio > 1 ? size / displayRatio : size
        
        ZStack {
            if ratio.usesCustomImage {
                Image(ratio.iconName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24) // Larger size, no frame
            } else if ratio == .original || ratio == .free || ratio == .custom {
                Image(systemName: ratio.iconName)
                    .font(.system(size: 20)) // Consistent with other buttons
            } else {
                // Proportional rectangle for generic ratios
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isSelected ? Color.black : Color.primary.opacity(0.8), lineWidth: 1.2)
                    .frame(width: iconWidth, height: iconHeight)
            }
        }
        .frame(width: 28, height: 28)
    }
}
