//
//  FilterTabView.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI
import Combine

struct FilterTabView: View {
    @ObservedObject var viewModel: EditorViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterType.allCases) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: viewModel.selectedFilter == filter,
                        action: {
                            viewModel.applyFilter(filter)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .scrollDiscoveryNudge()
        }
        .fadedEdge(leading: false, trailing: true)
        .frame(height: 90)
    }
}

struct FilterButton: View {
    let filter: FilterType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        InteractiveButton(action: action) {
            VStack(spacing: 8) {
                // Filter preview circle with gradient or icon
                ZStack {
                    Circle()
                        .fill(filterGradient)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .animation(AppMotion.bouncy, value: isSelected)
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: 54, height: 54)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Text(filter.displayName)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .blue : .primary.opacity(0.8))
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
    }
    
    private var filterGradient: LinearGradient {
        switch filter {
        case .none:
            return LinearGradient(colors: [.white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .losAngeles:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .paris:
            return LinearGradient(colors: [.pink.opacity(0.6), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .tokyo:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .london:
            return LinearGradient(colors: [.gray, Color(white: 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .newYork:
            return LinearGradient(colors: [.black, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .milan:
            return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sepia:
            return LinearGradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.3), Color(red: 0.4, green: 0.3, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dramatic:
            return LinearGradient(colors: [.black, Color(white: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
