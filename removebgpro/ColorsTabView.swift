import SwiftUI

struct ColorsTabView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Binding var selectedPicker: ColorPickerTab?
    
    // Preset Colors
    let presetColors: [Color] = [
        .white, .black, .gray, .red, .blue, .green, .yellow, .orange, .pink, .purple, .cyan, .mint
    ]
    // Gradient Pairs
    let gradients: [[Color]] = [
        [.blue, .purple],
        [.orange, .red],
        [.green, .blue],
        [.pink, .orange],
        [.black, .gray],
        [.blue, .cyan],
        [.purple, .pink],
        [.yellow, .orange]
    ]
    // Gradient Image Mappings
    let gradientImageNames: [String?] = [
        "gradient_sunset",
        "gradient_dawn",
        "gradient_ocean",
        "gradient_berry",
        nil, // gradient_midnight
        nil, // gradient_sky
        nil, // gradient_candy
        nil  // gradient_sunny
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if let picker = selectedPicker {
                // Schritt 2: Picker Content ONLY
                ZStack {
                    switch picker {
                    case .presets:
                        presetsView
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    case .gradients:
                        gradientsView
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    case .transparent:
                        transparentView
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                // Schritt 1: 4-Button Navigation (Presets, Gradients, Transparent, Custom)
                HStack(spacing: 0) {
                    ForEach(ColorPickerTab.allCases) { tab in
                        InteractiveButton(action: {
                            withAnimation(AppMotion.snappy) {
                                selectedPicker = tab
                            }
                        }) {
                            VStack(spacing: 10) {
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 24, weight: .regular))
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.primary)
                                
                                Text(tab.localizedName)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.primary.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Rainbow Color Picker Button
                    InteractiveButton(action: {
                        showingColorPicker = true
                    }) {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red], center: .center))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1.5)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 2)
                            }
                            .frame(width: 28, height: 28)
                            
                            Text("Farbe")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            SpectrumColorPickerView(color: Binding(
                get: { viewModel.backgroundColor ?? .white },
                set: { newColor in
                    viewModel.didChange()
                    viewModel.backgroundColor = newColor
                    viewModel.gradientColors = nil
                    viewModel.backgroundImage = nil
                    viewModel.updateAdjustment()
                }
            ))
            .presentationDetents([.fraction(0.45), .medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    @State private var showingColorPicker = false
    
    private var presetsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(presetColors, id: \.self) { color in
                    ColorCircle(color: color, isSelected: viewModel.backgroundColor == color && viewModel.gradientColors == nil) {
                        viewModel.didChange()
                        viewModel.backgroundColor = color
                        viewModel.gradientColors = nil
                        viewModel.backgroundImage = nil
                        viewModel.updateAdjustment()
                    }
                }
            }
            .padding(.horizontal, 20)
            .scrollDiscoveryNudge()
        }
        .fadedEdge(leading: false, trailing: true)
    }
    
    private var gradientsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<gradients.count, id: \.self) { index in
                    let colors = gradients[index]
                    let imageName = gradientImageNames[index]
                    GradientCircle(colors: colors, imageName: imageName, isSelected: viewModel.gradientColors == colors) {
                        viewModel.didChange()
                        viewModel.gradientColors = colors
                        viewModel.backgroundColor = nil
                        viewModel.backgroundImage = nil
                        viewModel.updateAdjustment()
                    }
                }
            }
            .padding(.horizontal, 20)
            .scrollDiscoveryNudge()
        }
        .fadedEdge(leading: false, trailing: true)
    }
    
    private var transparentView: some View {
        VStack(spacing: 16) {
            InteractiveButton(action: {
                AppHaptics.medium()
                viewModel.didChange()
                viewModel.backgroundColor = nil
                viewModel.gradientColors = nil
                viewModel.backgroundImage = nil
                viewModel.updateAdjustment()
            }) {
                VStack(spacing: 12) {
                    ZStack {
                        // Checkered pattern to show transparency
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.9), Color(white: 0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "circle.dotted")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if viewModel.backgroundColor == nil && viewModel.gradientColors == nil && viewModel.backgroundImage == nil {
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 68, height: 68)
                        }
                    }
                    
                    Text("Transparenter Hintergrund")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



struct ColorCircle: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        InteractiveButton(action: action) {
            ZStack {
                Circle()
                    .fill(color)
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
        }
    }
}

struct GradientCircle: View {
    let colors: [Color]
    let imageName: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        InteractiveButton(action: action) {
            ZStack {
                if let imageName = imageName {
                    Image(imageName)
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
                } else {
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .animation(AppMotion.bouncy, value: isSelected)
                }
                
                if isSelected {
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 54, height: 54)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}
