#!/usr/bin/env python3
"""
Script to add "Deine Reise beginnt hier" translations to Localizable.xcstrings
"""

import json

# Additional translations for home screen elements
TRANSLATIONS = {
    "Deine Reise beginnt hier": {
        "de": "Deine Reise beginnt hier", "en": "Your journey starts here", "es": "Tu viaje comienza aquí", "fr": "Votre voyage commence ici", "it": "Il tuo viaggio inizia qui",
        "nl": "Je reis begint hier", "pt-BR": "Sua jornada começa aqui", "pt-PT": "A tua viagem começa aqui",
        "ru": "Ваше путешествие начинается здесь", "zh-Hans": "您的旅程从这里开始", "zh-Hant": "您的旅程從這裡開始", "ja": "あなたの旅はここから始まります", "ko": "당신의 여정이 여기서 시작됩니다",
        "ar": "رحلتك تبدأ هنا", "tr": "Yolculuğun burada başlıyor", "hi": "आपकी यात्रा यहाँ से शुरू होती है", "pl": "Twoja podróż zaczyna się tutaj", "sv": "Din resa börjar här",
        "da": "Din rejse begynder her", "nb": "Din reise begynner her", "fi": "Matkasi alkaa tästä", "el": "Το ταξίδι σου ξεκινά εδώ", "he": "המסע שלך מתחיל כאן",
        "th": "การเดินทางของคุณเริ่มต้นที่นี่", "vi": "Hành trình của bạn bắt đầu tại đây", "id": "Perjalanan Anda dimulai di sini", "ms": "Perjalanan anda bermula di sini", "cs": "Vaše cesta začíná zde",
        "hu": "Az utazásod itt kezdődik", "ro": "Călătoria ta începe aici", "uk": "Ваша подорож починається тут", "hr": "Tvoje putovanje počinje ovdje", "sk": "Vaša cesta začína tu",
        "ca": "El teu viatge comença aquí", "bg": "Вашето пътуване започва тук", "lt": "Jūsų kelionė prasideda čia", "lv": "Jūsu ceļojums sākas šeit", "et": "Sinu teekond algab siit",
        "fa": "سفر شما از اینجا آغاز می‌شود"
    }
}

def load_xcstrings(filepath):
    """Load the Localizable.xcstrings file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_xcstrings(filepath, data):
    """Save the Localizable.xcstrings file"""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def add_missing_translations(filepath):
    """Add missing translations to the xcstrings file"""
    print(f"Loading {filepath}...")
    data = load_xcstrings(filepath)
    
    translations_added = 0
    keys_updated = 0
    
    for key, translations in TRANSLATIONS.items():
        if key in data['strings']:
            keys_updated += 1
            if 'localizations' not in data['strings'][key]:
                data['strings'][key]['localizations'] = {}
            
            for lang_code, translation in translations.items():
                # Only add if not already present or if we want to overwrite
                # existing check handles partially filled keys
                data['strings'][key]['localizations'][lang_code] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translation
                    }
                }
                translations_added += 1
        else:
            print(f"Adding new key '{key}'")
            keys_updated += 1
            data['strings'][key] = {
                "extractionState": "manual",
                "localizations": {}
            }
            for lang_code, translation in translations.items():
                data['strings'][key]['localizations'][lang_code] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translation
                    }
                }
                translations_added += 1
    
    print(f"Saving {filepath}...")
    save_xcstrings(filepath, data)
    
    print(f"\n✅ Success!")
    print(f"   Updated {keys_updated} keys")
    print(f"   Added {translations_added} translations")

if __name__ == "__main__":
    filepath = "/Users/blargou/Desktop/removebgpro/removebgpro/Localizable.xcstrings"
    add_missing_translations(filepath)
