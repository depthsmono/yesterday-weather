//
//  LocationsView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import SwiftUI

struct LocationsView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                VStack(spacing: 16) {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Search for a location...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onSubmit {
                                    Task {
                                        await locationManager.searchLocations(query: searchText)
                                    }
                                }

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    locationManager.searchResults = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                        Button("Search") {
                            Task {
                                await locationManager.searchLocations(query: searchText)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(searchText.isEmpty)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.3))

                ScrollView {
                    VStack(spacing: 16) {
                        // Search results
                        if !locationManager.searchResults.isEmpty {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Search Results")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(.horizontal)

                                ForEach(locationManager.searchResults) { result in
                                    SearchResultCard(result: result) {
                                        let newLocation = result.toWeatherLocation()
                                        locationManager.addLocation(newLocation)
                                        locationManager.setCurrentLocation(newLocation)
                                        searchText = ""
                                        locationManager.searchResults = []
                                        dismiss()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top)
                        }

                        // Current/Default location
                        VStack(spacing: 12) {
                            HStack {
                                Text("Your Locations")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Current location card
                            LocationCard(
                                location: locationManager.currentLocation,
                                isCurrent: true,
                                onSelect: {
                                    dismiss()
                                },
                                onDelete: nil
                            )
                            .padding(.horizontal)

                            // Other saved locations
                            ForEach(locationManager.locations.filter { $0.id != locationManager.currentLocation.id }) { location in
                                LocationCard(
                                    location: location,
                                    isCurrent: false,
                                    onSelect: {
                                        locationManager.setCurrentLocation(location)
                                        dismiss()
                                    },
                                    onDelete: {
                                        locationManager.removeLocation(location)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, locationManager.searchResults.isEmpty ? 20 : 0)
                    }
                }

                if locationManager.isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Locations")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Location Card

struct LocationCard: View {
    let location: WeatherLocation
    let isCurrent: Bool
    let onSelect: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(location.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if isCurrent {
                            Text("Current")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }

                        Spacer()
                    }

                    Text("Lat: \(String(format: "%.4f", location.latitude)), Lon: \(String(format: "%.4f", location.longitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let onDelete = onDelete, !isCurrent {
                    Button(action: {
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(isCurrent ? Color.blue.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrent ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let result: LocationSearchResult
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("Lat: \(String(format: "%.4f", result.latitude)), Lon: \(String(format: "%.4f", result.longitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LocationsView()
}