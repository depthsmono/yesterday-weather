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
                                    .foregroundColor(.warmAccent)
                            }

                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.warmTextSecondary)
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
                    LazyWeatherComparisonView(
                        comparison: comparison,
                        tenDayForecast: weatherService.tenDayForecast,
                        hourlyForecast: weatherService.todayHourlyForecast,
                        settingsManager: settingsManager,
                        quoteOfTheDay: loadingQuote,
                        weatherService: weatherService
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
            LinearGradient.warmAppBackground
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
            // 🚀 PERFORMANCE: Use progressive loading for faster UX
            await weatherService.fetchWeatherDataProgressively(for: locationManager.currentLocation)
        }
        .onChange(of: locationManager.currentLocation) { oldLocation, newLocation in
            // Refresh weather data when location changes
            Task {
                // 🚀 PERFORMANCE: Use progressive loading for faster location switching
                await weatherService.fetchWeatherDataProgressively(for: newLocation)
            }
        }
    }
}

// MARK: - Lazy Weather Comparison View with Progressive Loading

struct LazyWeatherComparisonView: View {
    let comparison: WeatherComparison
    let tenDayForecast: TenDayForecast?
    let hourlyForecast: HourlyForecastData?
    let settingsManager: SettingsManager
    let quoteOfTheDay: WeatherQuote
    let weatherService: WeatherService

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Phase 1: Weather headline with narrative and hourly forecast
                ComparisonHeaderView(comparison: comparison, settingsManager: settingsManager, hourlyForecast: hourlyForecast)

                // Phase 2: Side-by-side comparison loads next
                HStack(alignment: .top, spacing: 16) {
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

                // Phase 3: "How does today compare" section
                ComparisonDetailsView(comparison: comparison, settingsManager: settingsManager)

                // Phase 4: Additional sections can be added here if needed

                // Phase 5: 10-Day forecast (if available)
                if let forecast = tenDayForecast {
                    TenDayForecastView(forecast: forecast)
                } else if weatherService.isLoadingForecast {
                    LoadingForecastView()
                }

                // Phase 6: Quote of the Day
                QuoteOfTheDayView(quote: quoteOfTheDay)
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Weather Comparison View (Legacy)

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
                HStack(alignment: .top, spacing: 16) {
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
                WeatherIconView(weatherCode: comparison.today.weatherCode, isDay: true, size: 40)
                    .foregroundColor(.weatherSun)

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

                    // Removed duplicate advice - narrative is sufficient
                }
            }

            // Hourly Forecast
            if let hourlyForecast = hourlyForecast {
                Divider()
                    .background(Color.warmTextTertiary.opacity(0.4))

                HourlyForecastView(hourlyForecast: hourlyForecast)
                    .onAppear {
                        print("ComparisonHeaderView: Showing HourlyForecastView with \(hourlyForecast.hours.count) hours")
                    }
            } else {
                Text("Debug: No hourly forecast data")
                    .font(.caption)
                    .foregroundColor(.warmError)
                    .onAppear {
                        print("ComparisonHeaderView: hourlyForecast is nil")
                    }
            }
        }
        .padding()
        .background(LinearGradient.warmHeader)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.warmAccent.opacity(0.2), lineWidth: 1)
        )
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

            WeatherIconView(weatherCode: weather.weatherCode, isDay: true, size: 30)
                .foregroundColor(isPrimary ? .warmAccent : .warmSecondary)

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
                        .foregroundColor(.weatherRain)
                        .font(.caption)
                    Text("\(String(format: "%.1f", weather.precipitation))\"")
                        .font(.caption)
                }

                HStack {
                    Image(systemName: "humidity.fill")
                        .foregroundColor(.warmSuccess)
                        .font(.caption)
                    Text("\(weather.humidity)%")
                        .font(.caption)
                }

                HStack {
                    Image(systemName: "wind")
                        .foregroundColor(.weatherNeutral)
                        .font(.caption)
                    Text("\(String(format: "%.0f", weather.windSpeed)) mph")
                        .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(isPrimary ? Color.warmAccent.opacity(0.1) : Color.warmSecondary.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPrimary ? Color.warmAccent.opacity(0.3) : Color.warmSecondary.opacity(0.3), lineWidth: 1)
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
        .background(LinearGradient.warmCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.warmTextTertiary.opacity(0.2), lineWidth: 1)
        )
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
            LinearGradient.warmAppBackground
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
                .foregroundColor(.warmError)

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
                .foregroundColor(.warmAccent)

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
        .background(LinearGradient.warmForecast)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.warmTextTertiary.opacity(0.2), lineWidth: 1)
        )
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
                .foregroundColor(isToday ? .warmEmphasis : .warmTextPrimary)

            WeatherIconView(weatherCode: weatherCodeForDay(day), isDay: true, size: 24)
                .foregroundColor(.weatherSun)
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
                        .foregroundColor(.weatherRain)
                }
            } else {
                Text(" ")
                    .font(.caption2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(width: 70)
        .background(isToday ? Color.warmEmphasis.opacity(0.12) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.warmEmphasis.opacity(0.4) : Color.clear, lineWidth: 1)
        )
    }

    private func weatherCodeForDay(_ day: DayForecast) -> Int {
        // Simple weather code mapping based on precipitation
        if day.precipitation > 0.2 {
            return 63 // Moderate rain
        } else if day.precipitationProbability > 50 {
            return 61 // Slight rain
        } else if day.precipitationProbability > 20 {
            return 2 // Partly cloudy
        } else {
            return 0 // Clear sky
        }
    }
}

// MARK: - Quote of the Day View

struct QuoteOfTheDayView: View {
    let quote: WeatherQuote

    private var lines: [String] {
        quote.text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private var hasLineBreaks: Bool {
        quote.text.contains("\n")
    }

    private func uniformFontSize(for maxWidth: CGFloat) -> CGFloat {
        // Calculate the maximum font size that will fit ALL lines within the target width
        // without any individual line needing to scale down

        if hasLineBreaks {
            // For poetry: find the longest line and calculate font size based on that
            let longestLineLength = lines.map { $0.count }.max() ?? 1

            // Estimate character width more accurately for different font sizes
            // We'll iteratively find the largest size that fits
            let targetWidth = maxWidth * 0.9 // Use 90% of available width for padding

            // Start with a reasonable font size and work backwards
            var fontSize: CGFloat = 20 // Smaller max for homepage
            let minFontSize: CGFloat = 12 // Minimum readable size

            while fontSize >= minFontSize {
                // Estimate width needed for longest line at this font size
                let estimatedCharWidth = fontSize * 0.55
                let estimatedWidth = CGFloat(longestLineLength) * estimatedCharWidth

                if estimatedWidth <= targetWidth {
                    // This size fits - use it
                    return fontSize
                }

                fontSize -= 1
            }

            return minFontSize
        } else {
            // For prose: simpler calculation
            let charCount = quote.text.count
            let targetWidth = maxWidth * 0.9
            let estimatedCharWidth: CGFloat = 12
            let calculatedSize = targetWidth / (CGFloat(charCount) * estimatedCharWidth / 20)
            return max(12, min(18, calculatedSize))
        }
    }

    var body: some View {
        GeometryReader { geometry in
            // Center the entire quote + attribution block within the card
            VStack {
                Spacer() // Top spacer to center vertically

                HStack {
                    Spacer() // Left spacer to center horizontally

                    VStack(spacing: 20) {
                        // Quote text with dynamic scaling
                        if hasLineBreaks {
                            // Poetry: Display each line separately to prevent auto-wrapping
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                    Text(line)
                                        .font(.system(size: uniformFontSize(for: geometry.size.width)))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        .minimumScaleFactor(1.0) // No scaling - use calculated uniform size
                                        .lineLimit(1)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .frame(maxWidth: geometry.size.width * 0.85, alignment: .leading)
                        } else {
                            // Prose: Normal text display
                            Text(quote.text)
                                .font(.system(size: uniformFontSize(for: geometry.size.width)))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: geometry.size.width * 0.85, alignment: .leading)
                        }

                        // Attribution - right aligned to the full frame width (matching loading screen)
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(quote.author)
                                .font(.system(size: uniformFontSize(for: geometry.size.width) * 0.6)) // 40% smaller
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .multilineTextAlignment(.trailing)

                            Text(quote.work)
                                .font(.system(size: uniformFontSize(for: geometry.size.width) * 0.6)) // 40% smaller
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(maxWidth: geometry.size.width * 0.85, alignment: .trailing) // Right align to frame edge
                    }

                    Spacer() // Right spacer to center horizontally
                }
                .frame(maxWidth: geometry.size.width * 0.85) // Overall content constraint

                Spacer() // Bottom spacer to center vertically
            }
        }
        .padding()
        .background(LinearGradient.warmQuote)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.warmTextTertiary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .frame(minHeight: 180) // Minimum height for consistency
    }
}

// MARK: - Progressive Loading Components

struct WeatherHeadlineView: View {
    let comparison: WeatherComparison

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                WeatherIconView(weatherCode: comparison.today.weatherCode, isDay: true, size: 40)
                    .foregroundColor(.weatherSun)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(String(format: "%.0f", comparison.today.temperature))°F")
                        .font(.system(size: 36, weight: .bold))

                    Text(comparison.today.description)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    let tempDiff = comparison.temperatureDifference
                    let diffText = tempDiff > 0 ? "+\(String(format: "%.1f", tempDiff))°" : "\(String(format: "%.1f", tempDiff))°"
                    Text(diffText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(tempDiff > 0 ? .red : tempDiff < 0 ? .blue : .gray)

                    Text("vs yesterday")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(LinearGradient.warmHeader)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.warmAccent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}


struct LoadingForecastView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Next 10 Days")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<10) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 70, height: 120)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(LinearGradient.warmForecast)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.warmTextTertiary.opacity(0.2), lineWidth: 1)
        )
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
