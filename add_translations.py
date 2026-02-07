#!/usr/bin/env python3
"""
Script to add translations for all 40 languages to Localizable.xcstrings
"""

import json

# All translation keys that need to be translated
KEYS_TO_TRANSLATE = [
    "📸 Foto aufnehmen",
    "🗂️ Aus Galerie wählen",
    "Abbrechen",
    "Aktionen",
    "Alle Projekte löschen",
    "Als JPG speichern",
    "Als PNG speichern",
    "Anpassen",
    "ANZEIGE",
    "App",
    "App bewerten",
    "App teilen",
    "Bald verfügbar",
    "Bearbeiten",
    "Datenschutz",
    "Deine Reise beginnt hier",
    "Editor verlassen?",
    "Einstellungen",
    "Empfohlen",
    "Erstelle brillante Ausschnitte & Sticker",
    "Farben",
    "Filter",
    "Foto auswählen",
    "Foto Editor",
    "Foto hinzufügen",
    "Helligkeit",
    "Hintergrund",
    "Hintergrund wird entfernt...",
    "Kein Bild zum Speichern",
    "Kontakt",
    "Letzte Projekte",
    "Möchten Sie die Bearbeitung beenden? Ihre Änderungen werden beim Schließen gespeichert.",
    "NEUES PROJEKT",
    "Presets",
    "Projekt gespeichert",
    "Projekt löschen",
    "Reset",
    "Sättigung",
    "Schatten",
    "Schärfe",
    "Speichern",
    "Speichern & Schließen",
    "Speichere...",
    "Speicherfehler: Disk",
    "Sprache",
    "Sprache wählen",
    "Support",
    "Transparent",
    "Transparenter Hintergrund",
    "Über die App",
    "Verläufe",
    "Werbung platzieren",
    "WILLKOMMEN",
    "Zuschneiden",
    "Änderungen gespeichert"
]

# Translations for all languages
TRANSLATIONS = {
    # Russian
    "ru": {
        "📸 Foto aufnehmen": "📸 Сделать фото",
        "🗂️ Aus Galerie wählen": "🗂️ Выбрать из галереи",
        "Abbrechen": "Отмена",
        "Aktionen": "Действия",
        "Alle Projekte löschen": "Удалить все проекты",
        "Als JPG speichern": "Сохранить как JPG",
        "Als PNG speichern": "Сохранить как PNG",
        "Anpassen": "Настроить",
        "ANZEIGE": "РЕКЛАМА",
        "App": "Приложение",
        "App bewerten": "Оценить приложение",
        "App teilen": "Поделиться приложением",
        "Bald verfügbar": "Скоро доступно",
        "Bearbeiten": "Редактировать",
        "Datenschutz": "Конфиденциальность",
        "Deine Reise beginnt hier": "Ваше путешествие начинается здесь",
        "Editor verlassen?": "Выйти из редактора?",
        "Einstellungen": "Настройки",
        "Empfohlen": "Рекомендуется",
        "Erstelle brillante Ausschnitte & Sticker": "Создавайте великолепные вырезки и стикеры",
        "Farben": "Цвета",
        "Filter": "Фильтры",
        "Foto auswählen": "Выбрать фото",
        "Foto Editor": "Фоторедактор",
        "Foto hinzufügen": "Добавить фото",
        "Helligkeit": "Яркость",
        "Hintergrund": "Фон",
        "Hintergrund wird entfernt...": "Удаление фона...",
        "Kein Bild zum Speichern": "Нет изображения для сохранения",
        "Kontakt": "Контакт",
        "Letzte Projekte": "Последние проекты",
        "Möchten Sie die Bearbeitung beenden? Ihre Änderungen werden beim Schließen gespeichert.": "Хотите завершить редактирование? Ваши изменения будут сохранены при закрытии.",
        "NEUES PROJEKT": "НОВЫЙ ПРОЕКТ",
        "Presets": "Пресеты",
        "Projekt gespeichert": "Проект сохранен",
        "Projekt löschen": "Удалить проект",
        "Reset": "Сброс",
        "Sättigung": "Насыщенность",
        "Schatten": "Тень",
        "Schärfe": "Резкость",
        "Speichern": "Сохранить",
        "Speichern & Schließen": "Сохранить и закрыть",
        "Speichere...": "Сохранение...",
        "Speicherfehler: Disk": "Ошибка сохранения: Диск",
        "Sprache": "Язык",
        "Sprache wählen": "Выбрать язык",
        "Support": "Поддержка",
        "Transparent": "Прозрачный",
        "Transparenter Hintergrund": "Прозрачный фон",
        "Über die App": "О приложении",
        "Verläufe": "Градиенты",
        "Werbung platzieren": "Разместить рекламу",
        "WILLKOMMEN": "ДОБРО ПОЖАЛОВАТЬ",
        "Zuschneiden": "Обрезать",
        "Änderungen gespeichert": "Изменения сохранены"
    },
    # Simplified Chinese
    "zh-Hans": {
        "📸 Foto aufnehmen": "📸 拍照",
        "🗂️ Aus Galerie wählen": "🗂️ 从相册选择",
        "Abbrechen": "取消",
        "Aktionen": "操作",
        "Alle Projekte löschen": "删除所有项目",
        "Als JPG speichern": "保存为JPG",
        "Als PNG speichern": "保存为PNG",
        "Anpassen": "调整",
        "ANZEIGE": "广告",
        "App": "应用",
        "App bewerten": "评价应用",
        "App teilen": "分享应用",
        "Bald verfügbar": "即将推出",
        "Bearbeiten": "编辑",
        "Datenschutz": "隐私",
        "Deine Reise beginnt hier": "您的旅程从这里开始",
        "Editor verlassen?": "退出编辑器？",
        "Einstellungen": "设置",
        "Empfohlen": "推荐",
        "Erstelle brillante Ausschnitte & Sticker": "创建精美的剪切和贴纸",
        "Farben": "颜色",
        "Filter": "滤镜",
        "Foto auswählen": "选择照片",
        "Foto Editor": "照片编辑器",
        "Foto hinzufügen": "添加照片",
        "Helligkeit": "亮度",
        "Hintergrund": "背景",
        "Hintergrund wird entfernt...": "正在移除背景...",
        "Kein Bild zum Speichern": "没有图片可保存",
        "Kontakt": "联系",
        "Letzte Projekte": "最近项目",
        "Möchten Sie die Bearbeitung beenden? Ihre Änderungen werden beim Schließen gespeichert.": "要结束编辑吗？关闭时将保存您的更改。",
        "NEUES PROJEKT": "新项目",
        "Presets": "预设",
        "Projekt gespeichert": "项目已保存",
        "Projekt löschen": "删除项目",
        "Reset": "重置",
        "Sättigung": "饱和度",
        "Schatten": "阴影",
        "Schärfe": "锐度",
        "Speichern": "保存",
        "Speichern & Schließen": "保存并关闭",
        "Speichere...": "正在保存...",
        "Speicherfehler: Disk": "保存错误：磁盘",
        "Sprache": "语言",
        "Sprache wählen": "选择语言",
        "Support": "支持",
        "Transparent": "透明",
        "Transparenter Hintergrund": "透明背景",
        "Über die App": "关于应用",
        "Verläufe": "渐变",
        "Werbung platzieren": "投放广告",
        "WILLKOMMEN": "欢迎",
        "Zuschneiden": "裁剪",
        "Änderungen gespeichert": "更改已保存"
    },
    # Add more languages here...
}

def load_localizable():
    """Load the Localizable.xcstrings file"""
    with open('/Users/blargou/Desktop/removebgpro/removebgpro/Localizable.xcstrings', 'r', encoding='utf-8') as f:
        return json.load(f)

def save_localizable(data):
    """Save the Localizable.xcstrings file"""
    with open('/Users/blargou/Desktop/removebgpro/removebgpro/Localizable.xcstrings', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def add_translations():
    """Add translations for all languages"""
    data = load_localizable()
    
    for key in KEYS_TO_TRANSLATE:
        if key in data['strings']:
            for lang_code, translations in TRANSLATIONS.items():
                if key in translations:
                    if 'localizations' not in data['strings'][key]:
                        data['strings'][key]['localizations'] = {}
                    
                    data['strings'][key]['localizations'][lang_code] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": translations[key]
                        }
                    }
    
    save_localizable(data)
    print(f"Added translations for {len(TRANSLATIONS)} languages")

if __name__ == "__main__":
    add_translations()
