//
//  TimeManager.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/24/25.
//

import Foundation

// MARK: - Time Manager

class TimeManager: ObservableObject {
    static let shared = TimeManager()

    // NYC Timezone
    let nycTimeZone = TimeZone(identifier: "America/New_York")!

    // Current time in NYC timezone
    var currentNYCTime: Date {
        return Date()
    }

    // Calendar configured for NYC timezone
    var nycCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = nycTimeZone
        return calendar
    }

    private init() {}

    // MARK: - Date Formatting

    func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = nycTimeZone
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: currentNYCTime)
    }

    func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = nycTimeZone
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: currentNYCTime)
    }

    // MARK: - Hour-specific formatting

    func formatHour(from date: Date, isCurrentHour: Bool = false) -> String {
        if isCurrentHour {
            return "Now"
        }

        let formatter = DateFormatter()
        formatter.timeZone = nycTimeZone
        formatter.dateFormat = "ha"
        return formatter.string(from: date).lowercased()
    }

    // MARK: - Day-specific formatting

    func formatDayName(from date: Date, isToday: Bool = false) -> String {
        if isToday {
            return "Today"
        }

        let formatter = DateFormatter()
        formatter.timeZone = nycTimeZone

        // Always use abbreviated day names for consistent layout
        formatter.dateFormat = "E" // Abbreviated (Mon, Tue, etc.)
        return formatter.string(from: date)
    }

    // MARK: - Time zone conversion helpers

    func convertAPITimeToNYC(_ apiTimeString: String) -> Date? {
        // Try multiple date formats since the API might return different formats

        // First try ISO8601 with full format
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: apiTimeString) {
            return date
        }

        // Try the format the API is actually returning: "2025-09-25T23:00"
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        customFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        if let date = customFormatter.date(from: apiTimeString) {
            return date
        }

        // Try another common format: "2025-09-25T23:00:00"
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = customFormatter.date(from: apiTimeString) {
            return date
        }

        print("TimeManager: Could not parse time string: '\(apiTimeString)'")
        return nil
    }

    func isCurrentHour(_ date: Date) -> Bool {
        let calendar = nycCalendar
        let currentHour = calendar.component(.hour, from: currentNYCTime)
        let dateHour = calendar.component(.hour, from: date)

        return calendar.isDate(date, equalTo: currentNYCTime, toGranularity: .day) && currentHour == dateHour
    }

    func isToday(_ date: Date) -> Bool {
        return nycCalendar.isDate(date, inSameDayAs: currentNYCTime)
    }

    // MARK: - Hourly forecast time filtering

    func getNextHours(from hourlyData: HourlyWeather, count: Int = 24) -> [(index: Int, date: Date)] {
        var hoursToShow: [(index: Int, date: Date)] = []
        let now = currentNYCTime

        print("TimeManager: Current NYC time: \(now)")
        print("TimeManager: Looking for hours >= current time")

        for (index, timeString) in hourlyData.time.enumerated() {
            guard let hourDate = convertAPITimeToNYC(timeString) else {
                print("TimeManager: Failed to parse time string: \(timeString)")
                continue
            }

            // Much simpler logic: show current hour and all future hours
            // Allow a 30-minute grace period to include the current hour even if we're partway through it
            let graceTime = nycCalendar.date(byAdding: .minute, value: -30, to: now) ?? now

            if hourDate >= graceTime {
                hoursToShow.append((index: index, date: hourDate))
                print("TimeManager: Including hour \(timeString) -> \(hourDate)")
                if hoursToShow.count >= count {
                    break
                }
            } else {
                print("TimeManager: Skipping past hour \(timeString) -> \(hourDate)")
            }
        }

        print("TimeManager: Found \(hoursToShow.count) relevant hours out of \(hourlyData.time.count) total")
        return hoursToShow
    }

    // MARK: - Day/Night Detection

    func isDayTime(at date: Date, sunrise: Date?, sunset: Date?) -> Bool {
        guard let sunrise = sunrise, let sunset = sunset else {
            // Fallback: use simple time-based logic if sunrise/sunset not available
            let hour = nycCalendar.component(.hour, from: date)
            return hour >= 6 && hour < 19  // 6 AM to 7 PM as day
        }

        // Compare with actual sunrise/sunset times
        let result = date >= sunrise && date < sunset
        let formatter = DateFormatter()
        formatter.timeZone = nycTimeZone
        formatter.dateFormat = "HH:mm"
        print("TimeManager: isDayTime at \(formatter.string(from: date)) - sunrise: \(formatter.string(from: sunrise)), sunset: \(formatter.string(from: sunset)) -> \(result ? "DAY" : "NIGHT")")
        return result
    }

    func isDayTimeToday(at date: Date, dailyWeather: DailyWeather?) -> Bool {
        guard let dailyWeather = dailyWeather,
              !dailyWeather.sunrise.isEmpty,
              !dailyWeather.sunset.isEmpty else {
            // Fallback logic
            let hour = nycCalendar.component(.hour, from: date)
            return hour >= 6 && hour < 19
        }

        // Find the appropriate day's sunrise/sunset
        let targetDay = nycCalendar.startOfDay(for: date)

        for (index, dayString) in dailyWeather.time.enumerated() {
            guard let dayDate = parseDate(from: dayString) else { continue }
            let dayStart = nycCalendar.startOfDay(for: dayDate)

            if nycCalendar.isDate(targetDay, inSameDayAs: dayStart) {
                // Found matching day, parse sunrise/sunset
                let sunrise = parseSunriseSunset(dailyWeather.sunrise[index])
                let sunset = parseSunriseSunset(dailyWeather.sunset[index])
                return isDayTime(at: date, sunrise: sunrise, sunset: sunset)
            }
        }

        // Fallback if no matching day found
        let hour = nycCalendar.component(.hour, from: date)
        return hour >= 6 && hour < 19
    }

    private func parseDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = nycTimeZone
        return formatter.date(from: dateString)
    }

    private func parseSunriseSunset(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = nycTimeZone
        return formatter.date(from: timeString)
    }

    // MARK: - Debug info

    func debugTimeInfo() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = nycTimeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"

        return """
        Current NYC Time: \(formatter.string(from: currentNYCTime))
        Current Date: \(formatCurrentDate())
        Current Time: \(formatCurrentTime())
        """
    }
}