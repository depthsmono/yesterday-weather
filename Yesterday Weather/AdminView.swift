//
//  AdminView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/25/25.
//

import SwiftUI

struct AdminView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var narrativeSettings = NarrativeSettings.shared

    // All weather codes from WeatherCodeMapper
    private let weatherCodes: [(code: Int, description: String)] = [
        (0, "Clear sky"),
        (1, "Mainly clear"),
        (2, "Partly cloudy"),
        (3, "Overcast"),
        (45, "Fog"),
        (48, "Depositing rime fog"),
        (51, "Light drizzle"),
        (53, "Moderate drizzle"),
        (55, "Dense drizzle"),
        (56, "Light freezing drizzle"),
        (57, "Dense freezing drizzle"),
        (61, "Slight rain"),
        (63, "Moderate rain"),
        (65, "Heavy rain"),
        (66, "Light freezing rain"),
        (67, "Heavy freezing rain"),
        (71, "Slight snow fall"),
        (73, "Moderate snow fall"),
        (75, "Heavy snow fall"),
        (77, "Snow grains"),
        (80, "Slight rain showers"),
        (81, "Moderate rain showers"),
        (82, "Violent rain showers"),
        (85, "Slight snow showers"),
        (86, "Heavy snow showers"),
        (95, "Thunderstorm"),
        (96, "Thunderstorm with slight hail"),
        (99, "Thunderstorm with heavy hail")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Weather Icons Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weather Icons")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(weatherCodes, id: \.code) { weather in
                                WeatherIconCard(
                                    code: weather.code,
                                    description: weather.description
                                )
                            }
                        }
                    }

                    Divider()
                        .padding(.vertical)

                    // Narrative Settings Section
                    NarrativeSettingsView()
                        .environmentObject(narrativeSettings)
                }
                .padding()
            }
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        narrativeSettings.saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WeatherIconCard: View {
    let code: Int
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            // Weather Code
            Text("Code \(code)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // Weather Icon
            Image(systemName: WeatherCodeMapper.icon(for: code))
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(height: 50)

            // Description
            Text(description)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Icon Name
            Text(WeatherCodeMapper.icon(for: code))
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.08),
                    Color.cyan.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Narrative Settings View

struct NarrativeSettingsView: View {
    @EnvironmentObject var settings: NarrativeSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Narrative Thresholds")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Reset") {
                    settings.resetToDefaults()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            Text("Adjust the ranges that determine narrative outcomes")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Temperature Section
            ThresholdSection(
                title: "Temperature (°F)",
                icon: "thermometer",
                slightValue: $settings.temperatureSlightThreshold,
                significantValue: $settings.temperatureSignificantThreshold,
                muchValue: $settings.temperatureMuchThreshold,
                slightRange: 0.1...10.0,
                significantRange: 1.0...20.0,
                muchRange: 3.0...40.0,
                testValue: 5.5,
                getTestNarrative: { settings.getTemperatureNarrative(delta: 5.5) }
            )

            // Humidity Section
            ThresholdSection(
                title: "Humidity (%)",
                icon: "humidity",
                slightValue: $settings.humiditySlightThreshold,
                significantValue: $settings.humiditySignificantThreshold,
                muchValue: $settings.humidityMuchThreshold,
                slightRange: 1.0...30.0,
                significantRange: 5.0...50.0,
                muchRange: 10.0...80.0,
                testValue: 15.0,
                getTestNarrative: { settings.getHumidityNarrative(delta: 15.0) }
            )

            // Precipitation Section
            ThresholdSection(
                title: "Precipitation (inches)",
                icon: "cloud.rain",
                slightValue: $settings.precipitationSlightThreshold,
                significantValue: $settings.precipitationSignificantThreshold,
                muchValue: $settings.precipitationMuchThreshold,
                slightRange: 0.01...1.0,
                significantRange: 0.05...2.0,
                muchRange: 0.1...5.0,
                testValue: 0.2,
                getTestNarrative: { settings.getPrecipitationNarrative(delta: 0.2) }
            )

            // Wind Section
            ThresholdSection(
                title: "Wind Speed (mph)",
                icon: "wind",
                slightValue: $settings.windSlightThreshold,
                significantValue: $settings.windSignificantThreshold,
                muchValue: $settings.windMuchThreshold,
                slightRange: 1.0...20.0,
                significantRange: 3.0...30.0,
                muchRange: 5.0...50.0,
                testValue: 8.0,
                getTestNarrative: { settings.getWindNarrative(delta: 8.0) }
            )
        }
    }
}

struct ThresholdSection: View {
    let title: String
    let icon: String
    @Binding var slightValue: Double
    @Binding var significantValue: Double
    @Binding var muchValue: Double
    let slightRange: ClosedRange<Double>
    let significantRange: ClosedRange<Double>
    let muchRange: ClosedRange<Double>
    let testValue: Double
    let getTestNarrative: () -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                // Test narrative
                Text("Test: \(getTestNarrative())")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
            }

            VStack(spacing: 8) {
                ThresholdSlider(
                    label: "Slight",
                    value: $slightValue,
                    range: slightRange
                )

                ThresholdSlider(
                    label: "Significant",
                    value: $significantValue,
                    range: significantRange
                )

                ThresholdSlider(
                    label: "Much",
                    value: $muchValue,
                    range: muchRange
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.08),
                    Color.gray.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

struct ThresholdSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            Slider(value: $value, in: range, step: range.upperBound > 10 ? 1.0 : 0.01)

            Text(String(format: range.upperBound > 10 ? "%.0f" : "%.2f", value))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

#Preview {
    AdminView()
}