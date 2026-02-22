import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLanguagePicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showingPrivacy = false
    @State private var showingTerms = false
    
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
                    Text("Einstellungen")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    InteractiveButton(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 20) {
                        SettingsGroup(title: "App") {
                            InteractiveButton(action: { showingLanguagePicker = true }) {
                                SettingsRow(icon: "globe", title: "Sprache", color: .purple)
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                            
                            InteractiveButton(action: {
                                if let url = URL(string: "https://devlargou.com/") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                SettingsRow(icon: "info.circle", title: "Über die App", color: .blue)
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                            
                            InteractiveButton(action: {
                                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                }
                            }) {
                                SettingsRow(icon: "star", title: "App bewerten", color: .yellow)
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                            
                            InteractiveButton(action: {
                                let url = URL(string: "https://apps.apple.com/app/id6741484845")!
                                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                if let topVC = UIApplication.topViewController() {
                                    if let popover = activityVC.popoverPresentationController {
                                        popover.sourceView = topVC.view
                                        popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                                        popover.permittedArrowDirections = []
                                    }
                                    topVC.present(activityVC, animated: true)
                                }
                            }) {
                                SettingsRow(icon: "square.and.arrow.up", title: "App teilen", color: .green)
                            }
                        }
                        
                        SettingsGroup(title: "Support") {
                            InteractiveButton(action: {
                                if let url = URL(string: "mailto:support@devlargou.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                SettingsRow(icon: "envelope", title: "Kontakt", color: .orange)
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                            
                            InteractiveButton(action: {
                                showingPrivacy = true
                            }) {
                                SettingsRow(icon: "lock.shield", title: "Datenschutz", color: .gray)
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                            
                            InteractiveButton(action: {
                                showingTerms = true
                            }) {
                                SettingsRow(icon: "doc.text", title: "AGB", color: .gray)
                            }
                        }
                        
                        SettingsGroup(title: "Aktionen") {
                            InteractiveButton(action: {
                                showingDeleteConfirmation = true
                            }) {
                                SettingsRow(icon: "trash", title: "Alle Projekte löschen", color: .red, showChevron: false)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .alert("Alle Projekte löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) { }
            Button("Alle löschen", role: .destructive) {
                ProjectManager.shared.deleteAllProjects()
                AppHaptics.heavy()
            }
        } message: {
            Text("Alle gespeicherten Projekte werden unwiderruflich gelöscht.")
        }
        .sheet(isPresented: $showingLanguagePicker) {
            LanguagePickerView()
                .environment(\.locale, LanguageManager.shared.locale)
        }
        .sheet(isPresented: $showingPrivacy) {
            LegalView(type: .privacy)
        }
        .sheet(isPresented: $showingTerms) {
            LegalView(type: .terms)
        }
    }
}

struct SettingsGroup<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content
    
    init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 8)
                .textCase(.uppercase)
            
            VStack(spacing: 0) {
                content
            }
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.8))
                .cornerRadius(8)
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView()
}
