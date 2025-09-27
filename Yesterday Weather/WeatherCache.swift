//
//  WeatherCache.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/26/25.
//

import Foundation

// MARK: - Weather Cache for Performance

class WeatherCache {
    static let shared = WeatherCache()

    private let cache = NSCache<NSString, CachedWeatherData>()
    private let cacheLifetime: TimeInterval = 15 * 60 // 15 minutes

    private init() {
        // Configure cache limits
        cache.countLimit = 10 // Maximum 10 locations
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB max
    }

    // MARK: - Cache Operations

    func getCachedWeather(for location: WeatherLocation) -> CachedWeatherData? {
        let key = cacheKey(for: location)
        guard let cachedData = cache.object(forKey: key) else {
            return nil
        }

        // Check if cache is still valid
        if Date().timeIntervalSince(cachedData.timestamp) > cacheLifetime {
            cache.removeObject(forKey: key)
            print("WeatherCache: Expired cache for \(location.name)")
            return nil
        }

        print("WeatherCache: Using cached data for \(location.name) (age: \(String(format: "%.1f", Date().timeIntervalSince(cachedData.timestamp)))s)")
        return cachedData
    }

    func cacheWeather(for location: WeatherLocation,
                     comparison: WeatherComparison?,
                     tenDayForecast: TenDayForecast?,
                     hourlyForecast: HourlyForecastData?) {
        let key = cacheKey(for: location)
        let cachedData = CachedWeatherData(
            timestamp: Date(),
            comparison: comparison,
            tenDayForecast: tenDayForecast,
            hourlyForecast: hourlyForecast
        )

        cache.setObject(cachedData, forKey: key)
        print("WeatherCache: Cached weather data for \(location.name)")
    }

    func clearCache() {
        cache.removeAllObjects()
        print("WeatherCache: Cleared all cached data")
    }

    // MARK: - Cache Key Generation

    private func cacheKey(for location: WeatherLocation) -> NSString {
        // Create unique key based on location coordinates rounded to 3 decimal places
        let lat = String(format: "%.3f", location.latitude)
        let lon = String(format: "%.3f", location.longitude)
        return "\(lat),\(lon)" as NSString
    }
}

// MARK: - Cached Weather Data

class CachedWeatherData: NSObject {
    let timestamp: Date
    let comparison: WeatherComparison?
    let tenDayForecast: TenDayForecast?
    let hourlyForecast: HourlyForecastData?

    init(timestamp: Date,
         comparison: WeatherComparison?,
         tenDayForecast: TenDayForecast?,
         hourlyForecast: HourlyForecastData?) {
        self.timestamp = timestamp
        self.comparison = comparison
        self.tenDayForecast = tenDayForecast
        self.hourlyForecast = hourlyForecast
        super.init()
    }
}