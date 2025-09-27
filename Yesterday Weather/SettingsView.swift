//
//  SettingsView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var feedbackSubmitted = false
    @State private var showingAdmin = false

    var body: some View {
        NavigationView {
            Form {
                // Weather Experience Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Get smart suggestions by sharing how the weather affects you:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)

                        ForEach(WeatherExperience.allCases) { experience in
                            WeatherExperienceRow(
                                experience: experience,
                                isEnabled: settingsManager.enabledExperiences.contains(experience)
                            ) {
                                settingsManager.toggleExperience(experience)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Label("How Weather Affects You", systemImage: "person.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                // Preload Settings Section
                Section {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Preload Weather Data")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text("Update weather report before you wake for faster access")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { settingsManager.preloadWeatherEnabled },
                                set: { settingsManager.setPreloadEnabled($0) }
                            ))
                        }

                        if settingsManager.preloadWeatherEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preload Time")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                DatePicker(
                                    "Preload Time",
                                    selection: Binding(
                                        get: { settingsManager.preloadTime },
                                        set: { settingsManager.setPreloadTime($0) }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )

                                Text("Weather data will be loaded at \(settingsManager.preloadTime, formatter: timeFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .transition(.opacity.combined(with: .slide))
                            .animation(.easeInOut, value: settingsManager.preloadWeatherEnabled)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Label("Data Preloading", systemImage: "clock.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                // Give Feedback Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How can we improve Yesterday Weather?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if !feedbackSubmitted {
                            VStack(spacing: 12) {
                                TextField("Enter your feedback...", text: $feedbackText, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...6)

                                HStack {
                                    Spacer()
                                    Button("Submit") {
                                        submitFeedback()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                            }
                        } else {
                            Text("Thanks for your suggestion!")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.warmSuccess)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Label("Feedback", systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2024.09.22")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("About", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                // Admin Section
                Section {
                    Button(action: {
                        showingAdmin = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape.2.fill")
                                .foregroundColor(.warmAccent)
                                .frame(width: 20)

                            Text("Admin Panel")
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("Weather Icons & Settings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Label("Administration", systemImage: "key.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdmin) {
            AdminView()
        }
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private func submitFeedback() {
        // Here you would typically send feedback to your backend
        // For now, we'll just simulate submission
        feedbackSubmitted = true
        feedbackText = ""

        // Reset the success state after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            feedbackSubmitted = false
        }
    }
}

// MARK: - Weather Experience Row

struct WeatherExperienceRow: View {
    let experience: WeatherExperience
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: experience.icon)
                .font(.title2)
                .foregroundColor(isEnabled ? .warmAccent : .warmTextTertiary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(experience.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(experience.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            ))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
}
