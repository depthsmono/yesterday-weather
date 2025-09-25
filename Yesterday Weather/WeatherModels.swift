//
//  WeatherModels.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Weather Data Models

struct WeatherData: Codable {
    let current: CurrentWeather?
    let hourly: HourlyWeather?
    let daily: DailyWeather?

    enum CodingKeys: String, CodingKey {
        case current
        case hourly
        case daily
    }
}

struct CurrentWeatherResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let time: String
    let temperature2m: Double
    let apparentTemperature: Double
    let isDay: Int
    let windSpeed10m: Double
    let windDirection10m: Double
    let windGusts10m: Double
    let precipitation: Double
    let rain: Double
    let showers: Double
    let snowfall: Double
    let weatherCode: Int
    let cloudCover: Int
    let relativeHumidity2m: Int

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case windSpeed10m = "wind_speed_10m"
        case windDirection10m = "wind_direction_10m"
        case windGusts10m = "wind_gusts_10m"
        case precipitation
        case rain
        case showers
        case snowfall
        case weatherCode = "weather_code"
        case cloudCover = "cloud_cover"
        case relativeHumidity2m = "relative_humidity_2m"
    }
}

struct HourlyWeather: Codable {
    let time: [String]
    let temperature2m: [Double]
    let relativeHumidity2m: [Int]
    let apparentTemperature: [Double]
    let rain: [Double]
    let showers: [Double]
    let cloudCover: [Int]
    let visibility: [Double]
    let windDirection10m: [Double]
    let windSpeed10m: [Double]
    let temperature80m: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case rain
        case showers
        case cloudCover = "cloud_cover"
        case visibility
        case windDirection10m = "wind_direction_10m"
        case windSpeed10m = "wind_speed_10m"
        case temperature80m = "temperature_80m"
        case weatherCode = "weather_code"
    }
}

struct DailyWeather: Codable {
    let time: [String]
    let sunrise: [String]
    let sunset: [String]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let rainSum: [Double]
    let showersSum: [Double]
    let precipitationSum: [Double]
    let precipitationProbabilityMax: [Int]
    let precipitationHours: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case sunrise
        case sunset
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case rainSum = "rain_sum"
        case showersSum = "showers_sum"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case precipitationHours = "precipitation_hours"
    }
}

// MARK: - 10-Day Forecast Models

struct DayForecast {
    let date: Date
    let dayName: String
    let isToday: Bool
    let highTemp: Double
    let lowTemp: Double
    let precipitation: Double
    let precipitationProbability: Int
    let sunrise: Date?
    let sunset: Date?
    let description: String
    let icon: String

    init(from dailyWeather: DailyWeather, index: Int) {
        let timeManager = TimeManager.shared

        // Parse date using TimeManager's timezone handling
        let dateString = dailyWeather.time[index]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = timeManager.nycTimeZone
        self.date = dateFormatter.date(from: dateString) ?? Date()

        self.isToday = timeManager.isToday(self.date)
        self.dayName = timeManager.formatDayName(from: self.date, isToday: self.isToday)

        self.highTemp = dailyWeather.temperature2mMax[index]
        self.lowTemp = dailyWeather.temperature2mMin[index]
        self.precipitation = dailyWeather.precipitationSum[index]
        self.precipitationProbability = dailyWeather.precipitationProbabilityMax[index]

        // Parse sunrise/sunset times with NYC timezone
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        timeFormatter.timeZone = timeManager.nycTimeZone
        self.sunrise = timeFormatter.date(from: dailyWeather.sunrise[index])
        self.sunset = timeFormatter.date(from: dailyWeather.sunset[index])

        // Use precipitation probability to determine weather conditions
        if precipitation > 0.2 {
            self.description = "Rainy"
            self.icon = "cloud.rain.fill"
        } else if precipitationProbability > 50 {
            self.description = "Chance of rain"
            self.icon = "cloud.sun.rain.fill"
        } else if precipitationProbability > 20 {
            self.description = "Partly cloudy"
            self.icon = "cloud.sun.fill"
        } else {
            self.description = "Sunny"
            self.icon = "sun.max.fill"
        }
    }
}

struct TenDayForecast {
    let days: [DayForecast]

    init(from dailyWeather: DailyWeather) {
        var forecasts: [DayForecast] = []
        let maxDays = min(10, dailyWeather.time.count)

        for i in 0..<maxDays {
            forecasts.append(DayForecast(from: dailyWeather, index: i))
        }

        self.days = forecasts
    }
}

// MARK: - Weather Comparison Model

struct WeatherComparison {
    let today: WeatherSnapshot
    let yesterday: WeatherSnapshot

    var temperatureDifference: Double {
        today.temperature - yesterday.temperature
    }

    var precipitationDifference: Double {
        today.precipitation - yesterday.precipitation
    }

    var humidityDifference: Int {
        today.humidity - yesterday.humidity
    }

    func temperatureComparison(for experiences: Set<WeatherExperience> = []) -> ComparisonResult {
        let diff = temperatureDifference
        if abs(diff) < 2.0 {
            return .similar(getSimilarTemperatureMessage(for: experiences))
        } else if diff > 0 {
            return .higher(getWarmerMessage(diff: diff, for: experiences))
        } else {
            return .lower(getCoolerMessage(diff: abs(diff), for: experiences))
        }
    }

    var temperatureComparison: ComparisonResult {
        return temperatureComparison(for: [])
    }

    var precipitationComparison: ComparisonResult {
        let diff = precipitationDifference
        if abs(diff) < 0.1 {
            return .similar("Similar precipitation")
        } else if diff > 0 {
            return .higher("More precipitation (+\(String(format: "%.1f", diff))mm)")
        } else {
            return .lower("Less precipitation (\(String(format: "%.1f", diff))mm)")
        }
    }

    var humidityComparison: ComparisonResult {
        let diff = humidityDifference
        if abs(diff) < 5 {
            return .similar("Similar humidity")
        } else if diff > 0 {
            return .higher("More humid (+\(diff)%)")
        } else {
            return .lower("Less humid (\(diff)%)")
        }
    }

    // MARK: - Experience-Based Messages

    private func getSimilarTemperatureMessage(for experiences: Set<WeatherExperience>) -> String {
        if experiences.contains(.workingOutside) {
            return "Similar comfort for outdoor work"
        } else if experiences.contains(.bike) {
            return "Similar cycling conditions"
        } else if experiences.contains(.walking) {
            return "Similar walking comfort"
        } else {
            return "Similar temperature"
        }
    }

    private func getWarmerMessage(diff: Double, for experiences: Set<WeatherExperience>) -> String {
        let tempChange = String(format: "%.1f", diff)

        if experiences.contains(.workingOutside) {
            return "Warmer for outdoor work (+\(tempChange)°F)"
        } else if experiences.contains(.bike) {
            return "Warmer cycling weather (+\(tempChange)°F)"
        } else if experiences.contains(.walking) {
            return "Warmer for walking (+\(tempChange)°F)"
        } else if experiences.contains(.car) {
            return "Warmer driving conditions (+\(tempChange)°F)"
        } else {
            return "Warmer by \(tempChange)°F"
        }
    }

    private func getCoolerMessage(diff: Double, for experiences: Set<WeatherExperience>) -> String {
        let tempChange = String(format: "%.1f", diff)

        if experiences.contains(.workingOutside) {
            return "Cooler for outdoor work (-\(tempChange)°F)"
        } else if experiences.contains(.bike) {
            return "Cooler cycling weather (-\(tempChange)°F)"
        } else if experiences.contains(.walking) {
            return "Cooler for walking (-\(tempChange)°F)"
        } else if experiences.contains(.transit) {
            return "Cooler commute weather (-\(tempChange)°F)"
        } else {
            return "Cooler by \(tempChange)°F"
        }
    }
}

struct WeatherSnapshot {
    let date: Date
    let temperature: Double
    let precipitation: Double
    let humidity: Int
    let weatherCode: Int
    let windSpeed: Double
    let description: String

    init(from currentWeather: CurrentWeather, date: Date) {
        self.date = date
        self.temperature = currentWeather.temperature2m
        self.precipitation = currentWeather.precipitation
        self.humidity = currentWeather.relativeHumidity2m
        self.weatherCode = currentWeather.weatherCode
        self.windSpeed = currentWeather.windSpeed10m
        self.description = WeatherCodeMapper.description(for: currentWeather.weatherCode)
    }

    // Convenience initializer for manual creation
    init(date: Date, temperature: Double, precipitation: Double, humidity: Int, weatherCode: Int, windSpeed: Double, description: String) {
        self.date = date
        self.temperature = temperature
        self.precipitation = precipitation
        self.humidity = humidity
        self.weatherCode = weatherCode
        self.windSpeed = windSpeed
        self.description = description
    }
}

enum ComparisonResult {
    case higher(String)
    case lower(String)
    case similar(String)

    var text: String {
        switch self {
        case .higher(let message), .lower(let message), .similar(let message):
            return message
        }
    }

    var icon: String {
        switch self {
        case .higher:
            return "arrow.up.circle.fill"
        case .lower:
            return "arrow.down.circle.fill"
        case .similar:
            return "equal.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .higher:
            return "red"
        case .lower:
            return "blue"
        case .similar:
            return "gray"
        }
    }
}

// MARK: - Weather Code Mapping

struct WeatherCodeMapper {
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Light drizzle"
        case 56, 57: return "Freezing drizzle"
        case 61, 63, 65: return "Rain"
        case 66, 67: return "Freezing rain"
        case 71, 73, 75: return "Snow"
        case 77: return "Snow grains"
        case 80, 81, 82: return "Rain showers"
        case 85, 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Thunderstorm with hail"
        default: return "Unknown"
        }
    }

    static func icon(for code: Int) -> String {
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
}

// MARK: - Hourly Forecast Models

struct HourlyForecastData {
    let hours: [HourlyDataPoint]

    // Simple initializer for direct construction (useful for previews)
    init(hours: [HourlyDataPoint]) {
        self.hours = hours
    }

    init(from hourlyWeather: HourlyWeather, count: Int = 12) {
        let timeManager = TimeManager.shared
        print("HourlyForecastData: Initializing with \(hourlyWeather.time.count) total hours")

        let relevantHours = timeManager.getNextHours(from: hourlyWeather, count: count)
        print("HourlyForecastData: Got \(relevantHours.count) relevant hours")

        var dataPoints: [HourlyDataPoint] = []
        for (index, date) in relevantHours {
            let dataPoint = HourlyDataPoint(from: hourlyWeather, index: index, actualDate: date)
            dataPoints.append(dataPoint)
            print("HourlyForecastData: Added hour \(dataPoint.timeString) at \(dataPoint.temperature)°")
        }

        // Fallback: if no relevant hours found, show first few hours from API
        if dataPoints.isEmpty && !hourlyWeather.time.isEmpty {
            print("HourlyForecastData: No relevant hours found, using fallback with first \(min(count, hourlyWeather.time.count)) hours")
            for i in 0..<min(count, hourlyWeather.time.count) {
                if let date = timeManager.convertAPITimeToNYC(hourlyWeather.time[i]) {
                    let dataPoint = HourlyDataPoint(from: hourlyWeather, index: i, actualDate: date)
                    dataPoints.append(dataPoint)
                }
            }
        }

        self.hours = dataPoints
        print("HourlyForecastData: Final hours array has \(self.hours.count) items")
    }
}

struct HourlyDataPoint {
    let time: Date
    let timeString: String
    let isCurrentHour: Bool
    let temperature: Double
    let apparentTemperature: Double
    let precipitation: Double
    let humidity: Int
    let cloudCover: Int
    let windSpeed: Double
    let windDirection: Double
    let weatherCode: Int
    let icon: String
    let description: String

    init(from hourlyWeather: HourlyWeather, index: Int, actualDate: Date) {
        let timeManager = TimeManager.shared

        self.time = actualDate
        self.isCurrentHour = timeManager.isCurrentHour(actualDate)
        self.timeString = timeManager.formatHour(from: actualDate, isCurrentHour: self.isCurrentHour)

        self.temperature = hourlyWeather.temperature2m[index]
        self.apparentTemperature = hourlyWeather.apparentTemperature[index]
        self.precipitation = (hourlyWeather.rain[index] + hourlyWeather.showers[index]) * 100 // Convert to percentage
        self.humidity = hourlyWeather.relativeHumidity2m[index]
        self.cloudCover = hourlyWeather.cloudCover[index]
        self.windSpeed = hourlyWeather.windSpeed10m[index]
        self.windDirection = hourlyWeather.windDirection10m[index]
        self.weatherCode = hourlyWeather.weatherCode[index]

        // Use weather code for accurate icons and descriptions
        self.icon = WeatherCodeMapper.icon(for: self.weatherCode)
        self.description = WeatherCodeMapper.description(for: self.weatherCode)
    }
}

// MARK: - Location Constants

struct LocationConstants {
    static let newYorkLatitude = 40.7128
    static let newYorkLongitude = -74.0060
    static let newYorkName = "New York Metro"
}