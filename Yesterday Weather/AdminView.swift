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

    // Weather conditions from enhanced weather icon mapper
    private let weatherCodes = WeatherIconMapper.allWeatherConditions

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
                                EnhancedWeatherIconCard(
                                    code: weather.code,
                                    description: weather.description,
                                    dayIcon: weather.dayIcon,
                                    nightIcon: weather.nightIcon
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
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        narrativeSettings.saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EnhancedWeatherIconCard: View {
    let code: Int
    let description: String
    let dayIcon: String
    let nightIcon: String?

    var body: some View {
        VStack(spacing: 12) {
            // Weather Code
            Text("Code \(code)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // Weather Icons - Day and Night
            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    // Day Icon
                    WeatherIconView(weatherCode: code, isDay: true, size: 32)
                        .frame(height: 40)

                    Text("Day")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }

                if nightIcon != nil {
                    VStack(spacing: 6) {
                        // Night Icon
                        WeatherIconView(weatherCode: code, isDay: false, size: 32)
                            .frame(height: 40)

                        Text("Night")
                            .font(.caption2)
                            .foregroundColor(.indigo)
                    }
                }
            }

            // Description
            Text(description)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Icon Names
            VStack(spacing: 4) {
                Text(dayIcon)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)

                if let nightIcon = nightIcon {
                    Text(nightIcon)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.indigo.opacity(0.1))
                        .cornerRadius(4)
                }
            }
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