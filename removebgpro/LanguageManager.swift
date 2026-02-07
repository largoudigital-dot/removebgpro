import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @AppStorage("app_language_override") var selectedLanguage: String = "" {
        didSet {
            objectWillChange.send()
        }
    }
    
    // Automatically detect system language on first launch
    init() {
        // Only auto-detect if no language has been selected yet
        if selectedLanguage.isEmpty {
            let systemLang = Locale.preferredLanguages.first ?? "en"
            let langCode = extractLanguageCode(from: systemLang)
            
            // Check if the system language is supported
            if supportedLanguages.contains(where: { $0.id == langCode }) {
                selectedLanguage = langCode
            } else {
                // Fallback to English if system language is not supported
                selectedLanguage = "en"
            }
        }
    }
    
    // Extract language code from locale identifier (e.g., "en-US" -> "en", "pt-BR" -> "pt-BR")
    private func extractLanguageCode(from identifier: String) -> String {
        // Handle special cases like pt-BR, zh-Hans, zh-Hant
        if identifier.hasPrefix("pt-BR") || identifier.hasPrefix("pt_BR") {
            return "pt-BR"
        } else if identifier.hasPrefix("pt-PT") || identifier.hasPrefix("pt_PT") {
            return "pt-PT"
        } else if identifier.hasPrefix("zh-Hans") || identifier.hasPrefix("zh_Hans") {
            return "zh-Hans"
        } else if identifier.hasPrefix("zh-Hant") || identifier.hasPrefix("zh_Hant") {
            return "zh-Hant"
        } else if identifier.hasPrefix("nb") || identifier.hasPrefix("no") {
            return "nb"
        }
        
        // For most languages, just take the first component
        return identifier.components(separatedBy: CharacterSet(charactersIn: "-_")).first ?? "en"
    }
    
    // Get the effective language (with fallback)
    var effectiveLanguage: String {
        if selectedLanguage.isEmpty {
            return "en"
        }
        return selectedLanguage
    }
    
    // Check if current language is RTL (Right-to-Left)
    var isRTL: Bool {
        ["ar", "he", "fa"].contains(effectiveLanguage)
    }
    
    var locale: Locale {
        return Locale(identifier: effectiveLanguage)
    }
    
    let supportedLanguages: [LanguageInfo] = [
        LanguageInfo(id: "de", name: "Deutsch", flag: "🇩🇪"),
        LanguageInfo(id: "en", name: "English", flag: "🇺🇸"),
        LanguageInfo(id: "fr", name: "Français", flag: "🇫🇷"),
        LanguageInfo(id: "es", name: "Español", flag: "🇪🇸"),
        LanguageInfo(id: "it", name: "Italiano", flag: "🇮🇹"),
        LanguageInfo(id: "pt-BR", name: "Português (Brasil)", flag: "🇧🇷"),
        LanguageInfo(id: "pt-PT", name: "Português (Portugal)", flag: "🇵🇹"),
        LanguageInfo(id: "nl", name: "Nederlands", flag: "🇳🇱"),
        LanguageInfo(id: "ru", name: "Русский", flag: "🇷🇺"),
        LanguageInfo(id: "zh-Hans", name: "简体中文", flag: "🇨🇳"),
        LanguageInfo(id: "zh-Hant", name: "繁體中文", flag: "🇭🇰"),
        LanguageInfo(id: "ja", name: "日本語", flag: "🇯🇵"),
        LanguageInfo(id: "ko", name: "한국어", flag: "🇰🇷"),
        LanguageInfo(id: "tr", name: "Türkçe", flag: "🇹🇷"),
        LanguageInfo(id: "ar", name: "العربية", flag: "🇸🇦"),
        LanguageInfo(id: "hi", name: "हिन्दी", flag: "🇮🇳"),
        LanguageInfo(id: "pl", name: "Polski", flag: "🇵🇱"),
        LanguageInfo(id: "sv", name: "Svenska", flag: "🇸🇪"),
        LanguageInfo(id: "da", name: "Dansk", flag: "🇩🇰"),
        LanguageInfo(id: "nb", name: "Norsk bokmål", flag: "🇳🇴"),
        LanguageInfo(id: "fi", name: "Suomi", flag: "🇫🇮"),
        LanguageInfo(id: "el", name: "Ελληνικά", flag: "🇬🇷"),
        LanguageInfo(id: "he", name: "עברית", flag: "🇮🇱"),
        LanguageInfo(id: "th", name: "ไทย", flag: "🇹🇭"),
        LanguageInfo(id: "vi", name: "Tiếng Việt", flag: "🇻🇳"),
        LanguageInfo(id: "id", name: "Bahasa Indonesia", flag: "🇮🇩"),
        LanguageInfo(id: "ms", name: "Bahasa Melayu", flag: "🇲🇾"),
        LanguageInfo(id: "cs", name: "Čeština", flag: "🇨🇿"),
        LanguageInfo(id: "hu", name: "Magyar", flag: "🇭🇺"),
        LanguageInfo(id: "ro", name: "Română", flag: "🇷🇴"),
        LanguageInfo(id: "uk", name: "Українська", flag: "🇺🇦"),
        LanguageInfo(id: "hr", name: "Hrvatski", flag: "🇭🇷"),
        LanguageInfo(id: "sk", name: "Slovenčina", flag: "🇸🇰"),
        LanguageInfo(id: "ca", name: "Català", flag: "🇪🇸"),
        LanguageInfo(id: "bg", name: "Български", flag: "🇧🇬"),
        LanguageInfo(id: "lt", name: "Lietuvių", flag: "🇱🇹"),
        LanguageInfo(id: "lv", name: "Latviešu", flag: "🇱🇻"),
        LanguageInfo(id: "et", name: "Eesti", flag: "🇪🇪"),
        LanguageInfo(id: "fa", name: "فارسی", flag: "🇮🇷")
    ]
}

struct LanguageInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let flag: String
}
