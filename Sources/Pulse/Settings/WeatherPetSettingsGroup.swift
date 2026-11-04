// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import SwiftUI

struct WeatherPetSettingsGroup: View {
    @Bindable var settings: AppSettings
    @State private var query = ""

    var body: some View {
        SettingsGroup {
            SettingsRow(String.localized("Automatic weather pet"),
                        subtitle: String.localized("Changes the pet with local weather, including moonlight at night. Updates every 30 minutes.")) {
                Toggle(String.localized("Automatic weather pet"), isOn: $settings.weatherPreferences.enabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(localized: "When enabled, Open-Meteo receives your approximate coordinates or city search, plus your IP address. No account or usage data is sent. Location permission is requested only when you choose Allow location access.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Link(String.localized("Weather data: Open-Meteo (CC BY 4.0)"), destination: URL(string: "https://open-meteo.com/")!)
                    .font(.caption)
                Link(String.localized("City data: GeoNames via Open-Meteo (CC BY 4.0)"), destination: URL(string: "https://www.geonames.org/")!)
                    .font(.caption)
                Link(String.localized("Free weather service: non-commercial use only. Terms and privacy"),
                     destination: URL(string: "https://open-meteo.com/en/terms")!)
                    .font(.caption)
            }
            .padding(12)
            if settings.weatherPreferences.enabled {
                SettingsRowDivider()
                SettingsRow(String.localized("Weather location")) {
                    Picker(String.localized("Weather location"), selection: $settings.weatherPreferences.source) {
                        ForEach(WeatherPreferences.Source.allCases) { source in Text(source.title).tag(source) }
                    }
                    .labelsHidden()
                    .frame(width: SettingsLayout.controlWidth)
                }
                if settings.weatherPreferences.source == .automatic {
                    SettingsRow(String.localized("Current location"),
                                subtitle: String.localized("You can decline location access and search for a city instead.")) {
                        Button(String.localized("Allow location access")) { settings.weatherPet?.requestLocation() }
                            .disabled(settings.weatherPet?.status == .paused)
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    TimelineView(.periodic(from: .now, by: 60)) { _ in
                        let controller = settings.weatherPet
                        let status = controller?.status == .paused ? PetWeatherController.Status.paused :
                            (controller?.isStale == true ? .stale : controller?.status ?? .off)
                        Text(status.title).font(.callout).foregroundStyle(.secondary)
                        if let reading = controller?.reading {
                            HStack(spacing: 6) {
                                Text(reading.pet?.title ?? String.localized("Weather is unavailable. No current reading."))
                                Text(reading.observedAt, format: .dateTime.month().day().hour().minute())
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    if settings.weatherPreferences.source == .city, let city = settings.weatherPreferences.city {
                        Text(city.title).font(.callout).textSelection(.enabled)
                    }
                    HStack {
                        TextField(String.localized("City name"), text: $query)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit(search)
                            .onChange(of: query) { settings.weatherPet?.clearSearch() }
                            .accessibilityLabel(String.localized("City name"))
                        Button(String.localized("Search cities"), action: search)
                            .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 || query.count > 100 || settings.weatherPet?.isSearching == true)
                    }
                    if let controller = settings.weatherPet {
                        if controller.isSearching {
                            ProgressView().controlSize(.small)
                        } else if controller.searchFailed {
                            Text(localized: "Could not search cities. Check your connection and try again.")
                                .font(.caption).foregroundStyle(.secondary)
                        } else if controller.didSearch && controller.results.isEmpty {
                            Text(localized: "No cities found. Try another name.").font(.caption).foregroundStyle(.secondary)
                        }
                        ForEach(controller.results) { city in
                            Button {
                                var preferences = settings.weatherPreferences
                                preferences.source = .city
                                preferences.city = city
                                settings.weatherPreferences = preferences
                            } label: {
                                Text(city.title).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.borderless)
                            .padding(.vertical, 3)
                        }
                    }
                    Text(localized: "Select a search result to use that city instead of device location. Fixed pets and imported PNGs are kept; a PNG takes priority over weather.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(12)
            }
        }
        .onDisappear { settings.weatherPet?.clearSearch() }
    }

    private func search() {
        let language = settings.language.locale.language.languageCode?.identifier ?? "en"
        settings.weatherPet?.search(query, language: language)
    }
}
