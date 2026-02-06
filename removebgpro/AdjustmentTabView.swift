//
//  AdjustmentTabView.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI
import Combine

enum AdjustmentParameter: String, Codable, CaseIterable, Identifiable {
    case brightness = "Helligkeit"
    case contrast = "Kontrast"
    case saturation = "Sättigung"
    case sharpness = "Schärfe"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .brightness: return "sun.max.fill"
        case .contrast: return "circle.lefthalf.filled"
        case .saturation: return "drop.fill"
        case .sharpness: return "triangle.fill"
        }
    }
}

struct AdjustmentTabView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Binding var selectedParameter: AdjustmentParameter?
    
    var body: some View {
        ZStack {
            if let parameter = selectedParameter {
                // Slider Detail View
                HStack(spacing: 12) {
                    // Center Slider Area
                    VStack(spacing: 4) {
                        Text(parameter.rawValue)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                        
                        SliderView(parameter: parameter, viewModel: viewModel)
                        
                        Text(String(format: "%.0f%%", getParameterValue(parameter) * 100))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#3B82F6"))
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Reset Button (stays visible)
                    InteractiveButton(action: {
                        AppHaptics.medium()
                        viewModel.resetAdjustments()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Reset")
                                .font(.system(size: 9))
                                .foregroundColor(.primary)
                        }
                        .frame(width: 44, height: 90)
                        .background(Color.black.opacity(0.001))
                    }
                }
                .padding(.horizontal, 16)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                // Main Tool List View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(AdjustmentParameter.allCases) { parameter in
                            InteractiveButton(action: {
                                withAnimation(AppMotion.snappy) {
                                    selectedParameter = parameter
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: parameter.iconName)
                                        .font(.system(size: 22))
                                        .foregroundColor(.primary)
                                    
                                    Text(parameter.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.primary.opacity(0.8))
                                }
                                .frame(width: 70, height: 70)
                                .background(Color.primary.opacity(0.05))
                                .cornerRadius(16)
                            }
                        }
                        
                        // Main Reset Button
                        InteractiveButton(action: {
                            AppHaptics.medium()
                            viewModel.resetAdjustments()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                                Text("Reset")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary.opacity(0.8))
                            }
                            .frame(width: 70, height: 70)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .scrollDiscoveryNudge()
                }
                .fadedEdge(leading: false, trailing: true)
                .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
            }
        }
        .frame(height: 90)
    }
    
    private func getParameterValue(_ parameter: AdjustmentParameter) -> Double {
        switch parameter {
        case .brightness: return viewModel.brightness
        case .contrast: return viewModel.contrast
        case .saturation: return viewModel.saturation
        case .sharpness: return viewModel.blur / 20.0
        }
    }
}

struct SliderView: View {
    let parameter: AdjustmentParameter
    @ObservedObject var viewModel: EditorViewModel
    
    var body: some View {
        switch parameter {
        case .brightness:
            Slider(value: $viewModel.brightness, in: 0...2, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.brightness) { _ in viewModel.updateAdjustment() }
        case .contrast:
            Slider(value: $viewModel.contrast, in: 0...2, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.contrast) { _ in viewModel.updateAdjustment() }
        case .saturation:
            Slider(value: $viewModel.saturation, in: 0...2, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.saturation) { _ in viewModel.updateAdjustment() }
        case .sharpness:
            Slider(value: $viewModel.blur, in: 0...20, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.blur) { _ in viewModel.updateAdjustment() }
        }
    }
}
