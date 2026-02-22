import UIKit

struct StickerExporter {
    /// Converts a UIImage to PNG data for WhatsApp stickers.
    /// Resizes to 512x512 and reduces further if still over 400KB.
    static func convertToStickerData(image: UIImage) -> Data? {
        // 1. Resize to 512x512
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let resized = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: 512, height: 512))
        }
        
        guard var data = resized.pngData() else { return nil }
        print("DEBUG: PNG Größe: \(data.count / 1024) KB")
        
        // 2. Reduce size if too large (over 400KB)
        var currentImage = resized
        var size: CGFloat = 512
        
        while data.count > 400 * 1024 && size > 64 {
            size *= 0.85
            let r = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
            currentImage = r.image { _ in
                currentImage.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
            }
            data = currentImage.pngData() ?? data
            print("DEBUG: Reduziert auf \(Int(size))px → \(data.count / 1024) KB")
        }
        
        return data
    }
}
