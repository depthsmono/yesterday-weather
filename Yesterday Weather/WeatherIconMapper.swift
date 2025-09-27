//
//  WeatherIconMapper.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/25/25.
//

import Foundation

// MARK: - Enhanced Weather Icon Mapper using Erik Flowers Weather Icons
// Font: https://github.com/erikflowers/weather-icons
// License: SIL OFL 1.1

struct WeatherIconMapper {

    // MARK: - Weather Code to Icon Mapping

    static func getWeatherIcon(for code: Int, isDay: Bool = true) -> String {
        switch code {
        case 0:
            return isDay ? "wi-day-sunny" : "wi-night-clear"
        case 1:
            return isDay ? "wi-day-sunny-overcast" : "wi-night-alt-partly-cloudy"
        case 2:
            return isDay ? "wi-day-cloudy" : "wi-night-alt-cloudy"
        case 3:
            return "wi-cloudy"
        case 45:
            return isDay ? "wi-day-fog" : "wi-night-fog"
        case 48:
            return "wi-fog"
        case 51:
            return isDay ? "wi-day-sprinkle" : "wi-night-alt-sprinkle"
        case 53:
            return isDay ? "wi-day-rain-mix" : "wi-night-alt-rain-mix"
        case 55:
            return isDay ? "wi-day-rain" : "wi-night-alt-rain"
        case 56:
            return isDay ? "wi-day-rain-mix" : "wi-night-alt-rain-mix"
        case 57:
            return isDay ? "wi-day-sleet" : "wi-night-alt-sleet"
        case 61:
            return isDay ? "wi-day-showers" : "wi-night-alt-showers"
        case 63:
            return isDay ? "wi-day-rain" : "wi-night-alt-rain"
        case 65:
            return isDay ? "wi-day-rain-wind" : "wi-night-alt-rain-wind"
        case 66:
            return isDay ? "wi-day-sleet" : "wi-night-alt-sleet"
        case 67:
            return isDay ? "wi-day-sleet-storm" : "wi-night-alt-sleet-storm"
        case 71:
            return isDay ? "wi-day-snow" : "wi-night-alt-snow"
        case 73:
            return isDay ? "wi-day-snow-wind" : "wi-night-alt-snow-wind"
        case 75:
            return "wi-snow-wind"
        case 77:
            return "wi-snow"
        case 80:
            return isDay ? "wi-day-showers" : "wi-night-alt-showers"
        case 81:
            return isDay ? "wi-day-storm-showers" : "wi-night-alt-storm-showers"
        case 82:
            return "wi-storm-showers"
        case 85:
            return isDay ? "wi-day-snow" : "wi-night-alt-snow"
        case 86:
            return "wi-snow-wind"
        case 95:
            return isDay ? "wi-day-thunderstorm" : "wi-night-alt-thunderstorm"
        case 96:
            return isDay ? "wi-day-storm-showers" : "wi-night-alt-storm-showers"
        case 99:
            return "wi-thunderstorm"
        default:
            return "wi-na"
        }
    }

    // MARK: - Icon Description

    static func getIconDescription(for code: Int, isDay: Bool = true) -> String {
        switch code {
        case 0:
            return isDay ? "Clear Sky" : "Clear Night"
        case 1:
            return isDay ? "Mainly Clear" : "Mainly Clear Night"
        case 2:
            return isDay ? "Partly Cloudy" : "Partly Cloudy Night"
        case 3:
            return "Overcast"
        case 45:
            return "Fog"
        case 48:
            return "Depositing Rime Fog"
        case 51:
            return "Light Drizzle"
        case 53:
            return "Moderate Drizzle"
        case 55:
            return "Dense Drizzle"
        case 56:
            return "Light Freezing Drizzle"
        case 57:
            return "Dense Freezing Drizzle"
        case 61:
            return "Slight Rain"
        case 63:
            return "Moderate Rain"
        case 65:
            return "Heavy Rain"
        case 66:
            return "Light Freezing Rain"
        case 67:
            return "Heavy Freezing Rain"
        case 71:
            return "Slight Snow Fall"
        case 73:
            return "Moderate Snow Fall"
        case 75:
            return "Heavy Snow Fall"
        case 77:
            return "Snow Grains"
        case 80:
            return "Slight Rain Showers"
        case 81:
            return "Moderate Rain Showers"
        case 82:
            return "Violent Rain Showers"
        case 85:
            return "Slight Snow Showers"
        case 86:
            return "Heavy Snow Showers"
        case 95:
            return "Thunderstorm"
        case 96:
            return "Thunderstorm with Slight Hail"
        case 99:
            return "Thunderstorm with Heavy Hail"
        default:
            return "Unknown Condition"
        }
    }

    // MARK: - Fallback SF Symbol Mapping (for development/testing)

    static func getSFSymbolFallback(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1: return "sun.max.circle.fill"
        case 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67: return "cloud.rain.fill"
        case 71, 73, 75, 77: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.rain.fill"
        case 85, 86: return "cloud.snow.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle.fill"
        }
    }

    // MARK: - Comprehensive Icon List for Admin View

    static let allWeatherConditions: [(code: Int, dayIcon: String, nightIcon: String?, description: String)] = [
        (0, "wi-day-sunny", "wi-night-clear", "Clear sky"),
        (1, "wi-day-sunny-overcast", "wi-night-alt-partly-cloudy", "Mainly clear"),
        (2, "wi-day-cloudy", "wi-night-alt-cloudy", "Partly cloudy"),
        (3, "wi-cloudy", nil, "Overcast"),
        (45, "wi-day-fog", "wi-night-fog", "Fog"),
        (48, "wi-fog", nil, "Depositing rime fog"),
        (51, "wi-day-sprinkle", "wi-night-alt-sprinkle", "Light drizzle"),
        (53, "wi-day-rain-mix", "wi-night-alt-rain-mix", "Moderate drizzle"),
        (55, "wi-day-rain", "wi-night-alt-rain", "Dense drizzle"),
        (56, "wi-day-rain-mix", "wi-night-alt-rain-mix", "Light freezing drizzle"),
        (57, "wi-day-sleet", "wi-night-alt-sleet", "Dense freezing drizzle"),
        (61, "wi-day-showers", "wi-night-alt-showers", "Slight rain"),
        (63, "wi-day-rain", "wi-night-alt-rain", "Moderate rain"),
        (65, "wi-day-rain-wind", "wi-night-alt-rain-wind", "Heavy rain"),
        (66, "wi-day-sleet", "wi-night-alt-sleet", "Light freezing rain"),
        (67, "wi-day-sleet-storm", "wi-night-alt-sleet-storm", "Heavy freezing rain"),
        (71, "wi-day-snow", "wi-night-alt-snow", "Slight snow fall"),
        (73, "wi-day-snow-wind", "wi-night-alt-snow-wind", "Moderate snow fall"),
        (75, "wi-snow-wind", nil, "Heavy snow fall"),
        (77, "wi-snow", nil, "Snow grains"),
        (80, "wi-day-showers", "wi-night-alt-showers", "Slight rain showers"),
        (81, "wi-day-storm-showers", "wi-night-alt-storm-showers", "Moderate rain showers"),
        (82, "wi-storm-showers", nil, "Violent rain showers"),
        (85, "wi-day-snow", "wi-night-alt-snow", "Slight snow showers"),
        (86, "wi-snow-wind", nil, "Heavy snow showers"),
        (95, "wi-day-thunderstorm", "wi-night-alt-thunderstorm", "Thunderstorm"),
        (96, "wi-day-storm-showers", "wi-night-alt-storm-showers", "Thunderstorm with slight hail"),
        (99, "wi-thunderstorm", nil, "Thunderstorm with heavy hail")
    ]
}