//
//  LocationModels.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Location Models

struct WeatherLocation: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let isDefault: Bool

    init(name: String, latitude: Double, longitude: Double, isDefault: Bool) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
    }

    static let newYorkMetro = WeatherLocation(
        name: "New York Metro",
        latitude: 40.7128,
        longitude: -74.0060,
        isDefault: true
    )

    static let examples = [
        WeatherLocation(name: "Los Angeles", latitude: 34.0522, longitude: -118.2437, isDefault: false),
        WeatherLocation(name: "Chicago", latitude: 41.8781, longitude: -87.6298, isDefault: false),
        WeatherLocation(name: "Miami", latitude: 25.7617, longitude: -80.1918, isDefault: false),
        WeatherLocation(name: "San Francisco", latitude: 37.7749, longitude: -122.4194, isDefault: false),
        WeatherLocation(name: "Boston", latitude: 42.3601, longitude: -71.0589, isDefault: false)
    ]
}

// MARK: - Location Search Result

struct LocationSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double

    var displayName: String {
        return "\(name), \(country)"
    }

    func toWeatherLocation() -> WeatherLocation {
        return WeatherLocation(
            name: displayName,
            latitude: latitude,
            longitude: longitude,
            isDefault: false
        )
    }
}

// MARK: - Location Manager

class LocationManager: ObservableObject {
    @Published var locations: [WeatherLocation] = [WeatherLocation.newYorkMetro]
    @Published var currentLocation: WeatherLocation = WeatherLocation.newYorkMetro
    @Published var searchResults: [LocationSearchResult] = []
    @Published var isSearching = false

    init() {
        // Simple init without any UserDefaults access for now
    }

    func addLocation(_ location: WeatherLocation) {
        if !locations.contains(where: { $0.name == location.name }) {
            locations.append(location)
            saveLocations()
        }
    }

    func removeLocation(_ location: WeatherLocation) {
        locations.removeAll { $0.id == location.id }
        saveLocations()
    }

    func setCurrentLocation(_ location: WeatherLocation) {
        currentLocation = location
        // Move to top of list if not already there
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations.remove(at: index)
        }
        locations.insert(location, at: 0)
        saveLocations()
    }

    @MainActor func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        // Use OpenStreetMap Nominatim API for location search (free, no API key needed)
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://nominatim.openstreetmap.org/search?q=\(encodedQuery)&format=json&limit=5&addressdetails=1"

        guard let url = URL(string: urlString) else {
            isSearching = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode([NominatimResult].self, from: data)

            searchResults = results.compactMap { result in
                guard let lat = Double(result.lat),
                      let lon = Double(result.lon) else {
                    return nil
                }

                // Extract city and country from display_name
                let components = result.display_name.components(separatedBy: ", ")
                let name = components.first ?? result.display_name
                let country = components.last ?? ""

                return LocationSearchResult(
                    name: name,
                    country: country,
                    latitude: lat,
                    longitude: lon
                )
            }
        } catch {
            print("Location search error: \(error)")
            searchResults = []
        }

        isSearching = false
    }

    private func loadLocations() {
        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([WeatherLocation].self, from: data) {
            locations = decoded
        } else {
            // Default locations
            locations = [WeatherLocation.newYorkMetro]
        }

        // Load current location
        if let data = UserDefaults.standard.data(forKey: "currentLocation"),
           let decoded = try? JSONDecoder().decode(WeatherLocation.self, from: data) {
            currentLocation = decoded
        } else {
            // Set default current location if none saved
            currentLocation = WeatherLocation.newYorkMetro
        }
    }

    private func saveLocations() {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: "savedLocations")
        }

        if let encoded = try? JSONEncoder().encode(currentLocation) {
            UserDefaults.standard.set(encoded, forKey: "currentLocation")
        }
    }
}

// MARK: - Nominatim API Response

private struct NominatimResult: Codable {
    let lat: String
    let lon: String
    let display_name: String

    enum CodingKeys: String, CodingKey {
        case lat, lon
        case display_name = "display_name"
    }
}