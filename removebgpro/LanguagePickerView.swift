import SwiftUI

struct LanguagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var languageManager = LanguageManager.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Sprache wählen")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(languageManager.supportedLanguages) { language in
                            Button(action: {
                                languageManager.selectedLanguage = language.id
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    Text(language.flag)
                                        .font(.system(size: 24))
                                    
                                    Text(language.name)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    if languageManager.selectedLanguage == language.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(languageManager.selectedLanguage == language.id ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    LanguagePickerView()
}
