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

        let calendar = nycCalendar
        if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        }

        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: date)

        // For this week, show full day name, for next week show abbreviated
        let daysFromNow = calendar.dateComponents([.day], from: calendar.startOfDay(for: currentNYCTime), to: calendar.startOfDay(for: date)).day ?? 0

        if daysFromNow > 7 {
            formatter.dateFormat = "E" // Abbreviated (Mon, Tue, etc.)
            return formatter.string(from: date)
        } else {
            return dayName
        }
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