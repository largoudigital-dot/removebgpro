#!/usr/bin/env python3
"""
Script to add MISSING home screen translations to Localizable.xcstrings
Fixes "Foto auswählen", "Aus Galerie wählen", and main title
"""

import json

# Additional translations for home screen elements
TRANSLATIONS = {
    "Aus Galerie wählen": {
        "de": "Aus Galerie wählen", "en": "Select from Gallery", "es": "Seleccionar de la galería", "fr": "Choisir dans la galerie", "it": "Scegli dalla galleria",
        "nl": "Kies uit galerij", "pt-BR": "Escolher da galeria", "pt-PT": "Escolher da galeria",
        "ru": "Выбрать из галереи", "zh-Hans": "从相册选择", "zh-Hant": "從相簿選擇", "ja": "ギャラリーから選択", "ko": "갤러리에서 선택",
        "ar": "اختر من المعرض", "tr": "Galeriden seç", "hi": "गैलरी से चुनें", "pl": "Wybierz z galerii", "sv": "Välj från galleri",
        "da": "Vælg fra galleri", "nb": "Velg fra galleri", "fi": "Valitse galleriasta", "el": "Επιλογή από τη συλλογή", "he": "בחר מהגלריה",
        "th": "เลือกจากแกลเลอรี", "vi": "Chọn từ thư viện", "id": "Pilih dari galeri", "ms": "Pilih dari galeri", "cs": "Vybrat z galerie",
        "hu": "Választás a galériából", "ro": "Alege din galerie", "uk": "Вибрати з галереї", "hr": "Odaberi iz galerije", "sk": "Vybrať z galérie",
        "ca": "Triar de la galeria", "bg": "Избор от галерията", "lt": "Pasirinkti iš galerijos", "lv": "Izvēlēties no galerijas", "et": "Vali galeriist",
        "fa": "انتخاب از گالری"
    },
    "Foto auswählen": {
        "de": "Foto auswählen", "en": "Select Photo", "es": "Seleccionar foto", "fr": "Sélectionner une photo", "it": "Seleziona foto",
        "nl": "Foto selecteren", "pt-BR": "Selecionar foto", "pt-PT": "Selecionar fotografia",
        "ru": "Выбрать фото", "zh-Hans": "选择照片", "zh-Hant": "選擇照片", "ja": "写真を選択", "ko": "사진 선택",
        "ar": "اختر صورة", "tr": "Fotoğraf seç", "hi": "фото चुनें", "pl": "Wybierz zdjęcie", "sv": "Välj foto",
        "da": "Vælg foto", "nb": "Velg bilde", "fi": "Valitse kuva", "el": "Επιλογή φωτογραφίας", "he": "בחר תמונה",
        "th": "เลือกรูปภาพ", "vi": "Chọn ảnh", "id": "Pilih foto", "ms": "Pilih foto", "cs": "Vybrat fotku",
        "hu": "Fotó kiválasztása", "ro": "Selectează o fotografie", "uk": "Вибрати фото", "hr": "Odaberi fotografiju", "sk": "Vybrať fotografiu",
        "ca": "Seleccionar foto", "bg": "Избор на снимка", "lt": "Pasirinkti nuotrauką", "lv": "Izvēlēties fotoattēlu", "et": "Vali foto",
        "fa": "انتخاب عکس"
    },
    "Erstelle brillante Ausschnitte & Sticker": {
        "de": "Erstelle brillante Ausschnitte & Sticker", "en": "Create brilliant cutouts & stickers", "es": "Crea recortes y stickers brillantes", "fr": "Créez des découpes et autocollants", "it": "Crea ritagli e adesivi brillanti",
        "nl": "Maak briljante uitsnedes en stickers", "pt-BR": "Crie recortes e adesivos incríveis", "pt-PT": "Crie recortes e autocolantes incríveis",
        "ru": "Создавайте блестящие вырезы и стикеры", "zh-Hans": "创建精彩的剪纸和贴纸", "zh-Hant": "建立精彩的剪紙和貼圖", "ja": "素晴らしい切り抜きとステッカーを作成", "ko": "멋진 오려내기 및 스티커 만들기",
        "ar": "اصنع قصاصات وملصقات رائعة", "tr": "Harika kesimler ve çıkartmalar oluştur", "hi": "शानदार कटआउट और स्टिकर बनाएं", "pl": "Twórz wspaniałe wycinki i naklejki", "sv": "Skapa lysande utsnitt och klistermärken",
        "da": "Opret flotte udklip og klistermærker", "nb": "Lag flotte utklipp og klistremerker", "fi": "Luo upeita leikkeitä ja tarroja", "el": "Δημιουργήστε υπέροχα αποκόμματα και αυτοκόλλητα", "he": "צור חיתוכים ומדבקות מבריקים",
        "th": "สร้างภาพตัดและสติกเกอร์ที่ยอดเยี่ยม", "vi": "Tạo các hình cắt và nhãn dán tuyệt vời", "id": "Buat potongan dan stiker yang cemerlang", "ms": "Cipta potongan dan pelekat yang hebat", "cs": "Vytvářejte skvělé výřezy a nálepky",
        "hu": "Készíts briliáns kivágásokat és matricákat", "ro": "Creează decupaje și stickere strălucitoare", "uk": "Створюйте чудові вирізки та наклейки", "hr": "Stvorite sjajne izrezke i naljepnice", "sk": "Vytvárajte skvelé výrezy a nálepky",
        "ca": "Crea retalls i adhesius brillants", "bg": "Създавайте страхотни изрезки и стикери", "lt": "Kurkite puikius karpinius ir lipdukus", "lv": "Izveidojiet lieliskus izgriezumus un uzlīmes", "et": "Loo suurepäraseid väljalõikeid ja kleebiseid",
        "fa": "برش‌ها و استیکرهای درخشان بسازید"
    },
    "Zurück": {
        "de": "Zurück", "en": "Back", "es": "Atrás", "fr": "Retour", "it": "Indietro",
        "nl": "Terug", "pt-BR": "Voltar", "pt-PT": "Voltar",
        "ru": "Назад", "zh-Hans": "返回", "zh-Hant": "返回", "ja": "戻る", "ko": "뒤로",
        "ar": "رجوع", "tr": "Geri", "hi": "वापस", "pl": "Wstecz", "sv": "Tillbaka",
        "da": "Tilbage", "nb": "Tilbake", "fi": "Takaisin", "el": "Πίσω", "he": "חזור",
        "th": "ย้อนกลับ", "vi": "Quay lại", "id": "Kembali", "ms": "Kembali", "cs": "Zpět",
        "hu": "Vissza", "ro": "Înapoi", "uk": "Назад", "hr": "Natrag", "sk": "Späť",
        "ca": "Enrere", "bg": "Назад", "lt": "Atgal", "lv": "Atpakaļ", "et": "Tagasi",
        "fa": "بازگشت"
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
