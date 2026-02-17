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
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .none: return "Original"
        case .losAngeles: return "Los Angeles"
        case .paris: return "Paris"
        case .tokyo: return "Tokyo"
        case .london: return "London"
        case .newYork: return "New York"
        case .milan: return "Milan"
        case .sepia: return "Antique"
        case .dramatic: return "Studio"
        }
    }
    
    var displayName: LocalizedStringKey {
        self.localizedName
    }
    
    var imageName: String {
        switch self {
        case .none: return "filter_none"
        case .losAngeles: return "filter_losangeles"
        case .paris: return "filter_paris"
        case .tokyo: return "filter_tokyo"
        case .london: return "filter_london"
        case .newYork: return "filter_newyork"
        case .milan: return "filter_milan"
        case .sepia: return "filter_sepia"
        case .dramatic: return "filter_dramatic"
        }
    }
}
