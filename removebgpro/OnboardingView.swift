import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Präzises Freistellen",
            description: "Unsere KI entfernt Hintergründe in Sekunden – 100% automatisch und präzise.",
            imageName: "sparkles",
            color: Color(hex: "#4F46E5")
        ),
        OnboardingPage(
            title: "Profi-Editor",
            description: "Füge Schatten, Umrandungen und neue Hintergründe hinzu, um dein Motiv perfekt in Szene zu setzen.",
            imageName: "slider.horizontal.3",
            color: Color(hex: "#7C3AED")
        ),
        OnboardingPage(
            title: "Sticker Maker",
            description: "Verwandle deine Fotos in Sticker für WhatsApp & Co. – einfach ausschneiden und exportieren.",
            imageName: "face.smiling.fill",
            color: Color(hex: "#DB2777")
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Spacer()
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        hasSeenOnboarding = true
                        dismiss()
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Los geht's" : "Weiter")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[currentPage].color)
                        .cornerRadius(16)
                        .shadow(color: pages[currentPage].color.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 100))
                    .foregroundColor(page.color)
                    .shadow(color: page.color.opacity(0.5), radius: 20, x: 0, y: 10)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
