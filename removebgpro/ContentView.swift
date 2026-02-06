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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#334155")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Willkommen")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Foto Editor")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.white)
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
                                            colors: [Color(hex: "#3B82F6").opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .blur(radius: 40)
                                
                                Image(systemName: "photo.stack.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "#60A5FA"), Color(hex: "#2563EB")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color(hex: "#3B82F6").opacity(0.5), radius: 20, x: 0, y: 10)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Neues Projekt")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Wähle ein Foto aus deiner Galerie")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            InteractiveButton(action: {
                                showingImagePicker = true
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
                                        colors: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "#3B82F6").opacity(0.4), radius: 10, x: 0, y: 5)
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
                                // Empty State Placeholder
                                VStack(spacing: 12) {
                                    Image(systemName: "xmark.square.fill")
                                        .font(.system(size: 60))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white.opacity(0.1), .white.opacity(0.05)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    
                                    Text("Keine Projekte")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 130)
                                .background(.ultraThinMaterial.opacity(0.5))
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
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
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                if let thumbnail = project.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 100, height: 130)
            .cornerRadius(16)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            Text(project.date, style: .date)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .padding(.leading, 4)
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
