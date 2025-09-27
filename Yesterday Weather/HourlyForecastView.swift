//
//  HourlyForecastView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/24/25.
//

import SwiftUI

struct HourlyForecastView: View {
    let hourlyForecast: HourlyForecastData

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Hourly Forecast")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if hourlyForecast.hours.isEmpty {
                Text("Hourly data unavailable")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(hourlyForecast.hours.enumerated()), id: \.offset) { index, hour in
                            HourlyForecastCard(hour: hour, isNow: hour.isCurrentHour)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct HourlyForecastCard: View {
    let hour: HourlyDataPoint
    let isNow: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Time
            Text(isNow ? "Now" : hour.timeString)
                .font(.caption2)
                .fontWeight(isNow ? .semibold : .medium)
                .foregroundColor(isNow ? .warmEmphasis : .warmTextSecondary)

            // Weather Icon
            WeatherIconView(weatherCode: hour.weatherCode, isDay: hour.isDayTime, size: 20)
                .frame(height: 22)

            // Temperature
            Text("\(Int(round(hour.temperature)))°")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Precipitation (only if > 0)
            if hour.precipitation > 0.1 {
                VStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.weatherRain)
                    Text("\(String(format: "%.0f", hour.precipitation * 100))%")
                        .font(.system(size: 8))
                        .foregroundColor(.weatherRain)
                }
            } else {
                VStack(spacing: 2) {
                    // Spacer to maintain alignment
                    Color.clear
                        .frame(height: 8)
                    Color.clear
                        .frame(height: 8)
                }
            }
        }
        .frame(width: 44)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(isNow ? Color.warmEmphasis.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isNow ? Color.warmEmphasis.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    HourlyForecastView(hourlyForecast: HourlyForecastData(hours: []))
        .padding()
        .background(Color.gray.opacity(0.1))
}