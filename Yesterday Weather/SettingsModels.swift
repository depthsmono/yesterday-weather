//
//  SettingsModels.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Weather Experience Settings

enum WeatherExperience: String, CaseIterable, Identifiable, Codable {
    case walking = "walking"
    case car = "car"
    case transit = "transit"
    case bike = "bike"
    case workingOutside = "working_outside"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .walking: return "Walking"
        case .car: return "Car"
        case .transit: return "Transit"
        case .bike: return "Bike"
        case .workingOutside: return "Working Outside"
        }
    }

    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .car: return "car.fill"
        case .transit: return "bus.fill"
        case .bike: return "bicycle"
        case .workingOutside: return "hammer.fill"
        }
    }

    var description: String {
        switch self {
        case .walking: return "You'll walk outdoors"
        case .car: return "You'll travel by car"
        case .transit: return "You'll use public transportation"
        case .bike: return "You bike or cycle regularly"
        case .workingOutside: return "You work outdoors"
        }
    }
}

// MARK: - Settings Manager

@MainActor
class SettingsManager: ObservableObject {
    @Published var enabledExperiences: Set<WeatherExperience> = []
    @Published var preloadWeatherEnabled = false
    @Published var preloadTime = Date()

    private let userDefaults = UserDefaults.standard

    init() {
        loadSettings()
    }

    func toggleExperience(_ experience: WeatherExperience) {
        if enabledExperiences.contains(experience) {
            enabledExperiences.remove(experience)
        } else {
            enabledExperiences.insert(experience)
        }
        saveSettings()
    }

    func setPreloadEnabled(_ enabled: Bool) {
        preloadWeatherEnabled = enabled
        saveSettings()
    }

    func setPreloadTime(_ time: Date) {
        preloadTime = time
        saveSettings()
    }

    private func loadSettings() {
        // Load enabled experiences
        if let experienceData = userDefaults.data(forKey: "enabledExperiences"),
           let experiences = try? JSONDecoder().decode(Set<WeatherExperience>.self, from: experienceData) {
            enabledExperiences = experiences
        }

        // Load preload settings
        preloadWeatherEnabled = userDefaults.bool(forKey: "preloadWeatherEnabled")

        if let preloadTimeData = userDefaults.data(forKey: "preloadTime"),
           let time = try? JSONDecoder().decode(Date.self, from: preloadTimeData) {
            preloadTime = time
        } else {
            // Default preload time to 7:00 AM
            let calendar = Calendar.current
            preloadTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }

    private func saveSettings() {
        // Save enabled experiences
        if let experienceData = try? JSONEncoder().encode(enabledExperiences) {
            userDefaults.set(experienceData, forKey: "enabledExperiences")
        }

        // Save preload settings
        userDefaults.set(preloadWeatherEnabled, forKey: "preloadWeatherEnabled")

        if let preloadTimeData = try? JSONEncoder().encode(preloadTime) {
            userDefaults.set(preloadTimeData, forKey: "preloadTime")
        }
    }

    // Helper to get weather experience context for comparison descriptions
    func getWeatherContext() -> String {
        if enabledExperiences.isEmpty {
            return "general weather conditions"
        }

        let contexts = enabledExperiences.map { experience in
            switch experience {
            case .walking: return "walking comfort"
            case .car: return "driving conditions"
            case .transit: return "commuting comfort"
            case .bike: return "cycling conditions"
            case .workingOutside: return "outdoor work conditions"
            }
        }

        return contexts.joined(separator: ", ")
    }
}
