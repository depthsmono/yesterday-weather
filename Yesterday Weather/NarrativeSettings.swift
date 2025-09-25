//
//  NarrativeSettings.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/25/25.
//

import Foundation
import SwiftUI

class NarrativeSettings: ObservableObject {
    static let shared = NarrativeSettings()

    // MARK: - Temperature Thresholds (°F)
    @Published var temperatureSlightThreshold: Double = 1.0
    @Published var temperatureSignificantThreshold: Double = 3.0
    @Published var temperatureMuchThreshold: Double = 8.0

    // MARK: - Humidity Thresholds (%)
    @Published var humiditySlightThreshold: Double = 5.0
    @Published var humiditySignificantThreshold: Double = 10.0
    @Published var humidityMuchThreshold: Double = 20.0

    // MARK: - Precipitation Thresholds (inches)
    @Published var precipitationSlightThreshold: Double = 0.05
    @Published var precipitationSignificantThreshold: Double = 0.1
    @Published var precipitationMuchThreshold: Double = 0.3

    // MARK: - Wind Speed Thresholds (mph)
    @Published var windSlightThreshold: Double = 3.0
    @Published var windSignificantThreshold: Double = 5.0
    @Published var windMuchThreshold: Double = 10.0

    private init() {
        loadSettings()
    }

    // MARK: - Persistence

    private func loadSettings() {
        temperatureSlightThreshold = UserDefaults.standard.object(forKey: "tempSlight") as? Double ?? 1.0
        temperatureSignificantThreshold = UserDefaults.standard.object(forKey: "tempSignificant") as? Double ?? 3.0
        temperatureMuchThreshold = UserDefaults.standard.object(forKey: "tempMuch") as? Double ?? 8.0

        humiditySlightThreshold = UserDefaults.standard.object(forKey: "humiditySlight") as? Double ?? 5.0
        humiditySignificantThreshold = UserDefaults.standard.object(forKey: "humiditySignificant") as? Double ?? 10.0
        humidityMuchThreshold = UserDefaults.standard.object(forKey: "humidityMuch") as? Double ?? 20.0

        precipitationSlightThreshold = UserDefaults.standard.object(forKey: "precipitationSlight") as? Double ?? 0.05
        precipitationSignificantThreshold = UserDefaults.standard.object(forKey: "precipitationSignificant") as? Double ?? 0.1
        precipitationMuchThreshold = UserDefaults.standard.object(forKey: "precipitationMuch") as? Double ?? 0.3

        windSlightThreshold = UserDefaults.standard.object(forKey: "windSlight") as? Double ?? 3.0
        windSignificantThreshold = UserDefaults.standard.object(forKey: "windSignificant") as? Double ?? 5.0
        windMuchThreshold = UserDefaults.standard.object(forKey: "windMuch") as? Double ?? 10.0
    }

    func saveSettings() {
        UserDefaults.standard.set(temperatureSlightThreshold, forKey: "tempSlight")
        UserDefaults.standard.set(temperatureSignificantThreshold, forKey: "tempSignificant")
        UserDefaults.standard.set(temperatureMuchThreshold, forKey: "tempMuch")

        UserDefaults.standard.set(humiditySlightThreshold, forKey: "humiditySlight")
        UserDefaults.standard.set(humiditySignificantThreshold, forKey: "humiditySignificant")
        UserDefaults.standard.set(humidityMuchThreshold, forKey: "humidityMuch")

        UserDefaults.standard.set(precipitationSlightThreshold, forKey: "precipitationSlight")
        UserDefaults.standard.set(precipitationSignificantThreshold, forKey: "precipitationSignificant")
        UserDefaults.standard.set(precipitationMuchThreshold, forKey: "precipitationMuch")

        UserDefaults.standard.set(windSlightThreshold, forKey: "windSlight")
        UserDefaults.standard.set(windSignificantThreshold, forKey: "windSignificant")
        UserDefaults.standard.set(windMuchThreshold, forKey: "windMuch")
    }

    func resetToDefaults() {
        temperatureSlightThreshold = 1.0
        temperatureSignificantThreshold = 3.0
        temperatureMuchThreshold = 8.0

        humiditySlightThreshold = 5.0
        humiditySignificantThreshold = 10.0
        humidityMuchThreshold = 20.0

        precipitationSlightThreshold = 0.05
        precipitationSignificantThreshold = 0.1
        precipitationMuchThreshold = 0.3

        windSlightThreshold = 3.0
        windSignificantThreshold = 5.0
        windMuchThreshold = 10.0

        saveSettings()
    }
}

// MARK: - Narrative Generation Functions

extension NarrativeSettings {

    func getTemperatureNarrative(delta: Double) -> String {
        let absDelta = abs(delta)
        if absDelta >= temperatureMuchThreshold {
            return delta > 0 ? "much warmer" : "much colder"
        } else if absDelta >= temperatureSignificantThreshold {
            return delta > 0 ? "significantly warmer" : "significantly colder"
        } else if absDelta >= temperatureSlightThreshold {
            return delta > 0 ? "slightly warmer" : "slightly cooler"
        } else {
            return "similar temperature"
        }
    }

    func getHumidityNarrative(delta: Double) -> String {
        let absDelta = abs(delta)
        if absDelta >= humidityMuchThreshold {
            return delta > 0 ? "much more humid" : "much drier air"
        } else if absDelta >= humiditySignificantThreshold {
            return delta > 0 ? "significantly more humid" : "significantly drier air"
        } else if absDelta >= humiditySlightThreshold {
            return delta > 0 ? "slightly more humid" : "slightly drier air"
        } else {
            return "similar humidity"
        }
    }

    func getPrecipitationNarrative(delta: Double) -> String {
        if delta >= precipitationMuchThreshold {
            return "much rainier"
        } else if delta >= precipitationSignificantThreshold {
            return "significantly rainier"
        } else if delta >= precipitationSlightThreshold {
            return "slightly rainier"
        } else if delta <= -precipitationSlightThreshold {
            return "drier"
        } else {
            return "similar precipitation"
        }
    }

    func getWindNarrative(delta: Double) -> String {
        if delta >= windMuchThreshold {
            return "much windier"
        } else if delta >= windSignificantThreshold {
            return "significantly windier"
        } else if delta >= windSlightThreshold {
            return "slightly windier"
        } else if delta <= -windSlightThreshold {
            return "calmer"
        } else {
            return "similar wind"
        }
    }
}