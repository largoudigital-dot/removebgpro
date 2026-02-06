//
//  FilterType.swift
//  re-bg
//
//  Created by Photo Editor
//

import Foundation
import SwiftUI
import Combine

enum FilterType: String, CaseIterable, Identifiable, Codable {
    case none, losAngeles, paris, tokyo, london, newYork, milan, sepia, dramatic
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .none: return String(localized: "Original")
        case .losAngeles: return "Los Angeles"
        case .paris: return "Paris"
        case .tokyo: return "Tokyo"
        case .london: return "London"
        case .newYork: return "New York"
        case .milan: return "Milan"
        case .sepia: return String(localized: "Antique")
        case .dramatic: return String(localized: "Studio")
        }
    }
    
    var displayName: String {
        self.localizedName
    }
}
