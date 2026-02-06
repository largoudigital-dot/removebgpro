//
//  removebgproApp.swift
//  removebgpro
//
//  Created by Largou on 03.02.26.
//

import SwiftUI

@main
struct removebgproApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, languageManager.locale)
                .id(languageManager.selectedLanguage)
        }
    }
}
