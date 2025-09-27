//
//  WeatherIconView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/25/25.
//

import SwiftUI

// MARK: - Weather Icon View Component

struct WeatherIconView: View {
    let weatherCode: Int
    let isDay: Bool
    let size: CGFloat

    init(weatherCode: Int, isDay: Bool = true, size: CGFloat = 30) {
        self.weatherCode = weatherCode
        self.isDay = isDay
        self.size = size
    }

    var body: some View {
        if let font = loadWeatherIconsFont() {
            // Use Weather Icons font with warm colors
            Text(getWeatherIconUnicode())
                .font(Font(font))
                .foregroundColor(colorForWeatherCode(weatherCode, isDay: isDay))
        } else {
            // Fallback to SF Symbols with warm colors
            Image(systemName: WeatherIconMapper.getSFSymbolFallback(for: weatherCode))
                .font(.system(size: size))
                .foregroundColor(colorForWeatherCode(weatherCode, isDay: isDay))
        }
    }

    // MARK: - Font Loading

    private func loadWeatherIconsFont() -> UIFont? {
        let possibleFontNames = [
            "Weather Icons",
            "WeatherIcons-Regular",
            "weathericons-regular-webfont",
            "WeatherIcons"
        ]

        for fontName in possibleFontNames {
            if let font = UIFont(name: fontName, size: size) {
                print("WeatherIconView: Successfully loaded font '\(fontName)'")
                return font
            }
        }

        // Debug: Print that font wasn't found
        print("WeatherIconView: Weather Icons font not found, using SF Symbols fallback")

        return nil
    }

    // MARK: - Weather Icon Colors

    private func colorForWeatherCode(_ code: Int, isDay: Bool) -> Color {
        switch code {
        case 0: // Clear sky
            return isDay ? .weatherSun : .weatherNight
        case 1, 2: // Partly cloudy
            return isDay ? .weatherSun : .weatherNight
        case 3: // Overcast
            return .weatherCloud
        case 45, 48: // Fog
            return .weatherCloud
        case 51, 53, 55, 56, 57: // Drizzle
            return .weatherRain
        case 61, 63, 65, 66, 67: // Rain
            return .weatherRain
        case 71, 73, 75, 77: // Snow
            return .weatherCloud
        case 80, 81, 82: // Rain showers
            return .weatherRain
        case 85, 86: // Snow showers
            return .weatherCloud
        case 95, 96, 99: // Thunderstorm
            return .warmEmphasis
        default:
            return .weatherNeutral
        }
    }

    // MARK: - Debug Helper

    static func logAvailableFonts() {
        print("=== Available iOS Fonts ===")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            if !names.isEmpty {
                print("  \(family): \(names)")
            }
        }
    }

    // MARK: - Weather Icons Unicode Mapping

    private func getWeatherIconUnicode() -> String {
        let iconName = WeatherIconMapper.getWeatherIcon(for: weatherCode, isDay: isDay)
        return weatherIconUnicodeMap[iconName] ?? "\u{f07b}" // Default to "wi-na"
    }

    // MARK: - Weather Icons Unicode Map
    // Based on Erik Flowers Weather Icons font

    private let weatherIconUnicodeMap: [String: String] = [
        // Day Icons
        "wi-day-sunny": "\u{f00d}",
        "wi-day-cloudy": "\u{f002}",
        "wi-day-cloudy-gusts": "\u{f000}",
        "wi-day-cloudy-windy": "\u{f001}",
        "wi-day-fog": "\u{f003}",
        "wi-day-hail": "\u{f004}",
        "wi-day-haze": "\u{f0b6}",
        "wi-day-lightning": "\u{f005}",
        "wi-day-rain": "\u{f008}",
        "wi-day-rain-mix": "\u{f006}",
        "wi-day-rain-wind": "\u{f007}",
        "wi-day-showers": "\u{f009}",
        "wi-day-sleet": "\u{f0b2}",
        "wi-day-sleet-storm": "\u{f068}",
        "wi-day-snow": "\u{f00a}",
        "wi-day-snow-thunderstorm": "\u{f06b}",
        "wi-day-snow-wind": "\u{f065}",
        "wi-day-sprinkle": "\u{f00b}",
        "wi-day-storm-showers": "\u{f00e}",
        "wi-day-sunny-overcast": "\u{f00c}",
        "wi-day-thunderstorm": "\u{f010}",
        "wi-day-windy": "\u{f085}",

        // Night Icons
        "wi-night-clear": "\u{f02e}",
        "wi-night-alt-cloudy": "\u{f086}",
        "wi-night-alt-cloudy-gusts": "\u{f022}",
        "wi-night-alt-cloudy-windy": "\u{f023}",
        "wi-night-alt-hail": "\u{f024}",
        "wi-night-alt-lightning": "\u{f025}",
        "wi-night-alt-partly-cloudy": "\u{f081}",
        "wi-night-alt-rain": "\u{f028}",
        "wi-night-alt-rain-mix": "\u{f026}",
        "wi-night-alt-rain-wind": "\u{f027}",
        "wi-night-alt-showers": "\u{f029}",
        "wi-night-alt-sleet": "\u{f0b4}",
        "wi-night-alt-sleet-storm": "\u{f06a}",
        "wi-night-alt-snow": "\u{f02a}",
        "wi-night-alt-snow-thunderstorm": "\u{f06d}",
        "wi-night-alt-snow-wind": "\u{f067}",
        "wi-night-alt-sprinkle": "\u{f02b}",
        "wi-night-alt-storm-showers": "\u{f02c}",
        "wi-night-alt-thunderstorm": "\u{f02d}",
        "wi-night-fog": "\u{f04a}",

        // Neutral Icons
        "wi-cloud": "\u{f041}",
        "wi-cloudy": "\u{f013}",
        "wi-cloudy-gusts": "\u{f011}",
        "wi-cloudy-windy": "\u{f012}",
        "wi-fog": "\u{f014}",
        "wi-hail": "\u{f015}",
        "wi-rain": "\u{f019}",
        "wi-rain-mix": "\u{f017}",
        "wi-rain-wind": "\u{f018}",
        "wi-showers": "\u{f01a}",
        "wi-sleet": "\u{f0b5}",
        "wi-snow": "\u{f01b}",
        "wi-snow-wind": "\u{f064}",
        "wi-sprinkle": "\u{f01c}",
        "wi-storm-showers": "\u{f01d}",
        "wi-thunderstorm": "\u{f01e}",
        "wi-windy": "\u{f021}",
        "wi-hot": "\u{f072}",
        "wi-tornado": "\u{f056}",

        // Default/Unknown
        "wi-na": "\u{f07b}"
    ]
}

// MARK: - Preview Extension

extension WeatherIconView {
    static func preview(weatherCode: Int, isDay: Bool = true) -> some View {
        VStack {
            WeatherIconView(weatherCode: weatherCode, isDay: isDay, size: 50)
            Text(WeatherIconMapper.getIconDescription(for: weatherCode, isDay: isDay))
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            WeatherIconView.preview(weatherCode: 0, isDay: true)
            WeatherIconView.preview(weatherCode: 0, isDay: false)
        }
        HStack(spacing: 20) {
            WeatherIconView.preview(weatherCode: 63, isDay: true)
            WeatherIconView.preview(weatherCode: 63, isDay: false)
        }
        HStack(spacing: 20) {
            WeatherIconView.preview(weatherCode: 95, isDay: true)
            WeatherIconView.preview(weatherCode: 95, isDay: false)
        }
    }
    .padding()
}