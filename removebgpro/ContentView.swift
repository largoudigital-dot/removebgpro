//
//  ContentView.swift
//  re-bg
//
//  Created by Photo Editor
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var projectManager = ProjectManager.shared
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isEditorActive = false
    @State private var showingSettings = false
    @State private var isAnimating = false
    @State private var selectedProject: Project?
    @State private var showingSourceSelection = false
    @State private var showingCamera = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient - Vibrant Blue to Pink transition
                LinearGradient(
                    colors: [Color(hex: "#4F46E5"), Color(hex: "#7C3AED"), Color(hex: "#DB2777")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("WILLKOMMEN")
                                    .font(.system(size: 12, weight: .black))
                                    .kerning(1.2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Foto Editor")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                            Spacer()
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Main Action Card
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#F472B6").opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .blur(radius: 50)
                                
                                Image(systemName: "photo.stack.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "#F472B6"), Color(hex: "#DB2777")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color(hex: "#DB2777").opacity(0.6), radius: 25, x: 0, y: 12)
                            }
                            
                            VStack(spacing: 8) {
                                Text("NEUES PROJEKT")
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(.white)
                                Text("Erstelle brillante Ausschnitte & Sticker")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            InteractiveButton(action: {
                                showingSourceSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Foto auswählen")
                                }
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#6366F1"), Color(hex: "#4F46E5")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "#4F46E5").opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        
                        // Ad Placeholder Section
                        AdBannerView()
                            .padding(.horizontal, 24)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                        
                        // Recent Projects Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Letzte Projekte")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                            
                            if !projectManager.recentProjects.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(projectManager.recentProjects) { project in
                                            RecentProjectCard(project: project)
                                                .onTapGesture {
                                                    self.selectedImage = nil
                                                    self.selectedProject = project
                                                    self.isEditorActive = true
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            } else {
                                // Empty State Placeholder - More premium
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white.opacity(0.15))
                                    
                                    Text("Deine Reise beginnt hier")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .padding(.horizontal, 24)
                            }
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $isEditorActive) {
                EditorView(image: selectedImage, project: selectedProject)
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker { rawImage in
                    self.selectedProject = nil
                    self.selectedImage = rawImage
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isEditorActive = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingSettings) {
                SettingsView()
            }
            .confirmationDialog("Foto hinzufügen", isPresented: $showingSourceSelection) {
                Button("🗂️ Aus Galerie wählen") { showingImagePicker = true }
                Button("📸 Foto aufnehmen") { showingCamera = true }
                Button("Abbrechen", role: .cancel) { }
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker { rawImage in
                    self.selectedProject = nil
                    self.selectedImage = rawImage
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isEditorActive = true
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct RecentProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let thumbnail = project.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.white.opacity(0.1)
                }
            }
            .frame(width: 90, height: 90) // Square and small
            .cornerRadius(12)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
            )
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(project.date, style: .date)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                
                Text(project.date, style: .time)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.leading, 2)
        }
    }
}

struct AdBannerView: View {
    var body: some View {
        VStack {
            Text("ANZEIGE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .frame(height: 80)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.2))
                        Text("Werbung platzieren")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.2))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let onSelect: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.onSelect(uiImage)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
