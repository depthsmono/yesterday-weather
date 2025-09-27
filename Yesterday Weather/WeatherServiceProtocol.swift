//
//  WeatherServiceProtocol.swift
//  Yesterday Weather
//
//  Created by Claude AI on 9/26/25.
//

import Foundation

// MARK: - Weather Service Protocol

/// Protocol defining the weather service interface for better testability and dependency injection
protocol WeatherServiceProtocol: ObservableObject {
    // MARK: - Published Properties
    var isLoading: Bool { get }
    var error: String? { get }
    var weatherComparison: WeatherComparison? { get }
    var tenDayForecast: TenDayForecast? { get }
    var todayHourlyForecast: HourlyForecastData? { get }

    // Progressive loading states
    var isLoadingComparison: Bool { get }
    var isLoadingForecast: Bool { get }
    var isLoadingHourly: Bool { get }

    // MARK: - Core Methods
    @MainActor func fetchWeatherComparison(for location: WeatherLocation?) async
    @MainActor func fetchWeatherDataProgressively(for location: WeatherLocation?) async

    // MARK: - Cache Management
    func clearCache()
    func getCacheStatus(for location: WeatherLocation) -> String
}

// MARK: - Mock Weather Service for Testing

class MockWeatherService: WeatherServiceProtocol {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: String?
    @Published var weatherComparison: WeatherComparison?
    @Published var tenDayForecast: TenDayForecast?
    @Published var todayHourlyForecast: HourlyForecastData?

    @Published var isLoadingComparison = false
    @Published var isLoadingForecast = false
    @Published var isLoadingHourly = false

    // MARK: - Mock Configuration
    var shouldSimulateNetworkDelay = true
    var shouldSimulateError = false
    var mockErrorMessage = "Mock network error"

    // MARK: - Core Methods
    @MainActor func fetchWeatherComparison(for location: WeatherLocation? = nil) async {
        isLoading = true
        defer { isLoading = false }

        if shouldSimulateNetworkDelay {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }

        if shouldSimulateError {
            error = mockErrorMessage
            return
        }

        // Return mock data
        weatherComparison = WeatherService.createMockComparison()
        tenDayForecast = createMockForecast()
        todayHourlyForecast = createMockHourlyData()
    }

    @MainActor func fetchWeatherDataProgressively(for location: WeatherLocation? = nil) async {
        // Simulate progressive loading
        isLoadingComparison = true
        await fetchWeatherComparison(for: location)
        isLoadingComparison = false

        isLoadingForecast = true
        // Simulate additional loading time for forecast
        if shouldSimulateNetworkDelay {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        }
        isLoadingForecast = false

        isLoadingHourly = true
        // Simulate additional loading time for hourly
        if shouldSimulateNetworkDelay {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        }
        isLoadingHourly = false
    }

    // MARK: - Cache Management
    func clearCache() {
        // Mock implementation
        print("MockWeatherService: Cache cleared")
    }

    func getCacheStatus(for location: WeatherLocation) -> String {
        return "🧪 Mock Data"
    }

    // MARK: - Mock Data Creation
    private func createMockForecast() -> TenDayForecast? {
        // Create mock 10-day forecast data
        let mockDaily = DailyWeather(
            time: Array(0..<10).map { "2024-09-\(26 + $0)" },
            sunrise: Array(repeating: "2024-09-26T06:30", count: 10),
            sunset: Array(repeating: "2024-09-26T18:45", count: 10),
            temperature2mMax: Array(repeating: 75.0, count: 10),
            temperature2mMin: Array(repeating: 55.0, count: 10),
            rainSum: Array(repeating: 0.0, count: 10),
            showersSum: Array(repeating: 0.0, count: 10),
            precipitationSum: Array(repeating: 0.0, count: 10),
            precipitationProbabilityMax: Array(repeating: 10, count: 10),
            precipitationHours: Array(repeating: 0.0, count: 10)
        )
        return TenDayForecast(from: mockDaily)
    }

    private func createMockHourlyData() -> HourlyForecastData? {
        // Create mock hourly weather data first
        let currentTime = Date()
        let hourlyTimes = Array(0..<12).map { hour in
            let time = currentTime.addingTimeInterval(Double(hour) * 3600)
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: time)
        }

        let mockHourlyWeather = HourlyWeather(
            time: hourlyTimes,
            temperature2m: Array(0..<12).map { hour in
                let baseTemp = 70.0
                return baseTemp + (hour >= 6 && hour <= 18 ? 10.0 : -5.0)
            },
            relativeHumidity2m: Array(repeating: 65, count: 12),
            apparentTemperature: Array(0..<12).map { hour in
                let baseTemp = 72.0
                return baseTemp + (hour >= 6 && hour <= 18 ? 10.0 : -5.0)
            },
            rain: Array(repeating: 0.0, count: 12),
            showers: Array(repeating: 0.0, count: 12),
            cloudCover: Array(repeating: 30, count: 12),
            visibility: Array(repeating: 10.0, count: 12),
            windDirection10m: Array(repeating: 180.0, count: 12),
            windSpeed10m: Array(repeating: 5.0, count: 12),
            temperature80m: Array(repeating: 68.0, count: 12),
            weatherCode: Array(repeating: 2, count: 12)
        )

        // Use the proper HourlyForecastData initializer
        return HourlyForecastData(from: mockHourlyWeather, count: 12)
    }
}

// MARK: - WeatherService Extension

extension WeatherService: WeatherServiceProtocol {
    // WeatherService already conforms to the protocol
    // This extension just makes the conformance explicit
}