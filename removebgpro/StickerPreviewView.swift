import SwiftUI

struct StickerPreviewView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Sticker Vorschau")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // Preview Area
                if let previewImage = viewModel.stickerPreviewImage {
                    ZStack {
                        // Checkerboard background for transparency
                        Image(systemName: "checkerboard.rectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(width: 300, height: 300)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Image(uiImage: previewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 280, height: 280)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.shareAsSticker { success in
                            if success {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("An WhatsApp senden")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(14)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Abbrechen")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
}
