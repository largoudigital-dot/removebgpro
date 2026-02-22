import Foundation
import ImageIO
import UniformTypeIdentifiers

@objc class DeviceCapabilities: NSObject {
    @objc static func listSupportedTypes() {
        let types = CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []
        print("DEBUG: Supported CGImageDestination types:")
        for type in types {
            print("  - \(type)")
        }
    }
}
