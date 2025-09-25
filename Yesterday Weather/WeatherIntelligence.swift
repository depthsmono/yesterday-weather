//
//  WeatherIntelligence.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Weather Intelligence Engine

struct WeatherIntelligence {

    // MARK: - Analysis Result

    struct WeatherAnalysis {
        let narrative: String
        let advice: [String]
        let emoji: String
        let severity: AnalysisSeverity
    }

    enum AnalysisSeverity {
        case mild, moderate, significant, severe

        var priority: Int {
            switch self {
            case .mild: return 1
            case .moderate: return 2
            case .significant: return 3
            case .severe: return 4
            }
        }
    }

    // MARK: - Weather Factors

    private struct WeatherFactors {
        let temperatureDelta: Double
        let precipitationDelta: Double
        let humidityDelta: Int
        let windSpeedDelta: Double
        let weatherCodeChange: WeatherCodeComparison

        enum WeatherCodeComparison {
        case clearToStorm, stormToClear, similarConditions, minorChange, majorChange
        }
    }

    // MARK: - Main Analysis Function

    static func analyzeWeatherComparison(_ comparison: WeatherComparison, experiences: Set<WeatherExperience>) -> WeatherAnalysis {
        let factors = extractWeatherFactors(from: comparison)

        print("WeatherIntelligence: Temperature Δ: \(factors.temperatureDelta)°F")
        print("WeatherIntelligence: Humidity Δ: \(factors.humidityDelta)%")
        print("WeatherIntelligence: Precipitation Δ: \(factors.precipitationDelta)\"")

        let conditions = categorizeConditions(factors: factors)
        print("WeatherIntelligence: Detected conditions: \(conditions)")

        let contextualAdvice = generateContextualAdvice(factors: factors, experiences: experiences)
        let narrative = generateNarrative(conditions: conditions, factors: factors)
        let emoji = selectEmoji(conditions: conditions, factors: factors)
        let severity = determineSeverity(factors: factors)

        return WeatherAnalysis(
            narrative: narrative,
            advice: contextualAdvice,
            emoji: emoji,
            severity: severity
        )
    }

    // MARK: - Factor Extraction

    private static func extractWeatherFactors(from comparison: WeatherComparison) -> WeatherFactors {
        let tempDelta = comparison.temperatureDifference
        let precipDelta = comparison.precipitationDifference
        let humidityDelta = comparison.humidityDifference
        let windDelta = comparison.today.windSpeed - comparison.yesterday.windSpeed

        let weatherCodeChange = compareWeatherCodes(
            yesterday: comparison.yesterday.weatherCode,
            today: comparison.today.weatherCode
        )

        return WeatherFactors(
            temperatureDelta: tempDelta,
            precipitationDelta: precipDelta,
            humidityDelta: humidityDelta,
            windSpeedDelta: windDelta,
            weatherCodeChange: weatherCodeChange
        )
    }

    private static func compareWeatherCodes(yesterday: Int, today: Int) -> WeatherFactors.WeatherCodeComparison {
        let yesterdayCategory = categorizeWeatherCode(yesterday)
        let todayCategory = categorizeWeatherCode(today)

        switch (yesterdayCategory, todayCategory) {
        case ("clear", "storm"), ("clear", "rain"):
            return .clearToStorm
        case ("storm", "clear"), ("rain", "clear"):
            return .stormToClear
        case (let y, let t) where y == t:
            return .similarConditions
        case (_, _) where abs(yesterday - today) < 10:
            return .minorChange
        default:
            return .majorChange
        }
    }

    private static func categorizeWeatherCode(_ code: Int) -> String {
        switch code {
        case 0...3: return "clear"
        case 45...57: return "fog"
        case 61...67: return "rain"
        case 71...77: return "snow"
        case 80...86: return "rain"
        case 95...99: return "storm"
        default: return "unknown"
        }
    }

    // MARK: - Condition Analysis

    private static func categorizeConditions(factors: WeatherFactors) -> [String] {
        var conditions: [String] = []
        let settings = NarrativeSettings.shared

        // Temperature analysis - using configurable thresholds
        let tempDelta = abs(factors.temperatureDelta)
        if tempDelta >= settings.temperatureMuchThreshold {
            conditions.append(factors.temperatureDelta > 0 ? "much_warmer" : "much_colder")
        } else if tempDelta >= settings.temperatureSignificantThreshold {
            conditions.append(factors.temperatureDelta > 0 ? "warmer" : "cooler")
        } else if tempDelta >= settings.temperatureSlightThreshold {
            conditions.append(factors.temperatureDelta > 0 ? "slightly_warmer" : "slightly_cooler")
        }

        // Humidity analysis - using configurable thresholds
        let humidityDelta = Double(abs(factors.humidityDelta))
        if humidityDelta >= settings.humidityMuchThreshold {
            conditions.append(factors.humidityDelta > 0 ? "much_more_humid" : "much_drier_air")
        } else if humidityDelta >= settings.humiditySignificantThreshold {
            conditions.append(factors.humidityDelta > 0 ? "more_humid" : "drier_air")
        } else if humidityDelta >= settings.humiditySlightThreshold {
            conditions.append(factors.humidityDelta > 0 ? "slightly_more_humid" : "slightly_drier_air")
        }

        // Precipitation analysis - using configurable thresholds
        if factors.precipitationDelta >= settings.precipitationMuchThreshold {
            conditions.append("much_rainier")
        } else if factors.precipitationDelta >= settings.precipitationSignificantThreshold {
            conditions.append("rainier")
        } else if factors.precipitationDelta <= -settings.precipitationSlightThreshold {
            conditions.append("drier")
        }

        // Wind analysis - using configurable thresholds
        if factors.windSpeedDelta >= settings.windMuchThreshold {
            conditions.append("much_windier")
        } else if factors.windSpeedDelta >= settings.windSignificantThreshold {
            conditions.append("windier")
        } else if factors.windSpeedDelta <= -settings.windSlightThreshold {
            conditions.append("calmer")
        }

        // Weather pattern analysis
        switch factors.weatherCodeChange {
        case .clearToStorm:
            conditions.append("weather_deteriorating")
        case .stormToClear:
            conditions.append("weather_improving")
        case .majorChange:
            conditions.append("weather_changing")
        default:
            break
        }

        return conditions
    }

    // MARK: - Narrative Generation

    private static func generateNarrative(conditions: [String], factors: WeatherFactors) -> String {
        var narrativeParts: [String] = []

        // Temperature narrative
        if conditions.contains("much_colder") {
            narrativeParts.append("Much colder")
        } else if conditions.contains("much_warmer") {
            narrativeParts.append("Much warmer")
        } else if conditions.contains("cooler") {
            narrativeParts.append("Cooler")
        } else if conditions.contains("warmer") {
            narrativeParts.append("Warmer")
        } else if conditions.contains("slightly_cooler") {
            narrativeParts.append("Slightly cooler")
        } else if conditions.contains("slightly_warmer") {
            narrativeParts.append("Slightly warmer")
        }

        // Humidity narrative - NEW!
        if conditions.contains("much_more_humid") {
            narrativeParts.append("much more humid")
        } else if conditions.contains("much_drier_air") {
            narrativeParts.append("much drier air")
        } else if conditions.contains("more_humid") {
            narrativeParts.append("more humid")
        } else if conditions.contains("drier_air") {
            narrativeParts.append("drier air")
        } else if conditions.contains("slightly_more_humid") {
            narrativeParts.append("slightly more humid")
        } else if conditions.contains("slightly_drier_air") {
            narrativeParts.append("slightly drier air")
        }

        // Weather condition narrative
        if conditions.contains("much_rainier") {
            narrativeParts.append("much rainier")
        } else if conditions.contains("rainier") {
            narrativeParts.append("rainier")
        } else if conditions.contains("drier") {
            narrativeParts.append("drier")
        }

        // Wind narrative
        if conditions.contains("much_windier") {
            narrativeParts.append("much windier")
        } else if conditions.contains("windier") {
            narrativeParts.append("windier")
        } else if conditions.contains("calmer") {
            narrativeParts.append("calmer")
        }

        // Combine narratives with proper grammar
        let baseNarrative: String
        if narrativeParts.isEmpty {
            baseNarrative = "Similar conditions"
        } else if narrativeParts.count == 1 {
            baseNarrative = narrativeParts[0]
        } else if narrativeParts.count == 2 {
            baseNarrative = "\(narrativeParts[0]) and \(narrativeParts[1])"
        } else {
            var parts = narrativeParts
            let lastPart = parts.removeLast()
            baseNarrative = "\(parts.joined(separator: ", ")) and \(lastPart)"
        }

        let comparison = narrativeParts.isEmpty ? "to yesterday" : "than yesterday"

        return "\(baseNarrative) \(comparison)"
    }

    // MARK: - Contextual Advice Generation

    private static func generateContextualAdvice(factors: WeatherFactors, experiences: Set<WeatherExperience>) -> [String] {
        var advice: [String] = []

        // Temperature-based advice
        if factors.temperatureDelta < -10 {
            advice.append("Bundle up! Consider a hat and gloves 🧤")
        } else if factors.temperatureDelta < -5 {
            advice.append("Dress warmly - it's noticeably cooler 🧥")
        } else if factors.temperatureDelta > 10 {
            advice.append("Dress lighter - it's much warmer today ☀️")
        }

        // Precipitation advice
        if factors.precipitationDelta > 0.2 {
            advice.append("Pack an umbrella - rain expected ☂️")
        } else if factors.precipitationDelta > 0.05 {
            advice.append("Light rain possible - consider a jacket 🌧️")
        }

        // Wind advice
        if factors.windSpeedDelta > 8 {
            advice.append("Expect strong winds - secure loose items 💨")
        }

        // Experience-specific advice
        if experiences.contains(.bike) && factors.windSpeedDelta > 5 {
            advice.append("Cycling will be more challenging due to wind 🚴‍♂️")
        }

        if experiences.contains(.walking) && factors.precipitationDelta > 0.1 {
            advice.append("Walking conditions may be wet - wear appropriate shoes 👟")
        }

        if experiences.contains(.workingOutside) {
            if factors.temperatureDelta < -5 {
                advice.append("Outdoor work will be colder - layer appropriately 🏗️")
            }
            if factors.precipitationDelta > 0.1 {
                advice.append("Outdoor work may be affected by rain ⛈️")
            }
        }

        if experiences.contains(.transit) && factors.precipitationDelta > 0.15 {
            advice.append("Allow extra time for public transit due to weather 🚌")
        }

        // Weather pattern advice
        switch factors.weatherCodeChange {
        case .clearToStorm:
            advice.append("Weather is worsening - plan accordingly ⛈️")
        case .stormToClear:
            advice.append("Weather is improving - enjoy the clearer conditions! 🌤️")
        default:
            break
        }

        return advice
    }

    // MARK: - Emoji Selection

    private static func selectEmoji(conditions: [String], factors: WeatherFactors) -> String {
        if conditions.contains("much_colder") {
            return "🥶"
        } else if conditions.contains("much_warmer") {
            return "🌡️"
        } else if conditions.contains("much_rainier") {
            return "☔"
        } else if conditions.contains("much_windier") {
            return "💨"
        } else if conditions.contains("weather_improving") {
            return "🌤️"
        } else if conditions.contains("weather_deteriorating") {
            return "⛈️"
        } else {
            return "🌤️"
        }
    }

    // MARK: - Severity Determination

    private static func determineSeverity(factors: WeatherFactors) -> AnalysisSeverity {
        var severityScore = 0

        if abs(factors.temperatureDelta) > 15 { severityScore += 3 }
        else if abs(factors.temperatureDelta) > 10 { severityScore += 2 }
        else if abs(factors.temperatureDelta) > 5 { severityScore += 1 }

        if factors.precipitationDelta > 0.5 { severityScore += 3 }
        else if factors.precipitationDelta > 0.2 { severityScore += 2 }
        else if factors.precipitationDelta > 0.1 { severityScore += 1 }

        if factors.windSpeedDelta > 15 { severityScore += 3 }
        else if factors.windSpeedDelta > 10 { severityScore += 2 }
        else if factors.windSpeedDelta > 5 { severityScore += 1 }

        switch severityScore {
        case 0...1: return .mild
        case 2...4: return .moderate
        case 5...7: return .significant
        default: return .severe
        }
    }
}