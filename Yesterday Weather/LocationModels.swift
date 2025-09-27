//
//  LocationModels.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Location Validation Errors

enum LocationValidationError: LocalizedError {
    case invalidLatitude(Double)
    case invalidLongitude(Double)
    case emptyName

    var errorDescription: String? {
        switch self {
        case .invalidLatitude(let lat):
            return "Invalid latitude: \(lat). Must be between -90 and 90 degrees."
        case .invalidLongitude(let lon):
            return "Invalid longitude: \(lon). Must be between -180 and 180 degrees."
        case .emptyName:
            return "Location name cannot be empty."
        }
    }
}

// MARK: - Location Models

struct WeatherLocation: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let isDefault: Bool

    init(name: String, latitude: Double, longitude: Double, isDefault: Bool) throws {
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 else {
            throw LocationValidationError.invalidLatitude(latitude)
        }
        guard longitude >= -180 && longitude <= 180 else {
            throw LocationValidationError.invalidLongitude(longitude)
        }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LocationValidationError.emptyName
        }

        self.id = UUID()
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
    }

    // Convenience initializer for internal use (bypasses validation)
    private init(unchecked name: String, latitude: Double, longitude: Double, isDefault: Bool) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
    }

    // Custom Codable implementation to handle validation during decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let isDefault = try container.decode(Bool.self, forKey: .isDefault)

        // Use unchecked initializer for decoding to avoid validation issues with saved data
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
    }

    /// Validates if the location coordinates are reasonable for weather data
    var isValidForWeatherData: Bool {
        // Exclude extreme polar regions where weather data might be unreliable
        return latitude > -85 && latitude < 85
    }

    static let newYorkMetro = WeatherLocation(
        unchecked: "New York Metro",
        latitude: 40.7128,
        longitude: -74.0060,
        isDefault: true
    )

    static let examples = [
        WeatherLocation(unchecked: "Los Angeles", latitude: 34.0522, longitude: -118.2437, isDefault: false),
        WeatherLocation(unchecked: "Chicago", latitude: 41.8781, longitude: -87.6298, isDefault: false),
        WeatherLocation(unchecked: "Miami", latitude: 25.7617, longitude: -80.1918, isDefault: false),
        WeatherLocation(unchecked: "San Francisco", latitude: 37.7749, longitude: -122.4194, isDefault: false),
        WeatherLocation(unchecked: "Boston", latitude: 42.3601, longitude: -71.0589, isDefault: false)
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

    func toWeatherLocation() -> WeatherLocation? {
        do {
            return try WeatherLocation(
                name: displayName,
                latitude: latitude,
                longitude: longitude,
                isDefault: false
            )
        } catch {
            print("LocationSearchResult: Failed to create WeatherLocation - \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Location Manager

class LocationManager: ObservableObject {
    @Published var locations: [WeatherLocation] = [WeatherLocation.newYorkMetro]
    @Published var currentLocation: WeatherLocation = WeatherLocation.newYorkMetro
    @Published var searchResults: [LocationSearchResult] = []
    @Published var isSearching = false

    init() {
        loadLocations()
    }

    func addLocation(_ location: WeatherLocation) {
        print("LocationManager: Adding location - \(location.name)")
        if !locations.contains(where: { $0.name == location.name }) {
            locations.append(location)
            print("LocationManager: Location added successfully. Total locations: \(locations.count)")
            saveLocations()
        } else {
            print("LocationManager: Location already exists - \(location.name)")
        }
    }

    func removeLocation(_ location: WeatherLocation) {
        locations.removeAll { $0.id == location.id }
        saveLocations()
    }

    func setCurrentLocation(_ location: WeatherLocation) {
        print("LocationManager: Setting current location to - \(location.name)")
        currentLocation = location
        // Move to top of list if not already there
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations.remove(at: index)
            print("LocationManager: Moved existing location to top of list")
        }
        locations.insert(location, at: 0)
        saveLocations()
        print("LocationManager: Current location set successfully")
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
        print("LocationManager: Loading saved locations...")
        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([WeatherLocation].self, from: data) {
            locations = decoded
            print("LocationManager: Loaded \(locations.count) saved locations")
        } else {
            // Default locations
            locations = [WeatherLocation.newYorkMetro]
            print("LocationManager: No saved locations found, using default")
        }

        // Load current location
        if let data = UserDefaults.standard.data(forKey: "currentLocation"),
           let decoded = try? JSONDecoder().decode(WeatherLocation.self, from: data) {
            currentLocation = decoded
            print("LocationManager: Loaded current location - \(currentLocation.name)")
        } else {
            // Set default current location if none saved
            currentLocation = WeatherLocation.newYorkMetro
            print("LocationManager: No saved current location, using default - \(currentLocation.name)")
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