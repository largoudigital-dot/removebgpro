import SwiftUI
import Combine

enum ShadowParameter: String, CaseIterable, Identifiable {
    case radius = "Weichheit"
    case x = "X-Versatz"
    case y = "Y-Versatz"
    case opacity = "Deckkraft"
    case color = "Farbe"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .radius: return "sun.max.fill"
        case .x: return "arrow.left.and.right"
        case .y: return "arrow.up.and.down"
        case .opacity: return "circle.dotted"
        case .color: return "paintpalette.fill"
        }
    }
}

struct ShadowTabView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Binding var selectedParameter: ShadowParameter?
    
    var body: some View {
        ZStack {
            if let parameter = selectedParameter {
                // Slider Detail View
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text(parameter.rawValue)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                        
                        ShadowSliderView(parameter: parameter, viewModel: viewModel)
                        
                        if parameter != .color {
                            let value = getParameterValue(parameter)
                            let displayValue = (parameter == .opacity) ? String(format: "%.0f%%", value * 100) : String(format: "%.0f", value)
                            Text(displayValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "#3B82F6"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Reset Button
                    Button(action: {
                        hapticFeedback()
                        resetParameter(parameter)
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
                    }
                }
                .padding(.horizontal, 16)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                // Main Tool List View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ShadowParameter.allCases) { parameter in
                            Button(action: {
                                hapticFeedback()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedParameter = parameter
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: parameter.iconName)
                                        .font(.system(size: 22))
                                        .foregroundColor(.primary)
                                    
                                    Text(parameter.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 70, height: 70)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                        // Glow Preset
                        Button(action: {
                            hapticFeedback()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.shadowRadius = 30
                                viewModel.shadowX = 0
                                viewModel.shadowY = 0
                                viewModel.shadowOpacity = 0.5
                                viewModel.shadowColor = .black
                            }
                            viewModel.updateAdjustment()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                                Text("Glow")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 70, height: 70)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // Reset All
                        Button(action: {
                            hapticFeedback()
                            viewModel.shadowRadius = 0
                            viewModel.shadowX = 0
                            viewModel.shadowY = 0
                            viewModel.shadowOpacity = 0.3
                            viewModel.shadowColor = .black
                            viewModel.updateAdjustment()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                                Text("Alle Reset")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 70, height: 70)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        }
        .frame(height: 90)
    }
    
    private func getParameterValue(_ parameter: ShadowParameter) -> CGFloat {
        switch parameter {
        case .radius: return viewModel.shadowRadius
        case .x: return viewModel.shadowX
        case .y: return viewModel.shadowY
        case .opacity: return viewModel.shadowOpacity
        case .color: return 0
        }
    }
    
    private func resetParameter(_ parameter: ShadowParameter) {
        switch parameter {
        case .radius: viewModel.shadowRadius = 0
        case .x: viewModel.shadowX = 0
        case .y: viewModel.shadowY = 0
        case .opacity: viewModel.shadowOpacity = 0.3
        case .color: viewModel.shadowColor = .black
        }
        viewModel.updateAdjustment()
    }
}

struct ShadowSliderView: View {
    let parameter: ShadowParameter
    @ObservedObject var viewModel: EditorViewModel
    
    var body: some View {
        switch parameter {
        case .radius:
            Slider(value: $viewModel.shadowRadius, in: 0...100, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.shadowRadius) { _ in viewModel.updateAdjustment() }
        case .x:
            Slider(value: $viewModel.shadowX, in: -100...100, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.shadowX) { _ in viewModel.updateAdjustment() }
        case .y:
            Slider(value: $viewModel.shadowY, in: -100...100, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.shadowY) { _ in viewModel.updateAdjustment() }
        case .opacity:
            Slider(value: $viewModel.shadowOpacity, in: 0...1, onEditingChanged: { editing in
                if !editing { viewModel.finishAdjustment() }
            })
                .accentColor(Color(hex: "#3B82F6"))
                .onChange(of: viewModel.shadowOpacity) { _ in viewModel.updateAdjustment() }
        case .color:
            ColorPicker("Farbe wählen", selection: $viewModel.shadowColor)
                .padding(.horizontal, 20)
                .onChange(of: viewModel.shadowColor) { _ in viewModel.updateAdjustment() }
        }
    }
}
