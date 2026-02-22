import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var hasAccepted = false
    
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
    
    /// Total pages = 3 feature pages + 1 consent page
    private var totalPages: Int { pages.count + 1 }
    private var isConsentPage: Bool { currentPage == pages.count }
    
    var body: some View {
        ZStack {
            // Dynamic background
            LinearGradient(
                colors: isConsentPage
                    ? [Color(hex: "#1a1a2e"), Color(hex: "#16213e")]
                    : [.black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: currentPage)
            
            VStack {
                // Skip button (only on feature pages)
                if !isConsentPage {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                currentPage = pages.count // jump to consent
                            }
                        }) {
                            Text("Überspringen")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 12)
                    }
                } else {
                    Spacer().frame(height: 44)
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                    
                    // 4th page: Consent
                    ConsentPageView(hasAccepted: $hasAccepted)
                        .tag(pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: isConsentPage ? .never : .always))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                
                // Bottom button
                if isConsentPage {
                    Button(action: {
                        hasSeenOnboarding = true
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                            Text("Zustimmen & Starten")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: hasAccepted
                                    ? [Color(hex: "#22c55e"), Color(hex: "#16a34a")]
                                    : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: hasAccepted ? Color(hex: "#22c55e").opacity(0.4) : .clear, radius: 10, x: 0, y: 5)
                    }
                    .disabled(!hasAccepted)
                    .opacity(hasAccepted ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.25), value: hasAccepted)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Weiter" : "Weiter")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
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
}

// MARK: - Consent Page

struct ConsentPageView: View {
    @Binding var hasAccepted: Bool
    @State private var showPrivacy = false
    @State private var showTerms = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "#6366F1").opacity(0.12))
                    .frame(width: 160, height: 160)
                    .blur(radius: 40)
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hex: "#6366F1").opacity(0.4), radius: 20, x: 0, y: 10)
            }
            .padding(.bottom, 32)
            
            // Title
            Text("Willkommen!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.bottom, 8)
            
            Text("Bitte akzeptiere unsere Richtlinien")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 28)
            
            // Inline text with tappable links
            VStack(spacing: 6) {
                Text("Bitte lies und akzeptiere unsere")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 4) {
                    Button(action: { showPrivacy = true }) {
                        Text(LegalTextProvider.localizedTitle(for: .privacy))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#818CF8"))
                            .underline()
                    }
                    
                    Text("und")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Button(action: { showTerms = true }) {
                        Text(LegalTextProvider.localizedTitle(for: .terms))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#818CF8"))
                            .underline()
                    }
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
            
            // Checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    hasAccepted.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(hasAccepted ? Color(hex: "#22c55e") : Color.white.opacity(0.08))
                            .frame(width: 28, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(hasAccepted ? Color.clear : Color.white.opacity(0.2), lineWidth: 1.5)
                            )
                        
                        if hasAccepted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Text("Ich habe gelesen und akzeptiere")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .sheet(isPresented: $showPrivacy) {
            LegalView(type: .privacy)
        }
        .sheet(isPresented: $showTerms) {
            LegalView(type: .terms)
        }
    }
}

// MARK: - Models

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
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 17, design: .rounded))
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

// MARK: - Legal View (Privacy & Terms)

struct LegalView: View {
    let type: LegalType
    @Environment(\.dismiss) private var dismiss
    
    enum LegalType {
        case privacy
        case terms
        
        var title: String {
            switch self {
            case .privacy: return LegalTextProvider.localizedTitle(for: .privacy)
            case .terms: return LegalTextProvider.localizedTitle(for: .terms)
            }
        }
        
        var icon: String {
            switch self {
            case .privacy: return "lock.shield.fill"
            case .terms: return "doc.text.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .privacy: return Color(hex: "#6366F1")
            case .terms: return Color(hex: "#8B5CF6")
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: type.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(type.color)
                        Text(type.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView {
                    Text(LegalTextProvider.content(for: type))
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Localized Legal Content

struct LegalTextProvider {
    
    private static var lang: String {
        LanguageManager.shared.effectiveLanguage
    }
    
    static func localizedTitle(for type: LegalView.LegalType) -> String {
        switch type {
        case .privacy: return privacyTitles[lang] ?? privacyTitles["en"]!
        case .terms: return termsTitles[lang] ?? termsTitles["en"]!
        }
    }
    
    static func content(for type: LegalView.LegalType) -> String {
        switch type {
        case .privacy: return privacyContent[lang] ?? privacyContent["en"]!
        case .terms: return termsContent[lang] ?? termsContent["en"]!
        }
    }
    
    private static let privacyTitles: [String: String] = [
        "en": "Privacy Policy", "de": "Datenschutzerklärung",
        "fr": "Politique de Confidentialité", "es": "Política de Privacidad",
        "it": "Informativa sulla Privacy", "pt-BR": "Política de Privacidade",
        "pt-PT": "Política de Privacidade", "nl": "Privacybeleid",
        "ru": "Политика конфиденциальности", "zh-Hans": "隐私政策",
        "zh-Hant": "隱私權政策", "ja": "プライバシーポリシー",
        "ko": "개인정보 처리방침", "tr": "Gizlilik Politikası",
        "ar": "سياسة الخصوصية", "hi": "गोपनीयता नीति",
        "pl": "Polityka Prywatności", "sv": "Integritetspolicy",
        "da": "Privatlivspolitik", "nb": "Personvernserklæring",
        "fi": "Tietosuojakäytäntö", "el": "Πολιτική Απορρήτου",
        "he": "מדיניות פרטיות", "th": "นโยบายความเป็นส่วนตัว",
        "vi": "Chính sách Bảo mật", "id": "Kebijakan Privasi",
        "ms": "Dasar Privasi", "cs": "Zásady ochrany osobních údajů",
        "hu": "Adatvédelmi irányelvek", "ro": "Politica de Confidențialitate",
        "uk": "Політика конфіденційності", "hr": "Pravila o privatnosti",
        "sk": "Zásady ochrany súkromia", "ca": "Política de Privacitat",
        "bg": "Политика за поверителност", "lt": "Privatumo politika",
        "lv": "Privātuma politika", "et": "Privaatsuspoliitika",
        "fa": "سیاست حفظ حریم خصوصی"
    ]
    
    private static let termsTitles: [String: String] = [
        "en": "Terms of Service", "de": "AGB",
        "fr": "Conditions d'Utilisation", "es": "Términos de Servicio",
        "it": "Termini di Servizio", "pt-BR": "Termos de Serviço",
        "pt-PT": "Termos de Serviço", "nl": "Servicevoorwaarden",
        "ru": "Условия использования", "zh-Hans": "服务条款",
        "zh-Hant": "服務條款", "ja": "利用規約",
        "ko": "서비스 이용약관", "tr": "Hizmet Şartları",
        "ar": "شروط الخدمة", "hi": "सेवा की शर्तें",
        "pl": "Regulamin", "sv": "Användarvillkor",
        "da": "Servicevilkår", "nb": "Tjenestevilkår",
        "fi": "Käyttöehdot", "el": "Όροι Χρήσης",
        "he": "תנאי שימוש", "th": "ข้อกำหนดการให้บริการ",
        "vi": "Điều khoản Dịch vụ", "id": "Ketentuan Layanan",
        "ms": "Terma Perkhidmatan", "cs": "Podmínky služby",
        "hu": "Felhasználási feltételek", "ro": "Termeni și Condiții",
        "uk": "Умови використання", "hr": "Uvjeti korištenja",
        "sk": "Podmienky služby", "ca": "Termes del Servei",
        "bg": "Условия за ползване", "lt": "Paslaugų teikimo sąlygos",
        "lv": "Pakalpojumu noteikumi", "et": "Teenuse tingimused",
        "fa": "شرایط خدمات"
    ]
    
    private static let privacyContent: [String: String] = [
        "en": """
        Last updated: February 2026
        
        ClearCut ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains how we handle your data when you use our application.
        
        1. DATA COLLECTION
        
        ClearCut processes all images locally on your device. We do not upload, store, or transmit your photos to any external server. Your images remain entirely on your device.
        
        2. PERSONAL INFORMATION
        
        We do not collect any personal information such as your name, email address, phone number, or location data. No account creation is required to use ClearCut.
        
        3. IMAGE PROCESSING
        
        All background removal and image editing operations are performed entirely on your device using on-device machine learning models. No images are sent to external servers for processing.
        
        4. LOCAL STORAGE
        
        Project data and edited images are stored locally on your device using standard iOS storage mechanisms. You can delete all project data at any time through the app's settings.
        
        5. THIRD-PARTY SERVICES
        
        ClearCut may display advertisements through third-party ad networks. These services may collect anonymous usage data in accordance with their own privacy policies. We do not share any personal data with these services.
        
        6. ANALYTICS
        
        We do not use any analytics or tracking tools. Your usage of the app is completely private.
        
        7. CHILDREN'S PRIVACY
        
        ClearCut does not knowingly collect data from children under the age of 13. The app is suitable for all ages.
        
        8. CHANGES TO THIS POLICY
        
        We may update this Privacy Policy from time to time. Any changes will be reflected in the app with an updated date.
        
        9. CONTACT
        
        If you have any questions about this Privacy Policy, please contact us at:
        support@devlargou.com
        """,
        
        "de": """
        Zuletzt aktualisiert: Februar 2026
        
        ClearCut („wir", „unser" oder „die App") verpflichtet sich zum Schutz Ihrer Privatsphäre. Diese Datenschutzerklärung erläutert, wie wir mit Ihren Daten umgehen.
        
        1. DATENERHEBUNG
        
        ClearCut verarbeitet alle Bilder lokal auf Ihrem Gerät. Wir laden Ihre Fotos nicht hoch, speichern sie nicht und übertragen sie nicht an externe Server. Ihre Bilder verbleiben vollständig auf Ihrem Gerät.
        
        2. PERSÖNLICHE DATEN
        
        Wir erheben keine persönlichen Daten wie Ihren Namen, Ihre E-Mail-Adresse, Telefonnummer oder Standortdaten. Für die Nutzung von ClearCut ist keine Kontoerstellung erforderlich.
        
        3. BILDVERARBEITUNG
        
        Alle Hintergrundentfernungs- und Bildbearbeitungsvorgänge werden vollständig auf Ihrem Gerät mithilfe von On-Device-Machine-Learning-Modellen durchgeführt. Es werden keine Bilder zur Verarbeitung an externe Server gesendet.
        
        4. LOKALE SPEICHERUNG
        
        Projektdaten und bearbeitete Bilder werden lokal auf Ihrem Gerät gespeichert. Sie können alle Projektdaten jederzeit über die Einstellungen der App löschen.
        
        5. DIENSTE DRITTER
        
        ClearCut kann Werbung über Werbenetzwerke Dritter anzeigen. Diese Dienste können anonyme Nutzungsdaten gemäß ihren eigenen Datenschutzrichtlinien erheben. Wir geben keine persönlichen Daten an diese Dienste weiter.
        
        6. ANALYSEN
        
        Wir verwenden keine Analyse- oder Tracking-Tools. Ihre Nutzung der App ist vollständig privat.
        
        7. DATENSCHUTZ FÜR KINDER
        
        ClearCut erhebt wissentlich keine Daten von Kindern unter 13 Jahren. Die App ist für alle Altersgruppen geeignet.
        
        8. ÄNDERUNGEN DIESER RICHTLINIE
        
        Wir können diese Datenschutzerklärung von Zeit zu Zeit aktualisieren. Änderungen werden in der App mit einem aktualisierten Datum angezeigt.
        
        9. KONTAKT
        
        Bei Fragen zu dieser Datenschutzerklärung kontaktieren Sie uns bitte unter:
        support@devlargou.com
        """,
        
        "fr": """
        Dernière mise à jour : Février 2026
        
        ClearCut (« nous », « notre » ou « l'application ») s'engage à protéger votre vie privée.
        
        1. COLLECTE DE DONNÉES
        
        ClearCut traite toutes les images localement sur votre appareil. Nous ne téléchargeons, ne stockons ni ne transmettons vos photos vers un serveur externe.
        
        2. INFORMATIONS PERSONNELLES
        
        Nous ne collectons aucune information personnelle. Aucune création de compte n'est requise.
        
        3. TRAITEMENT DES IMAGES
        
        Toutes les opérations sont effectuées entièrement sur votre appareil.
        
        4. STOCKAGE LOCAL
        
        Les données de projet sont stockées localement. Vous pouvez les supprimer à tout moment via les paramètres.
        
        5. SERVICES TIERS
        
        ClearCut peut afficher des publicités. Ces services peuvent collecter des données anonymes.
        
        6. ANALYSE
        
        Nous n'utilisons aucun outil d'analyse ou de suivi.
        
        7. VIE PRIVÉE DES ENFANTS
        
        ClearCut ne collecte pas sciemment de données auprès d'enfants de moins de 13 ans.
        
        8. MODIFICATIONS
        
        Nous pouvons mettre à jour cette politique.
        
        9. CONTACT
        
        support@devlargou.com
        """,
        
        "es": """
        Última actualización: Febrero 2026
        
        ClearCut se compromete a proteger su privacidad.
        
        1. RECOPILACIÓN DE DATOS
        
        ClearCut procesa todas las imágenes localmente en su dispositivo. No subimos, almacenamos ni transmitimos sus fotos a ningún servidor externo.
        
        2. INFORMACIÓN PERSONAL
        
        No recopilamos información personal. No se requiere crear una cuenta.
        
        3. PROCESAMIENTO DE IMÁGENES
        
        Todas las operaciones se realizan en su dispositivo.
        
        4. ALMACENAMIENTO LOCAL
        
        Los datos del proyecto se almacenan localmente.
        
        5. SERVICIOS DE TERCEROS
        
        ClearCut puede mostrar anuncios.
        
        6. ANÁLISIS
        
        No utilizamos herramientas de análisis ni seguimiento.
        
        7. PRIVACIDAD INFANTIL
        
        ClearCut no recopila datos de menores de 13 años.
        
        8. CAMBIOS
        
        Podemos actualizar esta política.
        
        9. CONTACTO
        
        support@devlargou.com
        """
    ]
    
    private static let termsContent: [String: String] = [
        "en": """
        Last updated: February 2026
        
        Welcome to ClearCut. By downloading, installing, or using our application, you agree to the following Terms of Service.
        
        1. ACCEPTANCE OF TERMS
        
        By using ClearCut, you agree to be bound by these Terms. If you do not agree, please do not use the app.
        
        2. LICENSE
        
        We grant you a limited, non-exclusive, non-transferable, revocable license to use ClearCut for personal, non-commercial purposes in accordance with these Terms.
        
        3. USAGE RULES
        
        You agree not to:
        • Use the app for any illegal or unauthorized purpose
        • Reverse engineer, decompile, or disassemble the app
        • Remove any copyright or proprietary notices
        • Use the app to create content that infringes on others' rights
        
        4. INTELLECTUAL PROPERTY
        
        ClearCut and all its content, features, and functionality are owned by devlargou and are protected by copyright and other intellectual property laws.
        
        5. USER CONTENT
        
        You retain all rights to the images you edit using ClearCut. We do not claim any ownership over your content!
        
        6. DISCLAIMER
        
        ClearCut is provided "as is" without warranties of any kind. We do not guarantee that the app will be error-free or uninterrupted.
        
        7. LIMITATION OF LIABILITY
        
        To the fullest extent permitted by law, devlargou shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the app.
        
        8. TERMINATION
        
        We reserve the right to terminate or suspend your access to ClearCut at any time, without notice, for any reason.
        
        9. CHANGES TO TERMS
        
        We may modify these Terms at any time. Continued use of the app after changes constitutes acceptance of the new Terms.
        
        10. GOVERNING LAW
        
        These Terms shall be governed by and construed in accordance with the laws of the Federal Republic of Germany.
        
        11. CONTACT
        
        For questions about these Terms, contact us at:
        support@devlargou.com
        """,
        
        "de": """
        Zuletzt aktualisiert: Februar 2026
        
        Willkommen bei ClearCut. Durch das Herunterladen, Installieren oder Nutzen unserer App stimmen Sie den folgenden Allgemeinen Geschäftsbedingungen zu.
        
        1. ANNAHME DER BEDINGUNGEN
        
        Durch die Nutzung von ClearCut erklären Sie sich mit diesen AGB einverstanden. Wenn Sie nicht einverstanden sind, nutzen Sie die App bitte nicht.
        
        2. LIZENZ
        
        Wir gewähren Ihnen eine eingeschränkte, nicht-exklusive, nicht übertragbare, widerrufliche Lizenz zur Nutzung von ClearCut für persönliche, nicht-kommerzielle Zwecke.
        
        3. NUTZUNGSREGELN
        
        Sie verpflichten sich, die App nicht:
        • Für illegale oder unbefugte Zwecke zu nutzen
        • Zurückzuentwickeln, zu dekompilieren oder zu disassemblieren
        • Urheberrechts- oder Eigentumshinweise zu entfernen
        • Für Inhalte zu nutzen, die Rechte Dritter verletzen
        
        4. GEISTIGES EIGENTUM
        
        ClearCut und alle Inhalte, Funktionen und Merkmale sind Eigentum von devlargou und durch Urheberrecht geschützt.
        
        5. BENUTZERINHALTE
        
        Sie behalten alle Rechte an den Bildern, die Sie mit ClearCut bearbeiten. Wir erheben keinen Anspruch auf Ihre Inhalte.
        
        6. HAFTUNGSAUSSCHLUSS
        
        ClearCut wird „wie besehen" ohne jegliche Garantie bereitgestellt.
        
        7. HAFTUNGSBESCHRÄNKUNG
        
        Soweit gesetzlich zulässig, haftet devlargou nicht für indirekte, zufällige, besondere oder Folgeschäden.
        
        8. KÜNDIGUNG
        
        Wir behalten uns das Recht vor, Ihren Zugang jederzeit ohne Vorankündigung zu beenden.
        
        9. ÄNDERUNGEN DER AGB
        
        Wir können diese AGB jederzeit ändern. Die weitere Nutzung gilt als Annahme der neuen AGB.
        
        10. ANWENDBARES RECHT
        
        Diese AGB unterliegen dem Recht der Bundesrepublik Deutschland.
        
        11. KONTAKT
        
        Bei Fragen zu diesen AGB kontaktieren Sie uns:
        support@devlargou.com
        """,
        
        "fr": """
        Dernière mise à jour : Février 2026
        
        Bienvenue sur ClearCut. En utilisant notre application, vous acceptez les présentes Conditions.
        
        1. ACCEPTATION
        
        En utilisant ClearCut, vous acceptez ces conditions.
        
        2. LICENCE
        
        Nous vous accordons une licence limitée, non exclusive et révocable pour un usage personnel.
        
        3. RÈGLES D'UTILISATION
        
        Vous vous engagez à ne pas utiliser l'application à des fins illégales.
        
        4. PROPRIÉTÉ INTELLECTUELLE
        
        ClearCut est la propriété de devlargou.
        
        5. CONTENU UTILISATEUR
        
        Vous conservez tous les droits sur vos images.
        
        6. CLAUSE DE NON-RESPONSABILITÉ
        
        ClearCut est fourni « tel quel » sans aucune garantie.
        
        7. LIMITATION DE RESPONSABILITÉ
        
        devlargou ne saurait être tenu responsable des dommages indirects.
        
        8. RÉSILIATION
        
        Nous nous réservons le droit de suspendre votre accès.
        
        9. MODIFICATIONS
        
        Nous pouvons modifier ces conditions à tout moment.
        
        10. DROIT APPLICABLE
        
        Droit de la République fédérale d'Allemagne.
        
        11. CONTACT
        
        support@devlargou.com
        """,
        
        "es": """
        Última actualización: Febrero 2026
        
        Bienvenido a ClearCut. Al usar nuestra aplicación, acepta estos Términos.
        
        1. ACEPTACIÓN
        
        Al usar ClearCut, acepta estos términos.
        
        2. LICENCIA
        
        Le otorgamos una licencia limitada para uso personal.
        
        3. REGLAS DE USO
        
        Se compromete a no usar la aplicación para fines ilegales.
        
        4. PROPIEDAD INTELECTUAL
        
        ClearCut es propiedad de devlargou.
        
        5. CONTENIDO DEL USUARIO
        
        Usted conserva todos los derechos sobre sus imágenes.
        
        6. DESCARGO DE RESPONSABILIDAD
        
        ClearCut se proporciona "tal cual" sin garantías.
        
        7. LIMITACIÓN DE RESPONSABILIDAD
        
        devlargou no será responsable de daños indirectos.
        
        8. TERMINACIÓN
        
        Nos reservamos el derecho de suspender su acceso.
        
        9. CAMBIOS
        
        Podemos modificar estos términos.
        
        10. LEY APLICABLE
        
        Leyes de la República Federal de Alemania.
        
        11. CONTACTO
        
        support@devlargou.com
        """
    ]
}
