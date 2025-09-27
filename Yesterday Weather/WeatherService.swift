//
//  WeatherService.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Weather Service

class WeatherService: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var weatherComparison: WeatherComparison?
    @Published var tenDayForecast: TenDayForecast?
    @Published var todayHourlyForecast: HourlyForecastData?

    // 🚀 PERFORMANCE: Progressive loading states for better UX
    @Published var isLoadingComparison = false
    @Published var isLoadingForecast = false
    @Published var isLoadingHourly = false

    private let baseURL = "https://api.open-meteo.com/v1/forecast"

    // 🚀 PERFORMANCE: Optimized URLSession configuration
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0 // 10 second timeout instead of default 60s
        config.timeoutIntervalForResource = 30.0 // 30 second resource timeout
        config.waitsForConnectivity = false // Don't wait for connectivity
        config.allowsCellularAccess = true
        config.httpMaximumConnectionsPerHost = 4 // Allow more concurrent requests
        return URLSession(configuration: config)
    }()

    @MainActor func fetchWeatherComparison(for location: WeatherLocation? = nil) async {
        let selectedLocation = location ?? WeatherLocation.newYorkMetro
        let startTime = Date()

        // 🚀 PERFORMANCE: Check cache first
        if let cachedData = WeatherCache.shared.getCachedWeather(for: selectedLocation) {
            // Instantly load cached data
            weatherComparison = cachedData.comparison
            tenDayForecast = cachedData.tenDayForecast
            todayHourlyForecast = cachedData.hourlyForecast
            print("WeatherService: ⚡ Instantly loaded cached data for \(selectedLocation.name)")
            return
        }

        isLoading = true
        error = nil

        do {
            // 🚀 PERFORMANCE: Use single optimized API call instead of 4 separate calls
            let combinedData = try await fetchCombinedWeatherData(for: selectedLocation)

            let (today, yesterday, forecast, hourly) = combinedData

            let todaySnapshot = WeatherSnapshot(
                from: today.current,
                date: Date()
            )

            let yesterdaySnapshot = WeatherSnapshot(
                from: yesterday.current,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            )

            print("WeatherService: Today's data - Temp: \(todaySnapshot.temperature)°F, Weather: \(todaySnapshot.description), Humidity: \(todaySnapshot.humidity)%")
            print("WeatherService: Yesterday's data - Temp: \(yesterdaySnapshot.temperature)°F, Weather: \(yesterdaySnapshot.description), Humidity: \(yesterdaySnapshot.humidity)%")

            weatherComparison = WeatherComparison(
                today: todaySnapshot,
                yesterday: yesterdaySnapshot
            )

            // Process 10-day forecast
            if let dailyData = forecast.daily {
                tenDayForecast = TenDayForecast(from: dailyData)
            }

            // Process hourly forecast
            if let hourlyWeatherData = hourly.hourly {
                print("WeatherService: Processing hourly data with \(hourlyWeatherData.time.count) time entries")
                print("WeatherService: First few times: \(Array(hourlyWeatherData.time.prefix(3)))")
                // Pass daily weather data for day/night detection
                todayHourlyForecast = HourlyForecastData(from: hourlyWeatherData, dailyWeather: forecast.daily)
            } else {
                print("WeatherService: No hourly data received from API")
                print("WeatherService: Hourly response structure: \(String(describing: hourly))")
            }

        } catch {
            self.error = "Failed to fetch weather data: \(error.localizedDescription)"
        }

        // 🚀 PERFORMANCE: Cache the fetched data for 15 minutes
        WeatherCache.shared.cacheWeather(
            for: selectedLocation,
            comparison: weatherComparison,
            tenDayForecast: tenDayForecast,
            hourlyForecast: todayHourlyForecast
        )

        let elapsedTime = Date().timeIntervalSince(startTime)
        print("WeatherService: ⚡ Fresh weather data fetched in \(String(format: "%.2f", elapsedTime)) seconds")

        isLoading = false
    }

    // 🚀 PERFORMANCE: Progressive loading - load comparison data first, then forecast data
    @MainActor func fetchWeatherDataProgressively(for location: WeatherLocation? = nil) async {
        let selectedLocation = location ?? WeatherLocation.newYorkMetro

        // Check cache first for instant loading
        if let cachedData = WeatherCache.shared.getCachedWeather(for: selectedLocation) {
            weatherComparison = cachedData.comparison
            tenDayForecast = cachedData.tenDayForecast
            todayHourlyForecast = cachedData.hourlyForecast
            print("WeatherService: ⚡ Progressive: Instantly loaded all cached data")
            return
        }

        // Progressive loading: Start with comparison data (most important)
        isLoadingComparison = true

        do {
            // Phase 1: Load today's weather + basic comparison (fastest)
            async let todayData = fetchCombinedCurrentAndForecast(for: selectedLocation)
            async let yesterdayData = fetchYesterdayWeatherOptimized(for: selectedLocation)

            let (combinedData, yesterday) = try await (todayData, yesterdayData)

            // Show comparison immediately
            if let current = combinedData.current {
                let todaySnapshot = WeatherSnapshot(from: current, date: Date())
                let yesterdaySnapshot = WeatherSnapshot(from: yesterday.current, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())

                weatherComparison = WeatherComparison(today: todaySnapshot, yesterday: yesterdaySnapshot)
                print("WeatherService: ⚡ Progressive: Phase 1 - Comparison loaded")
            }
            isLoadingComparison = false

            // Phase 2: Process forecast data (can happen after comparison is shown)
            isLoadingForecast = true
            if let dailyData = combinedData.daily {
                tenDayForecast = TenDayForecast(from: dailyData)
                print("WeatherService: ⚡ Progressive: Phase 2 - 10-day forecast loaded")
            }
            isLoadingForecast = false

            // Phase 3: Process hourly data (least critical, can be last)
            isLoadingHourly = true
            if let hourlyData = combinedData.hourly {
                todayHourlyForecast = HourlyForecastData(from: hourlyData, dailyWeather: combinedData.daily)
                print("WeatherService: ⚡ Progressive: Phase 3 - Hourly forecast loaded")
            }
            isLoadingHourly = false

            // Cache everything for next time
            WeatherCache.shared.cacheWeather(
                for: selectedLocation,
                comparison: weatherComparison,
                tenDayForecast: tenDayForecast,
                hourlyForecast: todayHourlyForecast
            )

        } catch {
            self.error = "Failed to fetch weather data: \(error.localizedDescription)"
            isLoadingComparison = false
            isLoadingForecast = false
            isLoadingHourly = false
        }
    }

    // 🚀 PERFORMANCE: Combined API call to get all data in fewer requests
    private func fetchCombinedWeatherData(for location: WeatherLocation) async throws -> (today: CurrentWeatherResponse, yesterday: CurrentWeatherResponse, forecast: WeatherData, hourly: WeatherData) {
        // Get current weather + forecast in one call (reduces from 4 to 2 API calls)
        async let combinedCurrentAndForecast = fetchCombinedCurrentAndForecast(for: location)
        async let historicalData = fetchYesterdayWeatherOptimized(for: location)

        let (currentAndForecast, yesterday) = try await (combinedCurrentAndForecast, historicalData)

        return (
            today: CurrentWeatherResponse(current: currentAndForecast.current!),
            yesterday: yesterday,
            forecast: currentAndForecast,
            hourly: currentAndForecast
        )
    }

    private func fetchCombinedCurrentAndForecast(for location: WeatherLocation) async throws -> WeatherData {
        let url = buildCombinedURL(for: location)
        print("WeatherService: 🚀 Fetching combined current + forecast data from: \(url)")
        return try await performRequest(url: url)
    }

    private func fetchYesterdayWeatherOptimized(for location: WeatherLocation) async throws -> CurrentWeatherResponse {
        // Simplified yesterday fetch with less processing
        let url = buildYesterdayHistoricalURL(for: location)
        print("WeatherService: 🚀 Fetching yesterday weather from: \(url)")

        let historicalData = try await performRequest(url: url)
        return try extractYesterdayWeather(from: historicalData)
    }

    private func fetchTodayWeather(for location: WeatherLocation) async throws -> CurrentWeatherResponse {
        let url = buildURL(pastDays: 0, location: location)
        print("WeatherService: Fetching TODAY weather from: \(url)")
        return try await performCurrentRequest(url: url)
    }

    private func fetchYesterdayWeather(for location: WeatherLocation) async throws -> CurrentWeatherResponse {
        // For yesterday's weather, we need to fetch historical hourly data and extract a specific hour
        let url = buildYesterdayHistoricalURL(for: location)
        print("WeatherService: Fetching YESTERDAY weather from: \(url)")

        let historicalData = try await performRequest(url: url)

        guard let hourly = historicalData.hourly else {
            throw WeatherServiceError.invalidResponse
        }

        // Find yesterday at the same hour as current time (or closest available)
        let timeManager = TimeManager.shared
        let currentHour = timeManager.nycCalendar.component(.hour, from: timeManager.currentNYCTime)
        let yesterday = timeManager.nycCalendar.date(byAdding: .day, value: -1, to: timeManager.currentNYCTime) ?? Date()

        // Look for data from yesterday at the same hour
        var bestIndex = 0
        var closestHourDiff = 24

        for (index, timeString) in hourly.time.enumerated() {
            guard let hourDate = timeManager.convertAPITimeToNYC(timeString) else { continue }

            let hourOfData = timeManager.nycCalendar.component(.hour, from: hourDate)
            let dayOfData = timeManager.nycCalendar.startOfDay(for: hourDate)
            let yesterdayStart = timeManager.nycCalendar.startOfDay(for: yesterday)

            // If this is from yesterday
            if dayOfData == yesterdayStart {
                let hourDiff = abs(hourOfData - currentHour)
                if hourDiff < closestHourDiff {
                    closestHourDiff = hourDiff
                    bestIndex = index
                }
            }
        }

        // Create CurrentWeather from historical hourly data
        let currentWeather = CurrentWeather(
            time: hourly.time[bestIndex],
            temperature2m: hourly.temperature2m[bestIndex],
            apparentTemperature: hourly.apparentTemperature[bestIndex],
            isDay: 1, // Assume day for historical data
            windSpeed10m: hourly.windSpeed10m[bestIndex],
            windDirection10m: hourly.windDirection10m[bestIndex],
            windGusts10m: 0, // Not available in hourly
            precipitation: hourly.rain[bestIndex] + hourly.showers[bestIndex],
            rain: hourly.rain[bestIndex],
            showers: hourly.showers[bestIndex],
            snowfall: 0, // Assume no snow for now
            weatherCode: hourly.weatherCode[bestIndex],
            cloudCover: hourly.cloudCover[bestIndex],
            relativeHumidity2m: hourly.relativeHumidity2m[bestIndex]
        )

        print("WeatherService: Using yesterday's data from hour \(timeManager.nycCalendar.component(.hour, from: timeManager.convertAPITimeToNYC(hourly.time[bestIndex]) ?? Date()))")

        return CurrentWeatherResponse(current: currentWeather)
    }

    private func fetchTenDayForecast(for location: WeatherLocation) async throws -> WeatherData {
        let url = buildForecastURL(for: location)
        return try await performRequest(url: url)
    }

    private func fetchTodayHourlyForecast(for location: WeatherLocation) async throws -> WeatherData {
        let url = buildHourlyForecastURL(for: location)
        return try await performRequest(url: url)
    }

    private func buildURL(pastDays: Int, location: WeatherLocation) -> URL {
        var components = URLComponents(string: baseURL)!

        let queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,is_day,wind_speed_10m,wind_direction_10m,wind_gusts_10m,precipitation,rain,showers,snowfall,weather_code,cloud_cover,relative_humidity_2m"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "past_days", value: String(pastDays))
        ]

        components.queryItems = queryItems
        return components.url!
    }

    private func buildForecastURL(for location: WeatherLocation) -> URL {
        var components = URLComponents(string: baseURL)!

        let queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "daily", value: "sunrise,sunset,temperature_2m_max,temperature_2m_min,rain_sum,showers_sum,precipitation_sum,precipitation_probability_max,precipitation_hours"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "forecast_days", value: "10")
        ]

        components.queryItems = queryItems
        return components.url!
    }

    private func buildHourlyForecastURL(for location: WeatherLocation) -> URL {
        var components = URLComponents(string: baseURL)!

        let queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "hourly", value: "temperature_2m,relative_humidity_2m,apparent_temperature,rain,showers,cloud_cover,visibility,wind_direction_10m,wind_speed_10m,temperature_80m,weather_code"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "forecast_days", value: "2")
        ]

        components.queryItems = queryItems
        return components.url!
    }

    private func buildYesterdayHistoricalURL(for location: WeatherLocation) -> URL {
        var components = URLComponents(string: baseURL)!

        let queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "hourly", value: "temperature_2m,relative_humidity_2m,apparent_temperature,rain,showers,cloud_cover,visibility,wind_direction_10m,wind_speed_10m,temperature_80m,weather_code"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "past_days", value: "1"),
            URLQueryItem(name: "forecast_days", value: "0")
        ]

        components.queryItems = queryItems
        return components.url!
    }

    // 🚀 PERFORMANCE: Combined URL that gets current + forecast + hourly in one API call
    private func buildCombinedURL(for location: WeatherLocation) -> URL {
        var components = URLComponents(string: baseURL)!

        let queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            // Current weather
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,is_day,wind_speed_10m,wind_direction_10m,wind_gusts_10m,precipitation,rain,showers,snowfall,weather_code,cloud_cover,relative_humidity_2m"),
            // Daily forecast (10-day)
            URLQueryItem(name: "daily", value: "sunrise,sunset,temperature_2m_max,temperature_2m_min,rain_sum,showers_sum,precipitation_sum,precipitation_probability_max,precipitation_hours"),
            // Hourly forecast (next 2 days)
            URLQueryItem(name: "hourly", value: "temperature_2m,relative_humidity_2m,apparent_temperature,rain,showers,cloud_cover,visibility,wind_direction_10m,wind_speed_10m,temperature_80m,weather_code"),
            // Settings
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "forecast_days", value: "10")
        ]

        components.queryItems = queryItems
        return components.url!
    }

    // 🚀 PERFORMANCE: Optimized yesterday weather extraction
    private func extractYesterdayWeather(from historicalData: WeatherData) throws -> CurrentWeatherResponse {
        guard let hourly = historicalData.hourly,
              !hourly.time.isEmpty else {
            throw WeatherServiceError.invalidResponse
        }

        // Simple approach: use the middle hour from yesterday's data for better average
        let middleIndex = hourly.time.count / 2

        let currentWeather = CurrentWeather(
            time: hourly.time[middleIndex],
            temperature2m: hourly.temperature2m[middleIndex],
            apparentTemperature: hourly.apparentTemperature[middleIndex],
            isDay: 1,
            windSpeed10m: hourly.windSpeed10m[middleIndex],
            windDirection10m: hourly.windDirection10m[middleIndex],
            windGusts10m: 0,
            precipitation: hourly.rain[middleIndex] + hourly.showers[middleIndex],
            rain: hourly.rain[middleIndex],
            showers: hourly.showers[middleIndex],
            snowfall: 0,
            weatherCode: hourly.weatherCode[middleIndex],
            cloudCover: hourly.cloudCover[middleIndex],
            relativeHumidity2m: hourly.relativeHumidity2m[middleIndex]
        )

        return CurrentWeatherResponse(current: currentWeather)
    }

    private func performRequest(url: URL) async throws -> WeatherData {
        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherServiceError.invalidResponse
        }

        do {
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            return weatherData
        } catch {
            print("Decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            }
            throw WeatherServiceError.decodingError(error)
        }
    }

    private func performCurrentRequest(url: URL) async throws -> CurrentWeatherResponse {
        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherServiceError.invalidResponse
        }

        do {
            let weatherData = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
            return weatherData
        } catch {
            print("Current weather decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            }
            throw WeatherServiceError.decodingError(error)
        }
    }

    // 🚀 PERFORMANCE: Cache management methods
    func clearCache() {
        WeatherCache.shared.clearCache()
    }

    func getCacheStatus(for location: WeatherLocation) -> String {
        if let _ = WeatherCache.shared.getCachedWeather(for: location) {
            return "✅ Cached"
        } else {
            return "🔄 Will fetch"
        }
    }
}

// MARK: - Weather Service Errors

enum WeatherServiceError: LocalizedError {
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from weather service"
        case .decodingError(let error):
            return "Failed to decode weather data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock Data for Development/Testing

extension WeatherService {
    static func createMockComparison() -> WeatherComparison {
        let today = WeatherSnapshot(
            date: Date(),
            temperature: 72.5,
            precipitation: 0.1,
            humidity: 65,
            weatherCode: 2,
            windSpeed: 8.5,
            description: "Partly cloudy"
        )

        let yesterday = WeatherSnapshot(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            temperature: 68.3,
            precipitation: 0.0,
            humidity: 58,
            weatherCode: 1,
            windSpeed: 6.2,
            description: "Mainly clear"
        )

        return WeatherComparison(today: today, yesterday: yesterday)
    }
}