//
//  ContentView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingLocations = false
    @State private var showingSettings = false
    @State private var showingAdmin = false
    @State private var loadingQuote = WeatherQuoteBank.randomQuote()
    @State private var showQuote = true
    @State private var dataLoaded = false
    @State private var minimumTimeElapsed = false

    private var currentDateString: String {
        return TimeManager.shared.formatCurrentDate()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header - only show when not loading/showing quote
                if !showQuote && !weatherService.isLoading {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yesterday Weather")
                                .font(.custom("Apple Chancery", size: 20))
                                .foregroundColor(.primary)
                                .onLongPressGesture(minimumDuration: 2.0) {
                                    showingAdmin = true
                                }

                            Text(locationManager.currentLocation.name)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text(currentDateString)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 16) {
                            Button(action: {
                                showingLocations = true
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }

                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }

                if showQuote {
                    LoadingQuoteView(quote: loadingQuote) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showQuote = false
                        }
                    }
                } else if weatherService.isLoading {
                    LoadingView()
                } else if let error = weatherService.error {
                    ErrorView(error: error) {
                        Task {
                            await weatherService.fetchWeatherComparison()
                        }
                    }
                } else if let comparison = weatherService.weatherComparison {
                    WeatherComparisonView(
                        comparison: comparison,
                        tenDayForecast: weatherService.tenDayForecast,
                        hourlyForecast: weatherService.todayHourlyForecast,
                        settingsManager: settingsManager,
                        quoteOfTheDay: loadingQuote
                    )
                } else {
                    LoadingQuoteView(quote: loadingQuote) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showQuote = false
                        }
                    }
                }

                Spacer()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(isPresented: $showingLocations) {
            LocationsView()
                .environmentObject(locationManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showingAdmin) {
            AdminView()
        }
        .task {
            // Get a new random quote each time the app loads
            loadingQuote = WeatherQuoteBank.randomQuote()
            showQuote = true
            await weatherService.fetchWeatherComparison(for: locationManager.currentLocation)
        }
    }
}

// MARK: - Weather Comparison View

struct WeatherComparisonView: View {
    let comparison: WeatherComparison
    let tenDayForecast: TenDayForecast?
    let hourlyForecast: HourlyForecastData?
    let settingsManager: SettingsManager
    let quoteOfTheDay: WeatherQuote

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Today vs Yesterday Header
                ComparisonHeaderView(comparison: comparison, settingsManager: settingsManager, hourlyForecast: hourlyForecast)
                .onAppear {
                    print("ContentView: hourlyForecast is \(hourlyForecast == nil ? "nil" : "available with \(hourlyForecast!.hours.count) hours")")
                }

                // Weather Cards
                HStack(spacing: 16) {
                    WeatherCard(
                        title: "Yesterday",
                        subtitle: "Actual",
                        weather: comparison.yesterday,
                        isPrimary: false
                    )

                    WeatherCard(
                        title: "Today",
                        subtitle: "Forecast",
                        weather: comparison.today,
                        isPrimary: true
                    )
                }
                .padding(.horizontal)

                // Comparison Details
                ComparisonDetailsView(comparison: comparison, settingsManager: settingsManager)

                // 10-Day Forecast
                if let forecast = tenDayForecast {
                    TenDayForecastView(forecast: forecast)
                }

                // Quote of the Day
                QuoteOfTheDayView(quote: quoteOfTheDay)
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Comparison Header

struct ComparisonHeaderView: View {
    let comparison: WeatherComparison
    let settingsManager: SettingsManager
    let hourlyForecast: HourlyForecastData?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: WeatherCodeMapper.icon(for: comparison.today.weatherCode))
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(String(format: "%.0f", comparison.today.temperature))°F")
                        .font(.system(size: 36, weight: .bold))

                    Text(comparison.today.description)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    // Intelligent weather analysis
                    let analysis = WeatherIntelligence.analyzeWeatherComparison(comparison, experiences: settingsManager.enabledExperiences)

                    Text("\(analysis.emoji) \(analysis.narrative)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)

                    if let primaryAdvice = analysis.advice.first {
                        Text(primaryAdvice)
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }

            // Hourly Forecast
            if let hourlyForecast = hourlyForecast {
                Divider()
                    .background(Color.gray.opacity(0.3))

                HourlyForecastView(hourlyForecast: hourlyForecast)
                    .onAppear {
                        print("ComparisonHeaderView: Showing HourlyForecastView with \(hourlyForecast.hours.count) hours")
                    }
            } else {
                Text("Debug: No hourly forecast data")
                    .font(.caption)
                    .foregroundColor(.red)
                    .onAppear {
                        print("ComparisonHeaderView: hourlyForecast is nil")
                    }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    private func colorForComparison(_ comparison: ComparisonResult) -> Color {
        switch comparison {
        case .higher: return .red
        case .lower: return .blue
        case .similar: return .gray
        }
    }
}

// MARK: - Weather Card

struct WeatherCard: View {
    let title: String
    let subtitle: String
    let weather: WeatherSnapshot
    let isPrimary: Bool

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Image(systemName: WeatherCodeMapper.icon(for: weather.weatherCode))
                .font(.system(size: 30))
                .foregroundColor(isPrimary ? .orange : .blue)

            Text("\(String(format: "%.0f", weather.temperature))°F")
                .font(.title2)
                .fontWeight(.bold)

            Text(weather.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("\(String(format: "%.1f", weather.precipitation))\"")
                        .font(.caption)
                }

                HStack {
                    Image(systemName: "humidity.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("\(weather.humidity)%")
                        .font(.caption)
                }

                HStack {
                    Image(systemName: "wind")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text("\(String(format: "%.0f", weather.windSpeed)) mph")
                        .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isPrimary ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPrimary ? Color.orange.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Comparison Details

struct ComparisonDetailsView: View {
    let comparison: WeatherComparison
    let settingsManager: SettingsManager

    var body: some View {
        VStack(spacing: 16) {
            Text("How does today compare?")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                // Intelligent weather analysis
                let analysis = WeatherComparisonAnalyzer.analyzeComparison(comparison)

                IntelligentComparisonRow(
                    icon: analysis.temperature.icon,
                    title: "Temperature",
                    narrative: analysis.temperature.narrative,
                    severity: analysis.temperature.severity
                )

                IntelligentComparisonRow(
                    icon: analysis.precipitation.icon,
                    title: "Precipitation",
                    narrative: analysis.precipitation.narrative,
                    severity: analysis.precipitation.severity
                )

                IntelligentComparisonRow(
                    icon: analysis.humidity.icon,
                    title: "Humidity",
                    narrative: analysis.humidity.narrative,
                    severity: analysis.humidity.severity
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.12),
                    Color.yellow.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct IntelligentComparisonRow: View {
    let icon: String
    let title: String
    let narrative: String
    let severity: WeatherComparisonAnalyzer.ComparisonSeverity

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(colorForSeverity(severity))
                .frame(width: 20)

            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(narrative)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(colorForSeverity(severity))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }

    private func colorForSeverity(_ severity: WeatherComparisonAnalyzer.ComparisonSeverity) -> Color {
        switch severity {
        case .minimal: return .gray
        case .minor: return .primary
        case .moderate: return .blue
        case .significant: return .orange
        case .extreme: return .red
        }
    }
}

struct ComparisonRow: View {
    let icon: String
    let title: String
    let comparison: ComparisonResult

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Image(systemName: comparison.icon)
                    .foregroundColor(colorForComparison(comparison))
                    .font(.caption)

                Text(comparison.text)
                    .font(.caption)
                    .foregroundColor(colorForComparison(comparison))
            }
        }
        .padding(.vertical, 4)
    }

    private func colorForComparison(_ comparison: ComparisonResult) -> Color {
        switch comparison {
        case .higher: return .red
        case .lower: return .blue
        case .similar: return .gray
        }
    }
}

// MARK: - Supporting Views

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Fetching weather data...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
        )
    }
}

struct ErrorView: View {
    let error: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text("Weather Unavailable")
                .font(.headline)
                .fontWeight(.semibold)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptyStateView: View {
    let loadWeather: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Yesterday Weather")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Compare today's forecast with yesterday's actual weather")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Get Weather") {
                loadWeather()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - 10-Day Forecast View

struct TenDayForecastView: View {
    let forecast: TenDayForecast

    var body: some View {
        VStack(spacing: 16) {
            Text("Next 10 Days")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(forecast.days.enumerated()), id: \.offset) { index, day in
                        DayForecastCard(
                            day: day,
                            isToday: day.isToday
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.mint.opacity(0.15),
                    Color.teal.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct DayForecastCard: View {
    let day: DayForecast
    let isToday: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(isToday ? "Today" : day.dayName)
                .font(.caption)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isToday ? .orange : .primary)

            Image(systemName: day.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(height: 24)

            VStack(spacing: 2) {
                Text("\(Int(day.highTemp))°")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(Int(day.lowTemp))°")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if day.precipitation > 0.1 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(String(format: "%.1f", day.precipitation))\"")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            } else {
                Text(" ")
                    .font(.caption2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(width: 70)
        .background(isToday ? Color.orange.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Quote of the Day View

struct QuoteOfTheDayView: View {
    let quote: WeatherQuote

    var body: some View {
        VStack(spacing: 16) {
            Text("Quote of the Day")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                Text(quote.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)

                Text("— \(quote.attribution) —")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo.opacity(0.12),
                    Color.purple.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}

#Preview("With Data") {
    ContentView()
        .onAppear {
            // Preview with mock data
        }
}
