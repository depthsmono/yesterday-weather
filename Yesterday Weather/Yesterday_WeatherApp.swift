//
//  Yesterday_WeatherApp.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import SwiftUI
import UIKit

@main
struct Yesterday_WeatherApp: App {

    init() {
        // Debug: Log all available fonts on app startup
        print("=== AVAILABLE FONTS ON APP STARTUP ===")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            for name in names {
                print("Font: \(family) -> \(name)")
            }
        }
        print("=== END FONT LIST ===")

        // Test specific font loading
        testWeatherIconFont()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func testWeatherIconFont() {
        print("=== COMPREHENSIVE FONT DIAGNOSTICS ===")

        // 1. Check if font file exists in app bundle
        print("1. CHECKING APP BUNDLE FOR FONT FILES:")
        if let bundlePath = Bundle.main.path(forResource: "weathericons-regular-webfont", ofType: "ttf") {
            print("✅ Found font in bundle: \(bundlePath)")
        } else {
            print("❌ Font NOT found in app bundle - this is likely the issue!")
        }

        // 2. Check other possible font file names
        let possibleFiles = ["weathericons-regular-webfont", "WeatherIcons-Regular", "weather-icons"]
        for fileName in possibleFiles {
            if let path = Bundle.main.path(forResource: fileName, ofType: "ttf") {
                print("✅ Found alternative font: \(fileName).ttf at \(path)")
            }
        }

        // 3. Test font loading by name
        print("\n2. TESTING FONT LOADING BY NAME:")
        let testNames = [
            "Weather Icons",
            "WeatherIcons",
            "WeatherIcons-Regular",
            "weathericons-regular-webfont",
            "Weather Icons Regular"
        ]

        for name in testNames {
            if let font = UIFont(name: name, size: 16) {
                print("✅ Successfully loaded font: '\(name)' -> Family: \(font.familyName), Font Name: \(font.fontName)")
            } else {
                print("❌ Failed to load font: '\(name)'")
            }
        }

        // 4. Check bundle info for registered fonts
        print("\n3. CHECKING INFO.PLIST FOR FONT REGISTRATION:")
        if let fonts = Bundle.main.object(forInfoDictionaryKey: "UIAppFonts") as? [String] {
            print("✅ Registered fonts in Info.plist: \(fonts)")
        } else {
            print("❌ No UIAppFonts found in Info.plist - font registration missing!")
        }

        print("=== END DIAGNOSTICS ===\n")
    }
}
