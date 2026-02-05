
import UIKit
import UniformTypeIdentifiers

struct WebPConverter {
    /// Converts a UIImage to WebP data, ensuring it remains under 100KB for WhatsApp.
    static func convertToWebP(image: UIImage, quality: CGFloat = 0.8) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        
        let mutableData = NSMutableData()
        let webpType = UTType("org.webmproject.webp") ?? UTType.image
        guard let destination = CGImageDestinationCreateWithData(mutableData, webpType.identifier as CFString, 1, nil) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        let data = mutableData as Data
        
        // If file is too large (> 100KB), recursively try lower quality
        if data.count > 100 * 1024 && quality > 0.1 {
            return convertToWebP(image: image, quality: quality - 0.1)
        }
        
        return data
    }
}
