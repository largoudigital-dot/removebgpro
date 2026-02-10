//
//  ImageProcessor.swift
//  re-bg
//
//  Created by Photo Editor
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import Combine

struct ProcessingParameters: Equatable {
    var filter: FilterType = .none
    var brightness: Double = 1.0
    var contrast: Double = 1.0
    var saturation: Double = 1.0
    var blur: Double = 0.0
    var rotation: CGFloat = 0.0
    var aspectRatio: CGFloat? = nil
    var customSize: CGSize? = nil
    var backgroundColor: Color? = nil
    var gradientColors: [Color]? = nil
    var backgroundImage: UIImage? = nil
    var cropRect: CGRect? = nil
    var stickers: [Sticker] = []
    var textItems: [TextItem] = []
    var shadowRadius: CGFloat = 0
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0
    var shadowColor: Color = .black
    var shadowOpacity: Double = 0.3
    var shouldIncludeShadow: Bool = true
    var fgScale: CGFloat = 1.0
    var fgOffset: CGSize = .zero
    var bgScale: CGFloat = 1.0
    var bgOffset: CGSize = .zero
    var uiCanvasSize: CGSize? = nil
    var referenceSize: CGSize? = nil
    var outlineWidth: CGFloat = 0
    var outlineColor: Color = .white
}

enum EffectType: String, CaseIterable, Identifiable {
    case none = "Original"
    case vignette = "Vignette"
    case bloom = "Bloom"
    case noir = "Noir"
    case crystal = "Kristall"
    case blur = "Unschärfe"
    case edges = "Kanten"
    case posterize = "Poster"
    case grain = "Körnung"
    
    var id: String { rawValue }
}

class ImageProcessor {
    private let context = CIContext()
    
    // Apply filter to image
    func applyFilter(_ filterType: FilterType, to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        
        let filteredImage: CIImage?
        
        switch filterType {
        case .none:
            filteredImage = ciImage
            
        case .losAngeles:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.3
            filter.brightness = 0.02
            let warmFilter = CIFilter.temperatureAndTint()
            warmFilter.inputImage = filter.outputImage
            warmFilter.neutral = CIVector(x: 6500, y: 0)
            warmFilter.targetNeutral = CIVector(x: 7500, y: 0)
            filteredImage = warmFilter.outputImage
            
        case .paris:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.brightness = 0.05
            filter.saturation = 1.1
            let softFilter = CIFilter.temperatureAndTint()
            softFilter.inputImage = filter.outputImage
            softFilter.neutral = CIVector(x: 6500, y: 0)
            softFilter.targetNeutral = CIVector(x: 5800, y: 10) // Light pink/soft tint
            filteredImage = softFilter.outputImage
            
        case .tokyo:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.contrast = 1.25
            filter.saturation = 1.1
            let coolFilter = CIFilter.temperatureAndTint()
            coolFilter.inputImage = filter.outputImage
            coolFilter.neutral = CIVector(x: 6500, y: 0)
            coolFilter.targetNeutral = CIVector(x: 4800, y: 0)
            filteredImage = coolFilter.outputImage

        case .london:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 0.6
            filter.contrast = 0.9
            let moodyFilter = CIFilter.temperatureAndTint()
            moodyFilter.inputImage = filter.outputImage
            moodyFilter.neutral = CIVector(x: 6500, y: 0)
            moodyFilter.targetNeutral = CIVector(x: 5200, y: 0)
            filteredImage = moodyFilter.outputImage

        case .newYork:
            let mono = CIFilter.photoEffectNoir()
            mono.inputImage = ciImage
            let contrast = CIFilter.colorControls()
            contrast.inputImage = mono.outputImage
            contrast.contrast = 1.5
            filteredImage = contrast.outputImage

        case .milan:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.6
            filter.contrast = 1.1
            let sharpen = CIFilter.sharpenLuminance()
            sharpen.inputImage = filter.outputImage
            sharpen.sharpness = 0.8
            filteredImage = sharpen.outputImage

        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            filteredImage = filter.outputImage
            
        case .dramatic:
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = ciImage
            let contrastFilter = CIFilter.colorControls()
            contrastFilter.inputImage = filter.outputImage
            contrastFilter.contrast = 1.2
            filteredImage = contrastFilter.outputImage
        }
        
        guard let outputImage = filteredImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // Apply adjustments to image
    func applyAdjustments(to image: UIImage,
                         brightness: Double,
                         contrast: Double,
                         saturation: Double,
                         blur: Double) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        
        var currentImage = ciImage
        
        // Apply color controls (brightness, contrast, saturation)
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = currentImage
        colorFilter.brightness = Float(brightness - 1.0) // Convert 0-2 range to -1 to 1
        colorFilter.contrast = Float(contrast)
        colorFilter.saturation = Float(saturation)
        
        if let output = colorFilter.outputImage {
            currentImage = output
        }
        
        // Apply blur if needed
        if blur > 0 {
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = currentImage
            blurFilter.radius = Float(blur)
            
            if let output = blurFilter.outputImage {
                currentImage = output
            }
        }
        
        guard let cgImage = context.createCGImage(currentImage, from: ciImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // Rotate image
    func rotateImage(_ image: UIImage, degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        
        var newSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .size
        
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        image.draw(in: CGRect(x: -image.size.width / 2,
                             y: -image.size.height / 2,
                             width: image.size.width,
                             height: image.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
    
    // Crop image
    func cropImage(_ image: UIImage, to ratio: CGFloat) -> UIImage? {
        let cgImage = image.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let currentRatio = width / height
        var newWidth = width
        var newHeight = height
        
        if currentRatio > ratio {
            // Image is wider than target ratio
            newWidth = height * ratio
        } else {
            // Image is taller than target ratio
            newHeight = width / ratio
        }
        
        let x = (width - newWidth) / 2
        let y = (height - newHeight) / 2
        
        // x, y, newWidth, newHeight are already in pixels (from cgImage.width/height)
        let cropRect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        
        guard let croppedCgImage = cgImage.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // Crop to custom size
    func cropToSize(_ image: UIImage, width targetWidth: CGFloat, height targetHeight: CGFloat) -> UIImage? {
        let ratio = targetWidth / targetHeight
        return cropImage(image, to: ratio)
    }
    
    // Process complete image with all settings
    func processImage(original: UIImage,
                     filter: FilterType,
                     brightness: Double,
                     contrast: Double,
                     saturation: Double,
                     blur: Double,
                     rotation: CGFloat) -> UIImage? {
        var processedImage = original
        
        // Apply filter first
        if let filtered = applyFilter(filter, to: processedImage) {
            processedImage = filtered
        }
        
        // Apply adjustments
        if let adjusted = applyAdjustments(to: processedImage,
                                          brightness: brightness,
                                          contrast: contrast,
                                          saturation: saturation,
                                          blur: blur) {
            processedImage = adjusted
        }
        
        // Apply rotation
        if rotation != 0 {
            if let rotated = rotateImage(processedImage, degrees: rotation) {
                processedImage = rotated
            }
        }
        
        return processedImage
    }
    func processImageWithCrop(original: UIImage, params: ProcessingParameters) -> UIImage? {
        let filter = params.filter
        let brightness = params.brightness
        let contrast = params.contrast
        let saturation = params.saturation
        let blur = params.blur
        let rotation = params.rotation
        let aspectRatio = params.aspectRatio
        let customSize = params.customSize
        let backgroundColor = params.backgroundColor
        let gradientColors = params.gradientColors
        let backgroundImage = params.backgroundImage
        let cropRect = params.cropRect
        let stickers = params.stickers
        let textItems = params.textItems
        let shadowRadius = params.shadowRadius
        let shadowX = params.shadowX
        let shadowY = params.shadowY
        let shadowColor = params.shadowColor
        let shadowOpacity = params.shadowOpacity
        let shouldIncludeShadow = params.shouldIncludeShadow
        let fgScale = params.fgScale
        let fgOffset = params.fgOffset
        let bgScale = params.bgScale
        let bgOffset = params.bgOffset
        let uiCanvasSize = params.uiCanvasSize
        let referenceSize = params.referenceSize
        let outlineWidth = params.outlineWidth
        let outlineColor = params.outlineColor
        var processedImage = original
        
        // Calculate Virtual Canvas Size (Target Output Size)
        // If referenceSize is provided (Original Image Size), use it as the base.
        // Otherwise fallback to the processedImage size (which might be small if coming from BG removal).
        var virtualSize = referenceSize ?? processedImage.size
        
        // Adjust virtualSize based on crop/aspect ratio settings to determine the final canvas size
        if let rect = cropRect {
             virtualSize = CGSize(width: virtualSize.width * rect.width, height: virtualSize.height * rect.height)
        } else if let ratio = aspectRatio {
             // Calculate aspect fit/fill logic for virtual size?
             // Actually, if we crop to ratio, the output size depends on how cropImage works.
             // cropImage keeps the largest dimension that fits the ratio.
             let currentRatio = virtualSize.width / virtualSize.height
             if currentRatio > ratio {
                 virtualSize = CGSize(width: virtualSize.height * ratio, height: virtualSize.height)
             } else {
                 virtualSize = CGSize(width: virtualSize.width, height: virtualSize.width / ratio)
             }
        } else if let size = customSize {
             // Same logic as aspect ratio
             let ratio = size.width / size.height
             let currentRatio = virtualSize.width / virtualSize.height
             if currentRatio > ratio {
                 virtualSize = CGSize(width: virtualSize.height * ratio, height: virtualSize.height)
             } else {
                virtualSize = CGSize(width: virtualSize.width, height: virtualSize.width / ratio)
             }
        }
        
        // 0. Apply normalized crop rect if provided (Free Crop)
        if let rect = cropRect {
             guard let cgImage = processedImage.cgImage else { return processedImage }
             
             // IMPORTANT: Use UIImage.size which accounts for orientation,
             // not cgImage.width/height which are raw pixel dimensions
             let imageSize = processedImage.size
             
             // Convert normalized coordinates (0-1) to actual pixel coordinates
             let x = rect.minX * imageSize.width
             let y = rect.minY * imageSize.height
             let w = rect.width * imageSize.width
             let h = rect.height * imageSize.height
             
             // Create crop rectangle in image coordinate space
             let cropZone = CGRect(x: x, y: y, width: w, height: h)
             
             // Scale the crop zone to match the actual CGImage pixel dimensions
             let scale = processedImage.scale
             let scaledCropZone = CGRect(
                 x: cropZone.origin.x * scale,
                 y: cropZone.origin.y * scale,
                 width: cropZone.size.width * scale,
                 height: cropZone.size.height * scale
             )
             
             if let croppedCg = cgImage.cropping(to: scaledCropZone) {
                 processedImage = UIImage(cgImage: croppedCg, scale: processedImage.scale, orientation: processedImage.imageOrientation)
             }
        }
        
        // 1. Crop foreground first if needed
        if let ratio = aspectRatio {
            if let cropped = cropImage(processedImage, to: ratio) {
                processedImage = cropped
            }
        } else if let size = customSize {
            if let cropped = cropToSize(processedImage, width: size.width, height: size.height) {
                processedImage = cropped
            }
        }
        
        // 2. Apply all other effects to foreground
        var finalForeground = processImage(original: processedImage,
                                          filter: filter,
                                          brightness: brightness,
                                          contrast: contrast,
                                          saturation: saturation,
                                          blur: blur,
                                          rotation: rotation) ?? processedImage
        
        if shouldIncludeShadow {
            if let background = backgroundImage {
                processedImage = composite(foreground: finalForeground, background: background, shadowRadius: shadowRadius, shadowX: shadowX, shadowY: shadowY, shadowColor: shadowColor, shadowOpacity: shadowOpacity, fgScale: fgScale, fgOffset: fgOffset, bgScale: bgScale, bgOffset: bgOffset, uiCanvasSize: uiCanvasSize, outputSize: virtualSize, outlineWidth: outlineWidth, outlineColor: outlineColor) ?? finalForeground
            } else if let colors = gradientColors {
                if let gradientBg = self.createGradientImage(colors: colors, size: virtualSize) {
                    processedImage = composite(foreground: finalForeground, background: gradientBg, shadowRadius: shadowRadius, shadowX: shadowX, shadowY: shadowY, shadowColor: shadowColor, shadowOpacity: shadowOpacity, fgScale: fgScale, fgOffset: fgOffset, bgScale: bgScale, bgOffset: bgOffset, uiCanvasSize: uiCanvasSize, outputSize: virtualSize, outlineWidth: outlineWidth, outlineColor: outlineColor) ?? finalForeground
                }
            } else if let color = backgroundColor {
                if let colorBg = self.createColorImage(color: color, size: virtualSize) {
                    processedImage = composite(foreground: finalForeground, background: colorBg, shadowRadius: shadowRadius, shadowX: shadowX, shadowY: shadowY, shadowColor: shadowColor, shadowOpacity: shadowOpacity, fgScale: fgScale, fgOffset: fgOffset, bgScale: bgScale, bgOffset: bgOffset, uiCanvasSize: uiCanvasSize, outputSize: virtualSize, outlineWidth: outlineWidth, outlineColor: outlineColor) ?? finalForeground
                }
            } else {
                // No background - just use the foreground (but still apply transforms if needed, using virtualSize context)
                if fgScale != 1.0 || fgOffset != .zero || referenceSize != nil {
                    // Create empty background to drive composite logic with specific outputSize
                     if let emptyBg = self.createColorImage(color: .clear, size: virtualSize) {
                        processedImage = composite(foreground: finalForeground, background: emptyBg, shadowRadius: shadowRadius, shadowX: shadowX, shadowY: shadowY, shadowColor: shadowColor, shadowOpacity: shadowOpacity, fgScale: fgScale, fgOffset: fgOffset, bgScale: bgScale, bgOffset: bgOffset, uiCanvasSize: uiCanvasSize, outputSize: virtualSize, outlineWidth: outlineWidth, outlineColor: outlineColor) ?? finalForeground
                    } else {
                        processedImage = finalForeground
                    }
                } else {
                     processedImage = finalForeground
                }
            }
        } else {
            // Skip shadow baking (used for stable live preview)
            processedImage = finalForeground
        }
        
        // 4. Render Stickers
        if !stickers.isEmpty {
            processedImage = renderStickers(stickers, onto: processedImage) ?? processedImage
        }
        
        // 5. Render Text Items
        if !textItems.isEmpty {
            processedImage = renderTextItems(textItems, onto: processedImage) ?? processedImage
        }
        
        // 6. Apply shadow to transparent image (No background case)
        // If there was a background, the shadow was already applied in 'composite'
        if shouldIncludeShadow && backgroundImage == nil && gradientColors == nil && backgroundColor == nil {
            if shadowRadius > 0 || shadowX != 0 || shadowY != 0 {
                processedImage = applyShadowOnly(foreground: processedImage, shadowRadius: shadowRadius, shadowX: shadowX, shadowY: shadowY, shadowColor: shadowColor, shadowOpacity: shadowOpacity) ?? processedImage
            }
        }
        
        return processedImage
    }
    
    private func renderStickers(_ stickers: [Sticker], onto image: UIImage) -> UIImage? {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let context = UIGraphicsGetCurrentContext()
        
        for sticker in stickers {
            let stickerSize = size.width * 0.15 * sticker.scale // Base size is 15% of width
            let x = sticker.position.x * size.width
            let y = sticker.position.y * size.height
            
            context?.saveGState()
            context?.translateBy(x: x, y: y)
            context?.rotate(by: CGFloat(sticker.rotation.radians))
            
            let rect = CGRect(x: -stickerSize / 2, y: -stickerSize / 2, width: stickerSize, height: stickerSize)
            
            if sticker.type == .emoji {
                let string = sticker.content as NSString
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: stickerSize * 0.8)
                ]
                string.draw(in: rect, withAttributes: attributes)
            } else if sticker.type == .imageAsset {
                 if let assetImage = UIImage(named: sticker.content) {
                     assetImage.draw(in: rect)
                 }
            } else {
                // Render SF Symbol
                if let systemImage = UIImage(systemName: sticker.content) {
                    let color = UIColor(sticker.color)
                    let tintedImage = systemImage.withTintColor(color, renderingMode: .alwaysOriginal)
                    tintedImage.draw(in: rect)
                }
            }
            
            context?.restoreGState()
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    private func renderTextItems(_ items: [TextItem], onto image: UIImage) -> UIImage? {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let context = UIGraphicsGetCurrentContext()
        
        for item in items {
            // Determine font and size (base it on image width)
            let fontSize = size.width * 0.08 * item.scale
            
            // Handle Bold/Italic via Font Traits
            var font = UIFont(name: item.fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            var traits: UIFontDescriptor.SymbolicTraits = []
            if item.isBold { traits.insert(.traitBold) }
            if item.isItalic { traits.insert(.traitItalic) }
            
            if !traits.isEmpty, let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                font = UIFont(descriptor: descriptor, size: fontSize)
            }
            
            // Calculate text size and layout
            let paragraphStyle = NSMutableParagraphStyle()
            switch item.alignment {
            case .left: paragraphStyle.alignment = .left
            case .center: paragraphStyle.alignment = .center
            case .right: paragraphStyle.alignment = .right
            }
            paragraphStyle.lineSpacing = item.lineSpacing * (fontSize / 22.0)
            
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(item.color),
                .paragraphStyle: paragraphStyle,
                .kern: item.kerning
            ]
            
            if item.isUnderlined {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            
            let textToRender = item.isAllCaps ? item.text.uppercased() : item.text
            let attributedString = NSAttributedString(string: textToRender, attributes: attributes)
            let textSize = attributedString.size()
            
            // Background padding
            let padding = fontSize * 0.5 // Increased from 0.4
            let bgRect = CGRect(x: -textSize.width/2 - padding, 
                                y: -textSize.height/2 - padding/2, 
                                width: textSize.width + padding * 2, 
                                height: textSize.height + padding)
            
            let x = item.position.x * size.width
            let y = item.position.y * size.height
            
            context?.saveGState()
            context?.translateBy(x: x, y: y)
            context?.rotate(by: CGFloat(item.rotation.radians))
            
            // Draw background if needed
            if item.backgroundStyle != .none {
                let opacity = item.backgroundStyle == .solid ? 1.0 : 0.6
                UIColor(item.backgroundColor).withAlphaComponent(opacity).setFill()
                let path = UIBezierPath(roundedRect: bgRect, cornerRadius: padding * 0.8) // More rounded
                path.fill()
            }
            
            // Draw text
            let textRect = CGRect(x: -textSize.width/2, y: -textSize.height/2, width: textSize.width, height: textSize.height)
            attributedString.draw(in: textRect)
            
            context?.restoreGState()
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    private func createColorImage(color: Color, size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor(color).setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func createGradientImage(colors: [Color], size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgColors = colors.map { UIColor($0).cgColor }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: nil) else { return }
            
            context.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: size.height), options: [])
        }
    }
    
    private func composite(foreground: UIImage, background: UIImage, shadowRadius: CGFloat = 0, shadowX: CGFloat = 0, shadowY: CGFloat = 0, shadowColor: Color = .black, shadowOpacity: Double = 0.3, fgScale: CGFloat = 1.0, fgOffset: CGSize = .zero, bgScale: CGFloat = 1.0, bgOffset: CGSize = .zero, uiCanvasSize: CGSize? = nil, outputSize: CGSize? = nil, outlineWidth: CGFloat = 0, outlineColor: Color = .white) -> UIImage? {
        let size = outputSize ?? foreground.size
        UIGraphicsBeginImageContextWithOptions(size, false, foreground.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Calculate Pixel Scale (Mapping UI points to Image pixels)
        let pixelScale: CGFloat
        if let uiSize = uiCanvasSize, uiSize.width > 0 {
            pixelScale = size.width / uiSize.width
        } else {
            pixelScale = 1.0 // Fallback if no UI size captured
        }
        
        // --- 1. Draw Background ---
        context?.saveGState()
        
        // Calculate aspect fill (cover) scale for background BASE
        let widthRatio = size.width / background.size.width
        let heightRatio = size.height / background.size.height
        let baseScale = max(widthRatio, heightRatio)
        
        let newWidth = background.size.width * baseScale
        let newHeight = background.size.height * baseScale
        
        // Center the background base rect
        let bgX = (size.width - newWidth) / 2
        let bgY = (size.height - newHeight) / 2
        
        // Apply Background User Transforms (bgScale, bgOffset)
        // Center of canvas
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        let bgTranslateX = bgOffset.width * pixelScale
        let bgTranslateY = bgOffset.height * pixelScale
        
        context?.translateBy(x: centerX + bgTranslateX, y: centerY + bgTranslateY)
        context?.scaleBy(x: bgScale, y: bgScale)
        context?.translateBy(x: -centerX, y: -centerY)
        
        let bgRect = CGRect(x: bgX, y: bgY, width: newWidth, height: newHeight)
        background.draw(in: bgRect)
        
        context?.restoreGState()
        
        // --- 2. Draw Foreground ---
        context?.saveGState()
        
        // Apply Shadow
        if shadowRadius > 0 || shadowX != 0 || shadowY != 0 {
            let scaleFactor = max(size.width, size.height) / 1000.0
            let sRadius = shadowRadius * scaleFactor
            let sX = shadowX * scaleFactor
            let sY = shadowY * scaleFactor
            
            context?.setShadow(offset: CGSize(width: sX, height: sY), blur: sRadius, color: UIColor(shadowColor.opacity(shadowOpacity)).cgColor)
        }
        
        // Apply Foreground User Transforms (fgScale, fgOffset)
        let fgTranslateX = fgOffset.width * pixelScale
        let fgTranslateY = fgOffset.height * pixelScale
        
        context?.translateBy(x: centerX + fgTranslateX, y: centerY + fgTranslateY)
        context?.scaleBy(x: fgScale, y: fgScale)
        context?.translateBy(x: -centerX, y: -centerY)
        
        // Match Foreground to Canvas (if size differ)
        // If foreground is smaller than canvas (e.g. low res removal), we need to aspect fit it?
        // Or render it at center?
        // Usually, foreground should "fill" the canvas concept.
        // If we just draw(in: CGRect(origin: .zero, size: size)), it stretches!
        // We want to MAINTAIN ASPECT RATIO of foreground.
        // Wait, 'size' IS the target canvas size.
        // If we are composing, we generally expect the foreground to be the "Main Image".
        // If the Main Image (foreground) is 500x500 and Canvas is 1000x1000 (virtualSize),
        // we should probably scale foreground up to fit 1000x1000?
        // Yes, that's the whole point of "High Res Canvas".
        // But what if aspect ratios differ?
        // virtualSize is derived FROM referenceSize (Original Image).
        // foreground is PROCESSED image (derived from Original too).
        // So they SHOULD have same aspect ratio (unless cropped?).
        // If cropped, virtualSize logic above handles it.
        // Match Foreground to Canvas (if size differ)
        let fgRect = CGRect(origin: .zero, size: size)
        
        let imageToDraw: UIImage
        if outlineWidth > 0 {
            // Apply outline relative to the 512px baseline as requested: 
            // "8px at 512x512, scaled proportionally"
            let proportionalWidth = outlineWidth * (size.width / 512.0)
            imageToDraw = applyOutline(to: foreground, width: proportionalWidth, color: outlineColor) ?? foreground
        } else {
            imageToDraw = foreground
        }
        
        imageToDraw.draw(in: fgRect)
        
        context?.restoreGState()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    private func applyShadowOnly(foreground: UIImage, shadowRadius: CGFloat, shadowX: CGFloat, shadowY: CGFloat, shadowColor: Color, shadowOpacity: Double) -> UIImage? {
        let size = foreground.size
        let scaleFactor = max(size.width, size.height) / 1000.0
        
        let sRadius = shadowRadius * scaleFactor
        let sX = shadowX * scaleFactor
        let sY = shadowY * scaleFactor
        
        // Expand canvas to account for shadow spill and offset
        let marginX = sRadius * 4 + abs(sX)
        let marginY = sRadius * 4 + abs(sY)
        let canvasSize = CGSize(width: size.width + marginX * 2, height: size.height + marginY * 2)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, foreground.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setShadow(offset: CGSize(width: sX, height: sY), blur: sRadius, color: UIColor(shadowColor.opacity(shadowOpacity)).cgColor)
        
        // Center the foreground in the expanded canvas
        let drawRect = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        foreground.draw(in: drawRect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    // Core Effect logic
    func applyEffect(_ effect: EffectType, to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        var outputImage: CIImage?
        
        switch effect {
        case .none:
            return image
        case .vignette:
            let filter = CIFilter.vignette()
            filter.inputImage = ciImage
            filter.intensity = 1.0
            filter.radius = 2.0
            outputImage = filter.outputImage
        case .bloom:
            let filter = CIFilter.bloom()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            filter.radius = 10.0
            outputImage = filter.outputImage
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
        case .crystal:
            let filter = CIFilter.gloom()
            filter.inputImage = ciImage
            filter.intensity = 1.0
            filter.radius = 10.0
            outputImage = filter.outputImage
        case .blur:
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = 10.0
            outputImage = filter.outputImage
        case .edges:
            let filter = CIFilter.edges()
            filter.inputImage = ciImage
            filter.intensity = 1.0
            outputImage = filter.outputImage
        case .posterize:
            let filter = CIFilter.colorPosterize()
            filter.inputImage = ciImage
            filter.levels = 6.0
            outputImage = filter.outputImage
        case .grain:
            // 1. Create random noise
            let noise = CIFilter.randomGenerator()
            let noiseImage = noise.outputImage?.cropped(to: ciImage.extent)
            
            // 2. Make it monochrome/grey
            let whiteNoise = CIFilter.colorMonochrome()
            whiteNoise.inputImage = noiseImage
            whiteNoise.color = CIColor.gray
            whiteNoise.intensity = 1.0
            
            // 3. Blend with original (Overlay or Soft Light look)
            let blend = CIFilter.overlayBlendMode()
            blend.inputImage = whiteNoise.outputImage
            blend.backgroundImage = ciImage
            
            // 4. Adjust intensity by blending back a bit
            outputImage = blend.outputImage
        }
        
        guard let result = outputImage,
              let cgImage = context.createCGImage(result, from: result.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - Transparency Trimming
    
    func trimTransparency(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return nil }
        let ptr = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var top = 0
        var bottom = height - 1
        var left = 0
        var right = width - 1
        
        // Find top
        topLoop: for y in 0..<height {
            for x in 0..<width {
                if ptr[(y * width + x) * bytesPerPixel + 3] > 0 {
                    top = y
                    break topLoop
                }
            }
        }
        
        // If the image is completely transparent, return nil
        if top == 0 && ptr[3] == 0 {
            // Check if even the first pixel found was actually transparent
            var allTransparent = true
            for i in 0..<(width * height) {
                if ptr[i * bytesPerPixel + 3] > 0 {
                    allTransparent = false
                    break
                }
            }
            if allTransparent { return nil }
        }
        
        // Find bottom
        bottomLoop: for y in (top..<height).reversed() {
            for x in 0..<width {
                if ptr[(y * width + x) * bytesPerPixel + 3] > 0 {
                    bottom = y
                    break bottomLoop
                }
            }
        }
        
        // Find left
        leftLoop: for x in 0..<width {
            for y in top...bottom {
                if ptr[(y * width + x) * bytesPerPixel + 3] > 0 {
                    left = x
                    break leftLoop
                }
            }
        }
        
        // Find right
        rightLoop: for x in (left..<width).reversed() {
            for y in top...bottom {
                if ptr[(y * width + x) * bytesPerPixel + 3] > 0 {
                    right = x
                    break rightLoop
                }
            }
        }
        
        let trimRect = CGRect(x: left, y: top, width: right - left + 1, height: bottom - top + 1)
        
        guard let trimmedCgImage = cgImage.cropping(to: trimRect) else {
            return nil
        }
        
        return UIImage(cgImage: trimmedCgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - WhatsApp Sticker Generation
    func generateStickerImage(from image: UIImage, targetSize: CGFloat = 512, outlineWidth: CGFloat = 0, outlineColor: Color = .white) -> UIImage? {
        // 0. Find "New Corners" by trimming transparency
        // This ensures the sticker is tightly cropped to the actual content
        let trimmedImage = trimTransparency(from: image) ?? image
        
        // 1. Determine how much space the outline will take
        let outlinePadding = outlineWidth > 0 ? (outlineWidth + 4) : 0
        
        // 2. Scale the image so that the final sticker (image + outline) fits within targetSize
        let availableSpace = targetSize - (outlinePadding * 2)
        let scale = min(availableSpace / trimmedImage.size.width, availableSpace / trimmedImage.size.height)
        
        let scaledWidth = trimmedImage.size.width * scale
        let scaledHeight = trimmedImage.size.height * scale
        
        // 3. Create a clean resized version of the image at the base size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Exact pixel control
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: scaledWidth, height: scaledHeight), format: format)
        let scaledImage = renderer.image { _ in
            trimmedImage.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        }
        
        // 4. Apply the outline
        // applyOutline will expand the canvas of 'scaledImage' by exactly 'outlinePadding'
        // Resulting in a final image of (scaledWidth + 2*outlinePadding) x (scaledHeight + 2*outlinePadding)
        if outlineWidth > 0 {
            return applyOutline(to: scaledImage, width: outlineWidth, color: outlineColor)
        }
        
        return scaledImage
    }
    
    // MARK: - Outline Effect
    func applyOutline(to image: UIImage, width: CGFloat, color: Color) -> UIImage? {
        guard let ciOriginal = CIImage(image: image) else { return nil }
        
        // 0. Expand the canvas to make room for the outline + some padding for blur/smoothing
        // This is crucial for cropped images where the edge is a hard cut.
        let margin = width + 4
        let expandedExtent = ciOriginal.extent.insetBy(dx: -margin, dy: -margin)
        
        // Use a transparent background as the base for the expansion
        let baseImage = CIImage.clear.cropped(to: expandedExtent)
        let ciImage = ciOriginal.composited(over: baseImage)
        
        // 1. Create a mask from the alpha channel
        guard let maskFilter = CIFilter(name: "CIColorMatrix") else { return nil }
        maskFilter.setValue(ciImage, forKey: kCIInputImageKey)
        maskFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputRVector")
        maskFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputGVector")
        maskFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputBVector")
        maskFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        guard let mask = maskFilter.outputImage else { return nil }
        
        // 2. Expand mask using morphology
        guard let morphology = CIFilter(name: "CIMorphologyMaximum") else { return nil }
        morphology.setValue(mask, forKey: kCIInputImageKey)
        morphology.setValue(Float(width), forKey: kCIInputRadiusKey)
        
        guard let expandedMask = morphology.outputImage else { return nil }
        
        // 2b. Smooth the expanded mask for cleaner edges
        let smoothingFilter = CIFilter.gaussianBlur()
        smoothingFilter.inputImage = expandedMask
        smoothingFilter.radius = 1.0 // Subtle smoothing
        
        guard let smoothedMask = smoothingFilter.outputImage else { return nil }
        
        // 2c. Sharpen the mask back into a hard (but smooth) edge using ColorMatrix
        let rampFilter = CIFilter(name: "CIColorMatrix")!
        rampFilter.setValue(smoothedMask, forKey: kCIInputImageKey)
        rampFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 10), forKey: "inputAVector")
        rampFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: -4.5), forKey: "inputBiasVector")
        
        guard let finalMask = rampFilter.outputImage?.cropped(to: expandedMask.extent) else { return nil }
        
        // 3. Create colored background image
        guard let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        colorFilter.setValue(CIColor(color: UIColor(color)), forKey: kCIInputColorKey)
        
        guard let coloredImage = colorFilter.outputImage?.cropped(to: finalMask.extent) else { return nil }
        
        // 4. Combine: original over (colored background masked by expanded alpha)
        guard let maskedColored = CIFilter(name: "CISourceInCompositing") else { return nil }
        maskedColored.setValue(coloredImage, forKey: kCIInputImageKey)
        maskedColored.setValue(finalMask, forKey: kCIInputBackgroundImageKey)
        
        guard let outline = maskedColored.outputImage else { return nil }
        
        guard let finalFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        finalFilter.setValue(ciImage, forKey: kCIInputImageKey)
        finalFilter.setValue(outline, forKey: kCIInputBackgroundImageKey)
        
        guard let resultImage = finalFilter.outputImage,
              let cgImage = context.createCGImage(resultImage, from: resultImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
