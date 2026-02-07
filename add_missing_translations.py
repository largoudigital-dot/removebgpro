#!/usr/bin/env python3
"""
Script to add MISSING translations to Localizable.xcstrings
Adds translations for keys that were missed in the previous batch
"""

import json

# Additional translations for missed UI elements
TRANSLATIONS = {
    "Weichheit": {
        "de": "Weichheit", "en": "Softness", "es": "Suavidad", "fr": "Douceur", "it": "Morbidezza",
        "nl": "Zachtheid", "pt-BR": "Suavidade", "pt-PT": "Suavidade",
        "ru": "Мягкость", "zh-Hans": "柔和度", "zh-Hant": "柔和度", "ja": "柔らかさ", "ko": "부드러움",
        "ar": "نقولة", "tr": "Yumuşaklık", "hi": "कोमलता", "pl": "Miękkość", "sv": "Mjukhet",
        "da": "Blødhed", "nb": "Mykhet", "fi": "Pehmeys", "el": "Απαλότητα", "he": "רכות",
        "th": "ความนุ่มนวล", "vi": "Độ mềm", "id": "Kelembutan", "ms": "Kelembutan", "cs": "Měkkost",
        "hu": "Lágyság", "ro": "Finețe", "uk": "М'якість", "hr": "Mekoća", "sk": "Mäkkosť",
        "ca": "Suavitat", "bg": "Мекота", "lt": "Minkštumas", "lv": "Mīkstums", "et": "Pehmus",
        "fa": "نرمی"
    },
    "X-Versatz": {
        "de": "X-Versatz", "en": "X Offset", "es": "Desplazamiento X", "fr": "Décalage X", "it": "Offset X",
        "nl": "X-verschuiving", "pt-BR": "Deslocamento X", "pt-PT": "Deslocamento X",
        "ru": "Смещение по X", "zh-Hans": "X 偏移", "zh-Hant": "X 偏移", "ja": "Xオフセット", "ko": "X 오프셋",
        "ar": "إزاحة X", "tr": "X Kaydırma", "hi": "X ऑफसेट", "pl": "Przesunięcie X", "sv": "X-offset",
        "da": "X-forskydning", "nb": "X-forskyvning", "fi": "X-siirtymä", "el": "Μετατόπιση X", "he": "היסט X",
        "th": "ออฟเซ็ต X", "vi": "Độ lệch X", "id": "Offset X", "ms": "Offset X", "cs": "Posun X",
        "hu": "X eltolás", "ro": "Decalaj X", "uk": "Зсув по X", "hr": "X pomak", "sk": "Posun X",
        "ca": "Desplaçament X", "bg": "X отместване", "lt": "X poslinkis", "lv": "X nobīde", "et": "X nihe",
        "fa": "انحراف X"
    },
    "Y-Versatz": {
        "de": "Y-Versatz", "en": "Y Offset", "es": "Desplazamiento Y", "fr": "Décalage Y", "it": "Offset Y",
        "nl": "Y-verschuiving", "pt-BR": "Deslocamento Y", "pt-PT": "Deslocamento Y",
        "ru": "Смещение по Y", "zh-Hans": "Y 偏移", "zh-Hant": "Y 偏移", "ja": "Yオフセット", "ko": "Y 오프셋",
        "ar": "إزاحة Y", "tr": "Y Kaydırma", "hi": "Y ऑफसेट", "pl": "Przesunięcie Y", "sv": "Y-offset",
        "da": "Y-forskydning", "nb": "Y-forskyvning", "fi": "Y-siirtymä", "el": "Μετατόπιση Y", "he": "היסט Y",
        "th": "ออฟเซ็ต Y", "vi": "Độ lệch Y", "id": "Offset Y", "ms": "Offset Y", "cs": "Posun Y",
        "hu": "Y eltolás", "ro": "Decalaj Y", "uk": "Зсув по Y", "hr": "Y pomak", "sk": "Posun Y",
        "ca": "Desplaçament Y", "bg": "Y отместване", "lt": "Y poslinkis", "lv": "Y nobīde", "et": "Y nihe",
        "fa": "انحراف Y"
    },
    "Deckkraft": {
        "de": "Deckkraft", "en": "Opacity", "es": "Opacidad", "fr": "Opacité", "it": "Opacità",
        "nl": "Dekking", "pt-BR": "Opacidade", "pt-PT": "Opacidade",
        "ru": "Непрозрачность", "zh-Hans": "不透明度", "zh-Hant": "不透明度", "ja": "不透明度", "ko": "불투명도",
        "ar": "العتامة", "tr": "Opaklık", "hi": "अपारदर्शिता", "pl": "Krycie", "sv": "Opacitet",
        "da": "Gennemsigtighed", "nb": "Gjennomsiktighet", "fi": "Läpinäkyvyys", "el": "Αδιαφάνεια", "he": "אטימות",
        "th": "ความทึบ", "vi": "Độ mờ", "id": "Opasitas", "ms": "Kelegapan", "cs": "Krytí",
        "hu": "Átlátszatlanság", "ro": "Opacitate", "uk": "Непрозорість", "hr": "Neprozirnost", "sk": "Krytie",
        "ca": "Opacitat", "bg": "Непрозрачност", "lt": "Nepermatomumas", "lv": "Necaurspīdīgums", "et": "Läbipaistmatus",
        "fa": "کدورت"
    },
    "Alle Reset": {
        "de": "Alle Reset", "en": "Reset All", "es": "Restablecer todo", "fr": "Tout réinitialiser", "it": "Ripristina tutto",
        "nl": "Alles resetten", "pt-BR": "Redefinir tudo", "pt-PT": "Repor tudo",
        "ru": "Сбросить все", "zh-Hans": "全部重置", "zh-Hant": "全部重設", "ja": "すべてリセット", "ko": "모두 재설정",
        "ar": "إعادة تعيين الكل", "tr": "Tümünü sıfırla", "hi": "सभी रीसेट करें", "pl": "Zresetuj wszystko", "sv": "Återställ allt",
        "da": "Nulstil alt", "nb": "Tilbakestill alt", "fi": "Nollaa kaikki", "el": "Επαναφορά όλων", "he": "אפס הכל",
        "th": "รีเซ็ตทั้งหมด", "vi": "Đặt lại tất cả", "id": "Atur ulang semua", "ms": "Tetapkan semula semua", "cs": "Obnovit vše",
        "hu": "Összes visszaállítása", "ro": "Resetează tot", "uk": "Скинути все", "hr": "Resetiraj sve", "sk": "Obnoviť všetko",
        "ca": "Restablir tot", "bg": "Нулиране на всичко", "lt": "Atstatyti viską", "lv": "Atiestatīt visu", "et": "Lähtesta kõik",
        "fa": "بازنشانی همه"
    },
    "Farbe wählen": {
        "de": "Farbe wählen", "en": "Choose Color", "es": "Elegir color", "fr": "Choisir une couleur", "it": "Scegli colore",
        "nl": "Kleur kiezen", "pt-BR": "Escolher cor", "pt-PT": "Escolher cor",
        "ru": "Выбрать цвет", "zh-Hans": "选择颜色", "zh-Hant": "選擇顏色", "ja": "色を選択", "ko": "색상 선택",
        "ar": "اختر اللون", "tr": "Renk seç", "hi": "رंग चुनें", "pl": "Wybierz kolor", "sv": "Välj färg",
        "da": "Vælg farve", "nb": "Velg farge", "fi": "Valitse väri", "el": "Επιλογή χρώματος", "he": "بחר צבע",
        "th": "เลือกสี", "vi": "Chọn màu", "id": "Pilih warna", "ms": "Pilih warna", "cs": "Vybrat barvu",
        "hu": "Szín választása", "ro": "Alege culoarea", "uk": "Вибрати колір", "hr": "Odaberi boju", "sk": "Vybrať farbu",
        "ca": "Triar color", "bg": "Избор на цвят", "lt": "Pasirinkti spalvą", "lv": "Izvēlēties krāsu", "et": "Vali värv",
        "fa": "انتخاب رنگ"
    },
    "Glow": {
        "de": "Leuchten", "en": "Glow", "es": "Resplandor", "fr": "Lueur", "it": "Bagliore",
        "nl": "Gloed", "pt-BR": "Brilho", "pt-PT": "Brilho",
        "ru": "Свечение", "zh-Hans": "发光", "zh-Hant": "發光", "ja": "輝き", "ko": "광채",
        "ar": "توهج", "tr": "Parıltı", "hi": "चमक", "pl": "Poświata", "sv": "Glöd",
        "da": "Glød", "nb": "Glød", "fi": "Hehku", "el": "Λάμψη", "he": "זוהר",
        "th": "เรืองแสง", "vi": "Phát sáng", "id": "Bersinar", "ms": "Bersinar", "cs": "Záře",
        "hu": "Ragyogás", "ro": "Strălucire", "uk": "Світіння", "hr": "Sjaj", "sk": "Žiara",
        "ca": "Resplendor", "bg": "Сяйво", "lt": "Švytėjimas", "lv": "Spīdums", "et": "Kumamine",
        "fa": "درخشش"
    },
    "Antique": {
        "de": "Antik", "en": "Antique", "es": "Antiguo", "fr": "Antique", "it": "Antico",
        "nl": "Antiek", "pt-BR": "Antigo", "pt-PT": "Antigo",
        "ru": "Антик", "zh-Hans": "复古", "zh-Hant": "復古", "ja": "アンティーク", "ko": "앤티크",
        "ar": "عتيق", "tr": "Antika", "hi": "प्राचीन", "pl": "Antyk", "sv": "Antik",
        "da": "Antik", "nb": "Antikk", "fi": "Antiikki", "el": "Αντίκα", "he": "עתיק",
        "th": "โบราณ", "vi": "Cổ điển", "id": "Antik", "ms": "Antik", "cs": "Starožitný",
        "hu": "Antik", "ro": "Antic", "uk": "Антик", "hr": "Antika", "sk": "Starožitné",
        "ca": "Antic", "bg": "Античен", "lt": "Antikvarinis", "lv": "Antīks", "et": "Antiik",
        "fa": "عتیقه"
    },
    "Studio": {
        "de": "Studio", "en": "Studio", "es": "Estudio", "fr": "Studio", "it": "Studio",
        "nl": "Studio", "pt-BR": "Estúdio", "pt-PT": "Estúdio",
        "ru": "Студия", "zh-Hans": "工作室", "zh-Hant": "工作室", "ja": "スタジオ", "ko": "스튜디오",
        "ar": "ستوديو", "tr": "Stüdyo", "hi": "स्टूडियो", "pl": "Studio", "sv": "Studio",
        "da": "Studie", "nb": "Studio", "fi": "Studio", "el": "Στούντιο", "he": "סטודיו",
        "th": "สตูดิโอ", "vi": "Studio", "id": "Studio", "ms": "Studio", "cs": "Studio",
        "hu": "Stúdió", "ro": "Studio", "uk": "Студія", "hr": "Studio", "sk": "Štúdio",
        "ca": "Estudi", "bg": "Студио", "lt": "Studija", "lv": "Studija", "et": "Stuudio",
        "fa": "استودیو"
    },
    "Fertig": {
        "de": "Fertig", "en": "Done", "es": "Listo", "fr": "Terminé", "it": "Fatto",
        "nl": "Klaar", "pt-BR": "Concluído", "pt-PT": "Concluído",
        "ru": "Готово", "zh-Hans": "完成", "zh-Hant": "完成", "ja": "完了", "ko": "완료",
        "ar": "تم", "tr": "Tamamlandı", "hi": "हो गया", "pl": "Gotowe", "sv": "Klar",
        "da": "Færdig", "nb": "Ferdig", "fi": "Valmis", "el": "Τέλος", "he": "בוצע",
        "th": "เสร็จสิ้น", "vi": "Xong", "id": "Selesai", "ms": "Selesai", "cs": "Hotovo",
        "hu": "Kész", "ro": "Gata", "uk": "Готово", "hr": "Gotovo", "sk": "Hotovo",
        "ca": "Fet", "bg": "Готово", "lt": "Atlikta", "lv": "Gatavs", "et": "Valmis",
        "fa": "انجام شد"
    },
    "Kontrast": {
        "de": "Kontrast", "en": "Contrast", "es": "Contraste", "fr": "Contraste", "it": "Contrasto",
        "nl": "Contrast", "pt-BR": "Contraste", "pt-PT": "Contraste",
        "ru": "Контраст", "zh-Hans": "对比度", "zh-Hant": "對比度", "ja": "コントラスト", "ko": "대비",
        "ar": "التباين", "tr": "Kontrast", "hi": "कंट्रास्ट", "pl": "Kontrast", "sv": "Kontrast",
        "da": "Kontrast", "nb": "Kontrast", "fi": "Kontrasti", "el": "Αντίθεση", "he": "ניגודיות",
        "th": "ความคมชัด", "vi": "Độ tương phản", "id": "Kontras", "ms": "Kontras", "cs": "Kontrast",
        "hu": "Kontraszt", "ro": "Contrast", "uk": "Контраст", "hr": "Kontrast", "sk": "Kontrast",
        "ca": "Contrast", "bg": "Контраст", "lt": "Kontrastas", "lv": "Kontrasts", "et": "Kontrast",
        "fa": "تضاد"
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
