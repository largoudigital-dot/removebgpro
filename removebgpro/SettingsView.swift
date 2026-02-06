import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B")],
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
                    Button(action: { dismiss() }) {
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
                            SettingsRow(icon: "info.circle", title: "Über die App", color: .blue)
                            SettingsRow(icon: "star", title: "App bewerten", color: .yellow)
                            SettingsRow(icon: "square.and.arrow.up", title: "App teilen", color: .green)
                        }
                        
                        SettingsGroup(title: "Support") {
                            SettingsRow(icon: "envelope", title: "Kontakt", color: .orange)
                            SettingsRow(icon: "doc.text", title: "Datenschutz", color: .gray)
                        }
                        
                        SettingsGroup(title: "Aktionen") {
                            Button(action: {
                                // Clear projects logic
                                UserDefaults.standard.removeObject(forKey: "recent_projects_v2")
                                ProjectManager.shared.recentProjects = []
                            }) {
                                SettingsRow(icon: "trash", title: "Alle Projekte löschen", color: .red, showChevron: false)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 8)
            
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
    let title: String
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
