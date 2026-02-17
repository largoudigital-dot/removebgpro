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
                // Filter preview circle with representative photo
                ZStack {
                    Image(filter.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
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
}
