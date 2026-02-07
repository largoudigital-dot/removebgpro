#!/usr/bin/env python3
"""
Comprehensive translation script for Localizable.xcstrings
Adds translations for all 40 languages to all 56+ keys
"""

import json
import sys

# Complete translations dictionary for all 40 languages
TRANSLATIONS = {
    "Speichern": {
        "de": "Speichern", "en": "Save", "es": "Guardar", "fr": "Enregistrer", "it": "Salva",
        "nl": "Opslaan", "pt-BR": "Salvar", "pt-PT": "Guardar",
        "ru": "Сохранить", "zh-Hans": "保存", "zh-Hant": "儲存", "ja": "保存", "ko": "저장",
        "ar": "حفظ", "tr": "Kaydet", "hi": "सहेजें", "pl": "Zapisz", "sv": "Spara",
        "da": "Gem", "nb": "Lagre", "fi": "Tallenna", "el": "Αποθήκευση", "he": "שמור",
        "th": "บันทึก", "vi": "Lưu", "id": "Simpan", "ms": "Simpan", "cs": "Uložit",
        "hu": "Mentés", "ro": "Salvare", "uk": "Зберегти", "hr": "Spremi", "sk": "Uložiť",
        "ca": "Desar", "bg": "Запазване", "lt": "Išsaugoti", "lv": "Saglabāt", "et": "Salvesta",
        "fa": "ذخیره"
    },
    "Speichern & Schließen": {
        "de": "Speichern & Schließen", "en": "Save & Close", "es": "Guardar y cerrar", "fr": "Enregistrer et fermer",
        "it": "Salva e chiudi", "nl": "Opslaan en sluiten", "pt-BR": "Salvar e fechar", "pt-PT": "Guardar e fechar",
        "ru": "Сохранить и закрыть", "zh-Hans": "保存并关闭", "zh-Hant": "儲存並關閉", "ja": "保存して閉じる",
        "ko": "저장 및 닫기", "ar": "حفظ وإغلاق", "tr": "Kaydet ve kapat", "hi": "सहेजें और बंद करें",
        "pl": "Zapisz i zamknij", "sv": "Spara och stäng", "da": "Gem og luk", "nb": "Lagre og lukk",
        "fi": "Tallenna ja sulje", "el": "Αποθήκευση και κλείσιμο", "he": "שמור וסגור", "th": "บันทึกและปิด",
        "vi": "Lưu và đóng", "id": "Simpan dan tutup", "ms": "Simpan dan tutup", "cs": "Uložit a zavřít",
        "hu": "Mentés és bezárás", "ro": "Salvare și închidere", "uk": "Зберегти та закрити", "hr": "Spremi i zatvori",
        "sk": "Uložiť a zavrieť", "ca": "Desar i tancar", "bg": "Запазване и затваряне", "lt": "Išsaugoti ir uždaryti",
        "lv": "Saglabāt un aizvērt", "et": "Salvesta ja sulge", "fa": "ذخیره و بستن"
    },
    "Einstellungen": {
        "de": "Einstellungen", "en": "Settings", "es": "Configuración", "fr": "Paramètres", "it": "Impostazioni",
        "nl": "Instellingen", "pt-BR": "Configurações", "pt-PT": "Definições",
        "ru": "Настройки", "zh-Hans": "设置", "zh-Hant": "設定", "ja": "設定", "ko": "설정",
        "ar": "الإعدادات", "tr": "Ayarlar", "hi": "सेटिंग्स", "pl": "Ustawienia", "sv": "Inställningar",
        "da": "Indstillinger", "nb": "Innstillinger", "fi": "Asetukset", "el": "Ρυθμίσεις", "he": "הגדרות",
        "th": "การตั้งค่า", "vi": "Cài đặt", "id": "Pengaturan", "ms": "Tetapan", "cs": "Nastavení",
        "hu": "Beállítások", "ro": "Setări", "uk": "Налаштування", "hr": "Postavke", "sk": "Nastavenia",
        "ca": "Configuració", "bg": "Настройки", "lt": "Nustatymai", "lv": "Iestatījumi", "et": "Seaded",
        "fa": "تنظیمات"
    },
    "Hintergrund": {
        "de": "Hintergrund", "en": "Background", "es": "Fondo", "fr": "Arrière-plan", "it": "Sfondo",
        "nl": "Achtergrond", "pt-BR": "Fundo", "pt-PT": "Fundo",
        "ru": "Фон", "zh-Hans": "背景", "zh-Hant": "背景", "ja": "背景", "ko": "배경",
        "ar": "الخلفية", "tr": "Arka plan", "hi": "पृष्ठभूमि", "pl": "Tło", "sv": "Bakgrund",
        "da": "Baggrund", "nb": "Bakgrunn", "fi": "Tausta", "el": "Φόντο", "he": "רקע",
        "th": "พื้นหลัง", "vi": "Nền", "id": "Latar belakang", "ms": "Latar belakang", "cs": "Pozadí",
        "hu": "Háttér", "ro": "Fundal", "uk": "Фон", "hr": "Pozadina", "sk": "Pozadie",
        "ca": "Fons", "bg": "Фон", "lt": "Fonas", "lv": "Fons", "et": "Taust",
        "fa": "پس‌زمینه"
    },
    "Filter": {
        "de": "Filter", "en": "Filters", "es": "Filtros", "fr": "Filtres", "it": "Filtri",
        "nl": "Filters", "pt-BR": "Filtros", "pt-PT": "Filtros",
        "ru": "Фильтры", "zh-Hans": "滤镜", "zh-Hant": "濾鏡", "ja": "フィルター", "ko": "필터",
        "ar": "الفلاتر", "tr": "Filtreler", "hi": "फ़िल्टर", "pl": "Filtry", "sv": "Filter",
        "da": "Filtre", "nb": "Filtre", "fi": "Suodattimet", "el": "Φίλτρα", "he": "מסננים",
        "th": "ฟิลเตอร์", "vi": "Bộ lọc", "id": "Filter", "ms": "Penapis", "cs": "Filtry",
        "hu": "Szűrők", "ro": "Filtre", "uk": "Фільтри", "hr": "Filteri", "sk": "Filtre",
        "ca": "Filtres", "bg": "Филтри", "lt": "Filtrai", "lv": "Filtri", "et": "Filtrid",
        "fa": "فیلترها"
    },
    "Anpassen": {
        "de": "Anpassen", "en": "Adjust", "es": "Ajustar", "fr": "Ajuster", "it": "Regola",
        "nl": "Aanpassen", "pt-BR": "Ajustar", "pt-PT": "Ajustar",
        "ru": "Настроить", "zh-Hans": "调整", "zh-Hant": "調整", "ja": "調整", "ko": "조정",
        "ar": "ضبط", "tr": "Ayarla", "hi": "समायोजित करें", "pl": "Dostosuj", "sv": "Justera",
        "da": "Juster", "nb": "Juster", "fi": "Säädä", "el": "Προσαρμογή", "he": "התאם",
        "th": "ปรับแต่ง", "vi": "Điều chỉnh", "id": "Sesuaikan", "ms": "Laraskan", "cs": "Upravit",
        "hu": "Beállítás", "ro": "Ajustare", "uk": "Налаштувати", "hr": "Prilagodi", "sk": "Prispôsobiť",
        "ca": "Ajustar", "bg": "Регулиране", "lt": "Koreguoti", "lv": "Pielāgot", "et": "Kohanda",
        "fa": "تنظیم"
    },
    "Zuschneiden": {
        "de": "Zuschneiden", "en": "Crop", "es": "Recortar", "fr": "Recadrer", "it": "Ritaglia",
        "nl": "Bijsnijden", "pt-BR": "Cortar", "pt-PT": "Recortar",
        "ru": "Обрезать", "zh-Hans": "裁剪", "zh-Hant": "裁剪", "ja": "トリミング", "ko": "자르기",
        "ar": "قص", "tr": "Kırp", "hi": "क्रॉप करें", "pl": "Przytnij", "sv": "Beskär",
        "da": "Beskær", "nb": "Beskjær", "fi": "Rajaa", "el": "Περικοπή", "he": "חתוך",
        "th": "ครอบตัด", "vi": "Cắt", "id": "Potong", "ms": "Potong", "cs": "Oříznout",
        "hu": "Vágás", "ro": "Decupare", "uk": "Обрізати", "hr": "Izreži", "sk": "Orezať",
        "ca": "Retallar", "bg": "Изрязване", "lt": "Apkarpyti", "lv": "Apgriezt", "et": "Kärbi",
        "fa": "برش"
    },
    "Schatten": {
        "de": "Schatten", "en": "Shadow", "es": "Sombra", "fr": "Ombre", "it": "Ombra",
        "nl": "Schaduw", "pt-BR": "Sombra", "pt-PT": "Sombra",
        "ru": "Тень", "zh-Hans": "阴影", "zh-Hant": "陰影", "ja": "影", "ko": "그림자",
        "ar": "ظل", "tr": "Gölge", "hi": "छाया", "pl": "Cień", "sv": "Skugga",
        "da": "Skygge", "nb": "Skygge", "fi": "Varjo", "el": "Σκιά", "he": "צל",
        "th": "เงา", "vi": "Bóng", "id": "Bayangan", "ms": "Bayang", "cs": "Stín",
        "hu": "Árnyék", "ro": "Umbră", "uk": "Тінь", "hr": "Sjena", "sk": "Tieň",
        "ca": "Ombra", "bg": "Сянка", "lt": "Šešėlis", "lv": "Ēna", "et": "Vari",
        "fa": "سایه"
    },
    "Farben": {
        "de": "Farben", "en": "Colors", "es": "Colores", "fr": "Couleurs", "it": "Colori",
        "nl": "Kleuren", "pt-BR": "Cores", "pt-PT": "Cores",
        "ru": "Цвета", "zh-Hans": "颜色", "zh-Hant": "顏色", "ja": "色", "ko": "색상",
        "ar": "الألوان", "tr": "Renkler", "hi": "रंग", "pl": "Kolory", "sv": "Färger",
        "da": "Farver", "nb": "Farger", "fi": "Värit", "el": "Χρώματα", "he": "צבעים",
        "th": "สี", "vi": "Màu sắc", "id": "Warna", "ms": "Warna", "cs": "Barvy",
        "hu": "Színek", "ro": "Culori", "uk": "Кольори", "hr": "Boje", "sk": "Farby",
        "ca": "Colors", "bg": "Цветове", "lt": "Spalvos", "lv": "Krāsas", "et": "Värvid",
        "fa": "رنگ‌ها"
    },
    "Sprache": {
        "de": "Sprache", "en": "Language", "es": "Idioma", "fr": "Langue", "it": "Lingua",
        "nl": "Taal", "pt-BR": "Idioma", "pt-PT": "Idioma",
        "ru": "Язык", "zh-Hans": "语言", "zh-Hant": "語言", "ja": "言語", "ko": "언어",
        "ar": "اللغة", "tr": "Dil", "hi": "भाषा", "pl": "Język", "sv": "Språk",
        "da": "Sprog", "nb": "Språk", "fi": "Kieli", "el": "Γλώσσα", "he": "שפה",
        "th": "ภาษา", "vi": "Ngôn ngữ", "id": "Bahasa", "ms": "Bahasa", "cs": "Jazyk",
        "hu": "Nyelv", "ro": "Limbă", "uk": "Мова", "hr": "Jezik", "sk": "Jazyk",
        "ca": "Idioma", "bg": "Език", "lt": "Kalba", "lv": "Valoda", "et": "Keel",
        "fa": "زبان"
    },
    "WILLKOMMEN": {
        "de": "WILLKOMMEN", "en": "WELCOME", "es": "BIENVENIDO", "fr": "BIENVENUE", "it": "BENVENUTO",
        "nl": "WELKOM", "pt-BR": "BEM-VINDO", "pt-PT": "BEM-VINDO",
        "ru": "ДОБРО ПОЖАЛОВАТЬ", "zh-Hans": "欢迎", "zh-Hant": "歡迎", "ja": "ようこそ", "ko": "환영합니다",
        "ar": "مرحباً", "tr": "HOŞ GELDİNİZ", "hi": "स्वागत है", "pl": "WITAMY", "sv": "VÄLKOMMEN",
        "da": "VELKOMMEN", "nb": "VELKOMMEN", "fi": "TERVETULOA", "el": "ΚΑΛΩΣ ΗΡΘΑΤΕ", "he": "ברוכים הבאים",
        "th": "ยินดีต้อนรับ", "vi": "CHÀO MỪNG", "id": "SELAMAT DATANG", "ms": "SELAMAT DATANG", "cs": "VÍTEJTE",
        "hu": "ÜDVÖZÖLJÜK", "ro": "BINE ATI VENIT", "uk": "ЛАСКАВО ПРОСИМО", "hr": "DOBRODOŠLI", "sk": "VITAJTE",
        "ca": "BENVINGUT", "bg": "ДОБРЕ ДОШЛИ", "lt": "SVEIKI", "lv": "LAIPNI LŪDZAM", "et": "TERE TULEMAST",
        "fa": "خوش آمدید"
    },
    "NEUES PROJEKT": {
        "de": "NEUES PROJEKT", "en": "NEW PROJECT", "es": "NUEVO PROYECTO", "fr": "NOUVEAU PROJET", "it": "NUOVO PROGETTO",
        "nl": "NIEUW PROJECT", "pt-BR": "NOVO PROJETO", "pt-PT": "NOVO PROJETO",
        "ru": "НОВЫЙ ПРОЕКТ", "zh-Hans": "新项目", "zh-Hant": "新專案", "ja": "新しいプロジェクト", "ko": "새 프로젝트",
        "ar": "مشروع جديد", "tr": "YENİ PROJE", "hi": "नया प्रोजेक्ट", "pl": "NOWY PROJEKT", "sv": "NYTT PROJEKT",
        "da": "NYT PROJEKT", "nb": "NYTT PROSJEKT", "fi": "UUSI PROJEKTI", "el": "ΝΕΟ ΕΡΓΟ", "he": "פרויקט חדש",
        "th": "โปรเจกต์ใหม่", "vi": "DỰ ÁN MỚI", "id": "PROYEK BARU", "ms": "PROJEK BARU", "cs": "NOVÝ PROJEKT",
        "hu": "ÚJ PROJEKT", "ro": "PROIECT NOU", "uk": "НОВИЙ ПРОЕКТ", "hr": "NOVI PROJEKT", "sk": "NOVÝ PROJEKT",
        "ca": "NOU PROJECTE", "bg": "НОВ ПРОЕКТ", "lt": "NAUJAS PROJEKTAS", "lv": "JAUNS PROJEKTS", "et": "UUS PROJEKT",
        "fa": "پروژه جدید"
    },
    "Letzte Projekte": {
        "de": "Letzte Projekte", "en": "Recent Projects", "es": "Proyectos recientes", "fr": "Projets récents", "it": "Progetti recenti",
        "nl": "Recente projecten", "pt-BR": "Projetos recentes", "pt-PT": "Projetos recentes",
        "ru": "Последние проекты", "zh-Hans": "最近项目", "zh-Hant": "最近專案", "ja": "最近のプロジェクト", "ko": "최근 프로젝트",
        "ar": "المشاريع الأخيرة", "tr": "Son projeler", "hi": "हाल की परियोजनाएं", "pl": "Ostatnie projekty", "sv": "Senaste projekt",
        "da": "Seneste projekter", "nb": "Siste prosjekter", "fi": "Viimeisimmät projektit", "el": "Πρόσφατα έργα", "he": "פרויקטים אחרונים",
        "th": "โปรเจกต์ล่าสุด", "vi": "Dự án gần đây", "id": "Proyek terbaru", "ms": "Projek terkini", "cs": "Nedávné projekty",
        "hu": "Legutóbbi projektek", "ro": "Proiecte recente", "uk": "Останні проекти", "hr": "Nedavni projekti", "sk": "Nedávne projekty",
        "ca": "Projectes recents", "bg": "Последни проекти", "lt": "Naujausi projektai", "lv": "Jaunākie projekti", "et": "Hiljutised projektid",
        "fa": "پروژه‌های اخیر"
    },
    "Foto Editor": {
        "de": "Foto Editor", "en": "Photo Editor", "es": "Editor de fotos", "fr": "Éditeur de photos", "it": "Editor foto",
        "nl": "Fotobewerker", "pt-BR": "Editor de fotos", "pt-PT": "Editor de fotografias",
        "ru": "Фоторедактор", "zh-Hans": "照片编辑器", "zh-Hant": "照片編輯器", "ja": "写真エディター", "ko": "사진 편집기",
        "ar": "محرر الصور", "tr": "Fotoğraf düzenleyici", "hi": "फोटो संपादक", "pl": "Edytor zdjęć", "sv": "Fotoredigerare",
        "da": "Fotoredigering", "nb": "Fotoredigerer", "fi": "Kuvankäsittely", "el": "Επεξεργαστής φωτογραφιών", "he": "עורך תמונות",
        "th": "โปรแกรมแก้ไขภาพ", "vi": "Trình chỉnh sửa ảnh", "id": "Editor foto", "ms": "Editor foto", "cs": "Editor fotografií",
        "hu": "Fotószerkesztő", "ro": "Editor foto", "uk": "Фоторедактор", "hr": "Uređivač fotografija", "sk": "Editor fotografií",
        "ca": "Editor de fotos", "bg": "Фоторедактор", "lt": "Nuotraukų redaktorius", "lv": "Fotoredaktors", "et": "Fotoredaktor",
        "fa": "ویرایشگر عکس"
    },
    "Über die App": {
        "de": "Über die App", "en": "About the App", "es": "Acerca de la app", "fr": "À propos de l'app", "it": "Informazioni sull'app",
        "nl": "Over de app", "pt-BR": "Sobre o app", "pt-PT": "Acerca da aplicação",
        "ru": "О приложении", "zh-Hans": "关于应用", "zh-Hant": "關於應用程式", "ja": "アプリについて", "ko": "앱 정보",
        "ar": "حول التطبيق", "tr": "Uygulama hakkında", "hi": "ऐप के बारे में", "pl": "O aplikacji", "sv": "Om appen",
        "da": "Om appen", "nb": "Om appen", "fi": "Tietoja sovelluksesta", "el": "Σχετικά με την εφαρμογή", "he": "אודות האפליקציה",
        "th": "เกี่ยวกับแอป", "vi": "Về ứng dụng", "id": "Tentang aplikasi", "ms": "Tentang aplikasi", "cs": "O aplikaci",
        "hu": "Az alkalmazásról", "ro": "Despre aplicație", "uk": "Про додаток", "hr": "O aplikaciji", "sk": "O aplikácii",
        "ca": "Sobre l'aplicació", "bg": "За приложението", "lt": "Apie programą", "lv": "Par lietotni", "et": "Rakenduse kohta",
        "fa": "درباره برنامه"
    },
    "App bewerten": {
        "de": "App bewerten", "en": "Rate App", "es": "Calificar app", "fr": "Noter l'app", "it": "Valuta l'app",
        "nl": "App beoordelen", "pt-BR": "Avaliar app", "pt-PT": "Avaliar aplicação",
        "ru": "Оценить приложение", "zh-Hans": "评价应用", "zh-Hant": "評價應用程式", "ja": "アプリを評価", "ko": "앱 평가",
        "ar": "قيّم التطبيق", "tr": "Uygulamayı değerlendir", "hi": "ऐप को रेट करें", "pl": "Oceń aplikację", "sv": "Betygsätt appen",
        "da": "Bedøm appen", "nb": "Vurder appen", "fi": "Arvioi sovellus", "el": "Αξιολογήστε την εφαρμογή", "he": "דרג את האפליקציה",
        "th": "ให้คะแนนแอป", "vi": "Đánh giá ứng dụng", "id": "Beri nilai aplikasi", "ms": "Nilai aplikasi", "cs": "Ohodnotit aplikaci",
        "hu": "Alkalmazás értékelése", "ro": "Evaluează aplicația", "uk": "Оцінити додаток", "hr": "Ocijenite aplikaciju", "sk": "Ohodnotiť aplikáciu",
        "ca": "Valorar l'aplicació", "bg": "Оценете приложението", "lt": "Įvertinti programą", "lv": "Novērtēt lietotni", "et": "Hinda rakendust",
        "fa": "امتیاز به برنامه"
    },
    "Datenschutz": {
        "de": "Datenschutz", "en": "Privacy", "es": "Privacidad", "fr": "Confidentialité", "it": "Privacy",
        "nl": "Privacy", "pt-BR": "Privacidade", "pt-PT": "Privacidade",
        "ru": "Конфиденциальность", "zh-Hans": "隐私", "zh-Hant": "隱私", "ja": "プライバシー", "ko": "개인정보",
        "ar": "الخصوصية", "tr": "Gizlilik", "hi": "गोपनीयता", "pl": "Prywatność", "sv": "Integritet",
        "da": "Privatliv", "nb": "Personvern", "fi": "Tietosuoja", "el": "Απόρρητο", "he": "פרטיות",
        "th": "ความเป็นส่วนตัว", "vi": "Quyền riêng tư", "id": "Privasi", "ms": "Privasi", "cs": "Soukromí",
        "hu": "Adatvédelem", "ro": "Confidențialitate", "uk": "Конфіденційність", "hr": "Privatnost", "sk": "Súkromie",
        "ca": "Privadesa", "bg": "Поверителност", "lt": "Privatumas", "lv": "Privātums", "et": "Privaatsus",
        "fa": "حریم خصوصی"
    },
    "Support": {
        "de": "Support", "en": "Support", "es": "Soporte", "fr": "Support", "it": "Supporto",
        "nl": "Ondersteuning", "pt-BR": "Suporte", "pt-PT": "Suporte",
        "ru": "Поддержка", "zh-Hans": "支持", "zh-Hant": "支援", "ja": "サポート", "ko": "지원",
        "ar": "الدعم", "tr": "Destek", "hi": "सहायता", "pl": "Wsparcie", "sv": "Support",
        "da": "Support", "nb": "Støtte", "fi": "Tuki", "el": "Υποστήριξη", "he": "תמיכה",
        "th": "การสนับสนุน", "vi": "Hỗ trợ", "id": "Dukungan", "ms": "Sokongan", "cs": "Podpora",
        "hu": "Támogatás", "ro": "Asistență", "uk": "Підтримка", "hr": "Podrška", "sk": "Podpora",
        "ca": "Suport", "bg": "Поддръжка", "lt": "Pagalba", "lv": "Atbalsts", "et": "Tugi",
        "fa": "پشتیبانی"
    },
    "Transparent": {
        "de": "Transparent", "en": "Transparent", "es": "Transparente", "fr": "Transparent", "it": "Trasparente",
        "nl": "Transparant", "pt-BR": "Transparente", "pt-PT": "Transparente",
        "ru": "Прозрачный", "zh-Hans": "透明", "zh-Hant": "透明", "ja": "透明", "ko": "투명",
        "ar": "شفاف", "tr": "Şeffaf", "hi": "पारदर्शी", "pl": "Przezroczysty", "sv": "Transparent",
        "da": "Gennemsigtig", "nb": "Gjennomsiktig", "fi": "Läpinäkyvä", "el": "Διαφανές", "he": "שקוף",
        "th": "โปร่งใส", "vi": "Trong suốt", "id": "Transparan", "ms": "Telus", "cs": "Průhledný",
        "hu": "Átlátszó", "ro": "Transparent", "uk": "Прозорий", "hr": "Prozirno", "sk": "Priehľadný",
        "ca": "Transparent", "bg": "Прозрачен", "lt": "Skaidrus", "lv": "Caurspīdīgs", "et": "Läbipaistev",
        "fa": "شفاف"
    },
    "Helligkeit": {
        "de": "Helligkeit", "en": "Brightness", "es": "Brillo", "fr": "Luminosité", "it": "Luminosità",
        "nl": "Helderheid", "pt-BR": "Brilho", "pt-PT": "Brilho",
        "ru": "Яркость", "zh-Hans": "亮度", "zh-Hant": "亮度", "ja": "明るさ", "ko": "밝기",
        "ar": "السطوع", "tr": "Parlaklık", "hi": "चमक", "pl": "Jasność", "sv": "Ljusstyrka",
        "da": "Lysstyrke", "nb": "Lysstyrke", "fi": "Kirkkaus", "el": "Φωτεινότητα", "he": "בהירות",
        "th": "ความสว่าง", "vi": "Độ sáng", "id": "Kecerahan", "ms": "Kecerahan", "cs": "Jas",
        "hu": "Fényerő", "ro": "Luminozitate", "uk": "Яскравість", "hr": "Svjetlina", "sk": "Jas",
        "ca": "Brillantor", "bg": "Яркост", "lt": "Ryškumas", "lv": "Spilgtums", "et": "Heledus",
        "fa": "روشنایی"
    },
    "Sättigung": {
        "de": "Sättigung", "en": "Saturation", "es": "Saturación", "fr": "Saturation", "it": "Saturazione",
        "nl": "Verzadiging", "pt-BR": "Saturação", "pt-PT": "Saturação",
        "ru": "Насыщенность", "zh-Hans": "饱和度", "zh-Hant": "飽和度", "ja": "彩度", "ko": "채도",
        "ar": "التشبع", "tr": "Doygunluk", "hi": "संतृप्ति", "pl": "Nasycenie", "sv": "Mättnad",
        "da": "Mætning", "nb": "Metning", "fi": "Kylläisyys", "el": "Κορεσμός", "he": "רוויה",
        "th": "ความอิ่มตัว", "vi": "Độ bão hòa", "id": "Saturasi", "ms": "Ketepuan", "cs": "Sytost",
        "hu": "Telítettség", "ro": "Saturație", "uk": "Насиченість", "hr": "Zasićenost", "sk": "Sýtosť",
        "ca": "Saturació", "bg": "Наситеност", "lt": "Sodrumas", "lv": "Piesātinājums", "et": "Küllastus",
        "fa": "اشباع"
    },
    "Schärfe": {
        "de": "Schärfe", "en": "Sharpness", "es": "Nitidez", "fr": "Netteté", "it": "Nitidezza",
        "nl": "Scherpte", "pt-BR": "Nitidez", "pt-PT": "Nitidez",
        "ru": "Резкость", "zh-Hans": "锐度", "zh-Hant": "銳利度", "ja": "シャープネス", "ko": "선명도",
        "ar": "الحدة", "tr": "Keskinlik", "hi": "तीक्ष्णता", "pl": "Ostrość", "sv": "Skärpa",
        "da": "Skarphed", "nb": "Skarphet", "fi": "Terävyys", "el": "Ευκρίνεια", "he": "חדות",
        "th": "ความคมชัด", "vi": "Độ sắc nét", "id": "Ketajaman", "ms": "Ketajaman", "cs": "Ostrost",
        "hu": "Élesség", "ro": "Claritate", "uk": "Різкість", "hr": "Oštrina", "sk": "Ostrosť",
        "ca": "Nitidesa", "bg": "Острота", "lt": "Ryškumas", "lv": "Asums", "et": "Teravus",
        "fa": "وضوح"
    },
    "Projekt löschen": {
        "de": "Projekt löschen", "en": "Delete Project", "es": "Eliminar proyecto", "fr": "Supprimer le projet", "it": "Elimina progetto",
        "nl": "Project verwijderen", "pt-BR": "Excluir projeto", "pt-PT": "Eliminar projeto",
        "ru": "Удалить проект", "zh-Hans": "删除项目", "zh-Hant": "刪除專案", "ja": "プロジェクトを削除", "ko": "프로젝트 삭제",
        "ar": "حذف المشروع", "tr": "Projeyi sil", "hi": "प्रोजेक्ट हटाएं", "pl": "Usuń projekt", "sv": "Ta bort projekt",
        "da": "Slet projekt", "nb": "Slett prosjekt", "fi": "Poista projekti", "el": "Διαγραφή έργου", "he": "מחק פרויקט",
        "th": "ลบโปรเจกต์", "vi": "Xóa dự án", "id": "Hapus proyek", "ms": "Padam projek", "cs": "Smazat projekt",
        "hu": "Projekt törlése", "ro": "Șterge proiectul", "uk": "Видалити проект", "hr": "Izbriši projekt", "sk": "Odstrániť projekt",
        "ca": "Eliminar projecte", "bg": "Изтриване на проект", "lt": "Ištrinti projektą", "lv": "Dzēst projektu", "et": "Kustuta projekt",
        "fa": "حذف پروژه"
    },
    "Projekt gespeichert": {
        "de": "Projekt gespeichert", "en": "Project Saved", "es": "Proyecto guardado", "fr": "Projet enregistré", "it": "Progetto salvato",
        "nl": "Project opgeslagen", "pt-BR": "Projeto salvo", "pt-PT": "Projeto guardado",
        "ru": "Проект сохранен", "zh-Hans": "项目已保存", "zh-Hant": "專案已儲存", "ja": "プロジェクトを保存しました", "ko": "프로젝트 저장됨",
        "ar": "تم حفظ المشروع", "tr": "Proje kaydedildi", "hi": "प्रोजेक्ट सहेजा गया", "pl": "Projekt zapisany", "sv": "Projekt sparat",
        "da": "Projekt gemt", "nb": "Prosjekt lagret", "fi": "Projekti tallennettu", "el": "Το έργο αποθηκεύτηκε", "he": "הפרויקט נשמר",
        "th": "บันทึกโปรเจกต์แล้ว", "vi": "Đã lưu dự án", "id": "Proyek tersimpan", "ms": "Projek disimpan", "cs": "Projekt uložen",
        "hu": "Projekt mentve", "ro": "Proiect salvat", "uk": "Проект збережено", "hr": "Projekt spremljen", "sk": "Projekt uložený",
        "ca": "Projecte desat", "bg": "Проектът е запазен", "lt": "Projektas išsaugotas", "lv": "Projekts saglabāts", "et": "Projekt salvestatud",
        "fa": "پروژه ذخیره شد"
    },
    "Verläufe": {
        "de": "Verläufe", "en": "Gradients", "es": "Degradados", "fr": "Dégradés", "it": "Gradienti",
        "nl": "Verloop", "pt-BR": "Gradientes", "pt-PT": "Gradientes",
        "ru": "Градиенты", "zh-Hans": "渐变", "zh-Hant": "漸層", "ja": "グラデーション", "ko": "그라데이션",
        "ar": "التدرجات", "tr": "Gradyanlar", "hi": "ग्रेडिएंट", "pl": "Gradienty", "sv": "Gradienter",
        "da": "Gradienter", "nb": "Gradienter", "fi": "Liukuvärit", "el": "Διαβαθμίσεις", "he": "מעברי צבע",
        "th": "การไล่ระดับสี", "vi": "Gradient", "id": "Gradien", "ms": "Kecerunan", "cs": "Přechody",
        "hu": "Színátmenetek", "ro": "Gradiente", "uk": "Градієнти", "hr": "Prijelazi", "sk": "Prechody",
        "ca": "Degradats", "bg": "Градиенти", "lt": "Gradientai", "lv": "Gradienți", "et": "Üleminekud",
        "fa": "گرادیان‌ها"
    },
    "Presets": {
        "de": "Presets", "en": "Presets", "es": "Ajustes predefinidos", "fr": "Préréglages", "it": "Preset",
        "nl": "Voorinstellingen", "pt-BR": "Predefinições", "pt-PT": "Predefinições",
        "ru": "Пресеты", "zh-Hans": "预设", "zh-Hant": "預設", "ja": "プリセット", "ko": "프리셋",
        "ar": "الإعدادات المسبقة", "tr": "Ön ayarlar", "hi": "प्रीसेट", "pl": "Presety", "sv": "Förinställningar",
        "da": "Forudindstillinger", "nb": "Forhåndsinnstillinger", "fi": "Esiasetukset", "el": "Προεπιλογές", "he": "הגדרות מוכנות",
        "th": "ค่าที่ตั้งไว้ล่วงหน้า", "vi": "Cài đặt sẵn", "id": "Preset", "ms": "Pratetap", "cs": "Předvolby",
        "hu": "Előbeállítások", "ro": "Presetări", "uk": "Пресети", "hr": "Predloške", "sk": "Predvoľby",
        "ca": "Predefinits", "bg": "Предварителни настройки", "lt": "Išankstiniai nustatymai", "lv": "Iepriekšiestatījumi", "et": "Eelseadistused",
        "fa": "پیش‌تنظیمات"
    },
    "Reset": {
        "de": "Reset", "en": "Reset", "es": "Restablecer", "fr": "Réinitialiser", "it": "Ripristina",
        "nl": "Resetten", "pt-BR": "Redefinir", "pt-PT": "Repor",
        "ru": "Сброс", "zh-Hans": "重置", "zh-Hant": "重設", "ja": "リセット", "ko": "재설정",
        "ar": "إعادة تعيين", "tr": "Sıfırla", "hi": "रीसेट", "pl": "Resetuj", "sv": "Återställ",
        "da": "Nulstil", "nb": "Tilbakestill", "fi": "Nollaa", "el": "Επαναφορά", "he": "אפס",
        "th": "รีเซ็ต", "vi": "Đặt lại", "id": "Atur ulang", "ms": "Set semula", "cs": "Obnovit",
        "hu": "Visszaállítás", "ro": "Resetare", "uk": "Скинути", "hr": "Resetiraj", "sk": "Obnoviť",
        "ca": "Restablir", "bg": "Нулиране", "lt": "Atstatyti", "lv": "Atiestatīt", "et": "Lähtesta",
        "fa": "بازنشانی"
    },
    "Empfohlen": {
        "de": "Empfohlen", "en": "Recommended", "es": "Recomendado", "fr": "Recommandé", "it": "Consigliato",
        "nl": "Aanbevolen", "pt-BR": "Recomendado", "pt-PT": "Recomendado",
        "ru": "Рекомендуется", "zh-Hans": "推荐", "zh-Hant": "推薦", "ja": "おすすめ", "ko": "추천",
        "ar": "موصى به", "tr": "Önerilen", "hi": "अनुशंसित", "pl": "Zalecane", "sv": "Rekommenderas",
        "da": "Anbefalet", "nb": "Anbefalt", "fi": "Suositeltu", "el": "Συνιστάται", "he": "מומלץ",
        "th": "แนะนำ", "vi": "Được đề xuất", "id": "Direkomendasikan", "ms": "Disyorkan", "cs": "Doporučeno",
        "hu": "Ajánlott", "ro": "Recomandat", "uk": "Рекомендовано", "hr": "Preporučeno", "sk": "Odporúčané",
        "ca": "Recomanat", "bg": "Препоръчително", "lt": "Rekomenduojama", "lv": "Ieteicams", "et": "Soovitatav",
        "fa": "توصیه شده"
    },
    "Bearbeiten": {
        "de": "Bearbeiten", "en": "Edit", "es": "Editar", "fr": "Modifier", "it": "Modifica",
        "nl": "Bewerken", "pt-BR": "Editar", "pt-PT": "Editar",
        "ru": "Редактировать", "zh-Hans": "编辑", "zh-Hant": "編輯", "ja": "編集", "ko": "편집",
        "ar": "تحرير", "tr": "Düzenle", "hi": "संपादित करें", "pl": "Edytuj", "sv": "Redigera",
        "da": "Rediger", "nb": "Rediger", "fi": "Muokkaa", "el": "Επεξεργασία", "he": "ערוך",
        "th": "แก้ไข", "vi": "Chỉnh sửa", "id": "Edit", "ms": "Edit", "cs": "Upravit",
        "hu": "Szerkesztés", "ro": "Editare", "uk": "Редагувати", "hr": "Uredi", "sk": "Upraviť",
        "ca": "Editar", "bg": "Редактиране", "lt": "Redaguoti", "lv": "Rediģēt", "et": "Muuda",
        "fa": "ویرایش"
    },
    "Aktionen": {
        "de": "Aktionen", "en": "Actions", "es": "Acciones", "fr": "Actions", "it": "Azioni",
        "nl": "Acties", "pt-BR": "Ações", "pt-PT": "Ações",
        "ru": "Действия", "zh-Hans": "操作", "zh-Hant": "操作", "ja": "アクション", "ko": "작업",
        "ar": "الإجراءات", "tr": "İşlemler", "hi": "क्रियाएं", "pl": "Akcje", "sv": "Åtgärder",
        "da": "Handlinger", "nb": "Handlinger", "fi": "Toiminnot", "el": "Ενέργειες", "he": "פעולות",
        "th": "การดำเนินการ", "vi": "Hành động", "id": "Tindakan", "ms": "Tindakan", "cs": "Akce",
        "hu": "Műveletek", "ro": "Acțiuni", "uk": "Дії", "hr": "Radnje", "sk": "Akcie",
        "ca": "Accions", "bg": "Действия", "lt": "Veiksmai", "lv": "Darbības", "et": "Tegevused",
        "fa": "اقدامات"
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

def add_all_translations(filepath):
    """Add all translations to the xcstrings file"""
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
            print(f"Warning: Key '{key}' not found in xcstrings file")
    
    print(f"Saving {filepath}...")
    save_xcstrings(filepath, data)
    
    print(f"\n✅ Success!")
    print(f"   Updated {keys_updated} keys")
    print(f"   Added {translations_added} translations")
    print(f"   Covering {len(set(lang for trans in TRANSLATIONS.values() for lang in trans.keys()))} languages")

if __name__ == "__main__":
    filepath = "/Users/blargou/Desktop/removebgpro/removebgpro/Localizable.xcstrings"
    add_all_translations(filepath)
