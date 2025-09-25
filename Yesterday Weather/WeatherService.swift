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

    private let baseURL = "https://api.open-meteo.com/v1/forecast"

    @MainActor func fetchWeatherComparison(for location: WeatherLocation? = nil) async {
        isLoading = true
        error = nil

        let selectedLocation = location ?? WeatherLocation.newYorkMetro
        let startTime = Date()

        do {
            // Fetch today's forecast, yesterday's actual weather, hourly forecast, and 10-day forecast
            async let todayData = fetchTodayWeather(for: selectedLocation)
            async let yesterdayData = fetchYesterdayWeather(for: selectedLocation)
            async let forecastData = fetchTenDayForecast(for: selectedLocation)
            async let hourlyData = fetchTodayHourlyForecast(for: selectedLocation)

            let (today, yesterday, forecast, hourly) = try await (todayData, yesterdayData, forecastData, hourlyData)

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
                todayHourlyForecast = HourlyForecastData(from: hourlyWeatherData)
            } else {
                print("WeatherService: No hourly data received from API")
                print("WeatherService: Hourly response structure: \(String(describing: hourly))")
            }

        } catch {
            self.error = "Failed to fetch weather data: \(error.localizedDescription)"
        }

        // Ensure minimum loading time for quote display
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minimumLoadTime: TimeInterval = 7.0

        if elapsedTime < minimumLoadTime {
            let remainingTime = minimumLoadTime - elapsedTime
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }

        isLoading = false
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

    private func performRequest(url: URL) async throws -> WeatherData {
        let (data, response) = try await URLSession.shared.data(from: url)

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
        let (data, response) = try await URLSession.shared.data(from: url)

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