//
//  ColorPalette.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/26/25.
//

import SwiftUI

// MARK: - Warm, Cohesive Color Palette

extension Color {

    // MARK: - Primary Warm Colors

    /// Warm golden amber - main accent color
    static let warmAccent = Color(red: 0.93, green: 0.65, blue: 0.29) // #EDA64A

    /// Rich warm orange - secondary accent
    static let warmSecondary = Color(red: 0.89, green: 0.47, blue: 0.20) // #E37933

    /// Deep sunset orange - for emphasis
    static let warmEmphasis = Color(red: 0.85, green: 0.33, blue: 0.16) // #D85428

    // MARK: - Supporting Warm Colors

    /// Soft warm cream - light backgrounds
    static let warmBackground = Color(red: 0.98, green: 0.96, blue: 0.92) // #FAF5EB

    /// Warm beige - subtle backgrounds
    static let warmSubtle = Color(red: 0.95, green: 0.91, blue: 0.84) // #F2E8D6

    /// Warm brown - for text and details
    static let warmBrown = Color(red: 0.42, green: 0.32, blue: 0.24) // #6B523D

    // MARK: - Weather Icon Colors

    /// Sunny day icon color
    static let weatherSun = Color(red: 0.95, green: 0.76, blue: 0.26) // #F2C242

    /// Cloud icon color
    static let weatherCloud = Color(red: 0.68, green: 0.73, blue: 0.78) // #AEBAC7

    /// Rain/precipitation color
    static let weatherRain = Color(red: 0.41, green: 0.68, blue: 0.84) // #69ADD6

    /// Night/moon icon color
    static let weatherNight = Color(red: 0.52, green: 0.58, blue: 0.70) // #8594B3

    /// Wind/general weather elements
    static let weatherNeutral = Color(red: 0.60, green: 0.60, blue: 0.60) // #999999

    // MARK: - Semantic Colors

    /// Success/positive states
    static let warmSuccess = Color(red: 0.52, green: 0.73, blue: 0.40) // #85BA66

    /// Warning/attention states
    static let warmWarning = Color(red: 0.89, green: 0.67, blue: 0.31) // #E3AB4F

    /// Error/negative states
    static let warmError = Color(red: 0.83, green: 0.36, blue: 0.32) // #D45C52

    // MARK: - Text Colors

    /// Primary text - warm dark brown
    static let warmTextPrimary = Color(red: 0.25, green: 0.20, blue: 0.15) // #403326

    /// Secondary text - medium warm brown
    static let warmTextSecondary = Color(red: 0.55, green: 0.47, blue: 0.38) // #8C7861

    /// Tertiary text - light warm brown
    static let warmTextTertiary = Color(red: 0.70, green: 0.64, blue: 0.57) // #B3A391
}

// MARK: - Gradient Helpers

extension LinearGradient {

    /// Main app background gradient
    static let warmAppBackground = LinearGradient(
        gradient: Gradient(colors: [Color.warmBackground, Color.white]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Header section gradient
    static let warmHeader = LinearGradient(
        gradient: Gradient(colors: [
            Color.warmAccent.opacity(0.15),
            Color.warmSecondary.opacity(0.08)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Card background gradient
    static let warmCard = LinearGradient(
        gradient: Gradient(colors: [
            Color.warmSubtle.opacity(0.6),
            Color.warmBackground.opacity(0.3)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Quote section gradient
    static let warmQuote = LinearGradient(
        gradient: Gradient(colors: [
            Color.warmAccent.opacity(0.10),
            Color.warmSecondary.opacity(0.05)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Forecast section gradient
    static let warmForecast = LinearGradient(
        gradient: Gradient(colors: [
            Color.warmSecondary.opacity(0.12),
            Color.warmAccent.opacity(0.08)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}