//
//  WeatherComparisonAnalyzer.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Weather Comparison Analyzer

struct WeatherComparisonAnalyzer {

    // MARK: - Analysis Results

    struct ComparisonAnalysis {
        let temperature: TemperatureAnalysis
        let precipitation: PrecipitationAnalysis
        let humidity: HumidityAnalysis
    }

    struct TemperatureAnalysis {
        let narrative: String
        let icon: String
        let severity: ComparisonSeverity
    }

    struct PrecipitationAnalysis {
        let narrative: String
        let icon: String
        let severity: ComparisonSeverity
    }

    struct HumidityAnalysis {
        let narrative: String
        let icon: String
        let severity: ComparisonSeverity
    }

    enum ComparisonSeverity {
        case minimal, minor, moderate, significant, extreme
    }

    // MARK: - Main Analysis Function

    static func analyzeComparison(_ comparison: WeatherComparison) -> ComparisonAnalysis {
        let tempAnalysis = analyzeTemperature(comparison)
        let precipAnalysis = analyzePrecipitation(comparison)
        let humidityAnalysis = analyzeHumidity(comparison)

        return ComparisonAnalysis(
            temperature: tempAnalysis,
            precipitation: precipAnalysis,
            humidity: humidityAnalysis
        )
    }

    // MARK: - Temperature Analysis

    private static func analyzeTemperature(_ comparison: WeatherComparison) -> TemperatureAnalysis {
        let delta = comparison.temperatureDifference
        let todayTemp = comparison.today.temperature
        let yesterdayTemp = comparison.yesterday.temperature

        let narrative: String
        let icon: String
        let severity: ComparisonSeverity

        switch abs(delta) {
        case 0..<2:
            narrative = generateSimilarTemperatureNarrative(today: todayTemp, yesterday: yesterdayTemp)
            icon = "thermometer"
            severity = .minimal

        case 2..<5:
            if delta > 0 {
                narrative = generateWarmerNarrative(delta: delta, today: todayTemp, yesterday: yesterdayTemp)
                icon = "thermometer.sun.fill"
            } else {
                narrative = generateCoolerNarrative(delta: abs(delta), today: todayTemp, yesterday: yesterdayTemp)
                icon = "thermometer.snowflake"
            }
            severity = .minor

        case 5..<10:
            if delta > 0 {
                narrative = generateMuchWarmerNarrative(delta: delta, today: todayTemp, yesterday: yesterdayTemp)
                icon = "thermometer.sun.fill"
            } else {
                narrative = generateMuchCoolerNarrative(delta: abs(delta), today: todayTemp, yesterday: yesterdayTemp)
                icon = "thermometer.snowflake"
            }
            severity = .moderate

        case 10..<20:
            if delta > 0 {
                narrative = generateHotNarrative(delta: delta, today: todayTemp, yesterday: yesterdayTemp)
                icon = "sun.max.fill"
            } else {
                narrative = generateColdNarrative(delta: abs(delta), today: todayTemp, yesterday: yesterdayTemp)
                icon = "snowflake"
            }
            severity = .significant

        default:
            if delta > 0 {
                narrative = generateExtremeHotNarrative(delta: delta, today: todayTemp, yesterday: yesterdayTemp)
                icon = "sun.max.fill"
            } else {
                narrative = generateExtremeColdNarrative(delta: abs(delta), today: todayTemp, yesterday: yesterdayTemp)
                icon = "snowflake"
            }
            severity = .extreme
        }

        return TemperatureAnalysis(narrative: narrative, icon: icon, severity: severity)
    }

    // MARK: - Precipitation Analysis

    private static func analyzePrecipitation(_ comparison: WeatherComparison) -> PrecipitationAnalysis {
        let delta = comparison.precipitationDifference
        let todayPrecip = comparison.today.precipitation
        let yesterdayPrecip = comparison.yesterday.precipitation

        let narrative: String
        let icon: String
        let severity: ComparisonSeverity

        // Analyze precipitation patterns
        if abs(delta) < 0.05 {
            narrative = generateSimilarPrecipitationNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
            icon = determinePrecipitationIcon(todayPrecip)
            severity = .minimal
        } else if delta > 0 {
            // More precipitation today
            if delta > 0.5 {
                narrative = generateMuchWetterNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
                icon = "cloud.heavyrain.fill"
                severity = .significant
            } else if delta > 0.2 {
                narrative = generateWetterNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
                icon = "cloud.rain.fill"
                severity = .moderate
            } else {
                narrative = generateSlightlyWetterNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
                icon = "cloud.drizzle.fill"
                severity = .minor
            }
        } else {
            // Less precipitation today
            let absDelta = abs(delta)
            if absDelta > 0.5 {
                narrative = generateMuchDrierNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
                icon = "drop.fill"
                severity = .significant
            } else if absDelta > 0.2 {
                narrative = generateDrierNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
                icon = "drop.fill"
                severity = .moderate
            } else {
                narrative = generateSlightlyDrierNarrative(today: todayPrecip, yesterday: yesterdayPrecip)
                icon = "drop.fill"
                severity = .minor
            }
        }

        return PrecipitationAnalysis(narrative: narrative, icon: icon, severity: severity)
    }

    // MARK: - Humidity Analysis

    private static func analyzeHumidity(_ comparison: WeatherComparison) -> HumidityAnalysis {
        let delta = comparison.humidityDifference
        let todayHumidity = comparison.today.humidity
        let yesterdayHumidity = comparison.yesterday.humidity

        let narrative: String
        let icon: String
        let severity: ComparisonSeverity

        switch abs(delta) {
        case 0..<5:
            narrative = generateSimilarHumidityNarrative(today: todayHumidity, yesterday: yesterdayHumidity)
            icon = "humidity"
            severity = .minimal

        case 5..<15:
            if delta > 0 {
                narrative = generateMoreHumidNarrative(delta: delta, today: todayHumidity, yesterday: yesterdayHumidity)
                icon = "humidity.fill"
            } else {
                narrative = generateLessHumidNarrative(delta: abs(delta), today: todayHumidity, yesterday: yesterdayHumidity)
                icon = "humidity"
            }
            severity = .minor

        case 15..<25:
            if delta > 0 {
                narrative = generateMuchMoreHumidNarrative(delta: delta, today: todayHumidity, yesterday: yesterdayHumidity)
                icon = "humidity.fill"
            } else {
                narrative = generateMuchLessHumidNarrative(delta: abs(delta), today: todayHumidity, yesterday: yesterdayHumidity)
                icon = "humidity"
            }
            severity = .moderate

        default:
            if delta > 0 {
                narrative = generateExtremelyHumidNarrative(delta: delta, today: todayHumidity, yesterday: yesterdayHumidity)
                icon = "humidity.fill"
            } else {
                narrative = generateExtremelyDryNarrative(delta: abs(delta), today: todayHumidity, yesterday: yesterdayHumidity)
                icon = "humidity"
            }
            severity = .significant
        }

        return HumidityAnalysis(narrative: narrative, icon: icon, severity: severity)
    }

    // MARK: - Temperature Narrative Generators

    private static func generateSimilarTemperatureNarrative(today: Double, yesterday: Double) -> String {
        let avgTemp = (today + yesterday) / 2
        if avgTemp > 80 {
            return "Hot both days"
        } else if avgTemp > 70 {
            return "Warm both days"
        } else if avgTemp > 50 {
            return "Mild both days"
        } else {
            return "Cool both days"
        }
    }

    private static func generateWarmerNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        if today > 85 {
            return "Hot today, warm yesterday"
        } else if today > 75 {
            return "Warm today, mild yesterday"
        } else {
            return "Warmer today (+\(String(format: "%.0f", delta))°F)"
        }
    }

    private static func generateCoolerNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        if today < 40 {
            return "Cold today, cool yesterday"
        } else if today < 60 {
            return "Cool today, mild yesterday"
        } else {
            return "Cooler today (-\(String(format: "%.0f", delta))°F)"
        }
    }

    private static func generateMuchWarmerNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        if today > 90 {
            return "Much hotter today than yesterday"
        } else {
            return "Much warmer today (+\(String(format: "%.0f", delta))°F)"
        }
    }

    private static func generateMuchCoolerNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        if today < 35 {
            return "Much colder today than yesterday"
        } else {
            return "Much cooler today (-\(String(format: "%.0f", delta))°F)"
        }
    }

    private static func generateHotNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        return "Significantly hotter today (+\(String(format: "%.0f", delta))°F)"
    }

    private static func generateColdNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        return "Significantly colder today (-\(String(format: "%.0f", delta))°F)"
    }

    private static func generateExtremeHotNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        return "Extremely hot compared to yesterday (+\(String(format: "%.0f", delta))°F)"
    }

    private static func generateExtremeColdNarrative(delta: Double, today: Double, yesterday: Double) -> String {
        return "Extremely cold compared to yesterday (-\(String(format: "%.0f", delta))°F)"
    }

    // MARK: - Precipitation Narrative Generators

    private static func generateSimilarPrecipitationNarrative(today: Double, yesterday: Double) -> String {
        let avgPrecip = (today + yesterday) / 2
        if avgPrecip < 0.01 {
            return "Dry both days"
        } else if avgPrecip < 0.1 {
            return "Light moisture both days"
        } else {
            return "Similar rainfall both days"
        }
    }

    private static func generateMuchWetterNarrative(today: Double, yesterday: Double) -> String {
        if yesterday < 0.05 {
            return "Heavy rain today, dry yesterday"
        } else {
            return "Much heavier rain today than yesterday"
        }
    }

    private static func generateWetterNarrative(today: Double, yesterday: Double) -> String {
        if yesterday < 0.1 {
            return "Rain today, light drizzle yesterday"
        } else {
            return "More rain today than yesterday"
        }
    }

    private static func generateSlightlyWetterNarrative(today: Double, yesterday: Double) -> String {
        return "Slightly more rain today"
    }

    private static func generateMuchDrierNarrative(today: Double, yesterday: Double) -> String {
        if today < 0.01 {
            return "Dry today, rainy yesterday"
        } else {
            return "Much less rain today than yesterday"
        }
    }

    private static func generateDrierNarrative(today: Double, yesterday: Double) -> String {
        return "Less rain today than yesterday"
    }

    private static func generateSlightlyDrierNarrative(today: Double, yesterday: Double) -> String {
        return "Slightly less rain today"
    }

    // MARK: - Humidity Narrative Generators

    private static func generateSimilarHumidityNarrative(today: Int, yesterday: Int) -> String {
        let avgHumidity = (today + yesterday) / 2
        if avgHumidity > 70 {
            return "Humid both days"
        } else if avgHumidity > 50 {
            return "Moderate humidity both days"
        } else {
            return "Dry air both days"
        }
    }

    private static func generateMoreHumidNarrative(delta: Int, today: Int, yesterday: Int) -> String {
        if today > 80 {
            return "Very humid today, moderate yesterday"
        } else {
            return "More humid today (+\(delta)%)"
        }
    }

    private static func generateLessHumidNarrative(delta: Int, today: Int, yesterday: Int) -> String {
        if today < 30 {
            return "Dry air today, humid yesterday"
        } else {
            return "Less humid today (-\(delta)%)"
        }
    }

    private static func generateMuchMoreHumidNarrative(delta: Int, today: Int, yesterday: Int) -> String {
        return "Much more humid today (+\(delta)%)"
    }

    private static func generateMuchLessHumidNarrative(delta: Int, today: Int, yesterday: Int) -> String {
        return "Much less humid today (-\(delta)%)"
    }

    private static func generateExtremelyHumidNarrative(delta: Int, today: Int, yesterday: Int) -> String {
        return "Extremely humid today vs yesterday (+\(delta)%)"
    }

    private static func generateExtremelyDryNarrative(delta: Int, today: Int, yesterday: Int) -> String {
        return "Extremely dry today vs yesterday (-\(delta)%)"
    }

    // MARK: - Helper Functions

    private static func determinePrecipitationIcon(_ precipitation: Double) -> String {
        if precipitation < 0.01 {
            return "drop.fill"
        } else if precipitation < 0.1 {
            return "cloud.drizzle.fill"
        } else if precipitation < 0.3 {
            return "cloud.rain.fill"
        } else {
            return "cloud.heavyrain.fill"
        }
    }
}