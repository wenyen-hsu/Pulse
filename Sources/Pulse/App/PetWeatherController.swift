// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import Foundation
import Observation

@MainActor @Observable
final class PetWeatherController {
    enum Status {
        case off, paused, needsPermission, denied, locating, locationUnavailable, noCity, loading, ready, stale, unavailable
        var title: String {
            switch self {
            case .off: .localized("Automatic weather is off.")
            case .paused: .localized("Weather is paused while a custom image or the classic rail is in use, or the panel is hidden.")
            case .needsPermission: .localized("Allow location access, or choose a city below.")
            case .denied: .localized("Location access is denied. Choose a city, or allow Nokori in System Settings → Privacy & Security → Location Services.")
            case .locating: .localized("Finding your approximate location…")
            case .locationUnavailable: .localized("Location is unavailable. Choose a city instead.")
            case .noCity: .localized("Search for and select a city to get its weather.")
            case .loading: .localized("Updating weather…")
            case .ready: .localized("Weather is up to date.")
            case .stale: .localized("Weather is out of date. Showing the last reading.")
            case .unavailable: .localized("Weather is unavailable. No current reading.")
            }
        }
    }

    private(set) var status: Status = .off
    private(set) var reading: PetWeatherReading?
    private(set) var results: [WeatherCity] = []
    private(set) var isSearching = false
    private(set) var searchFailed = false
    private(set) var didSearch = false
    @ObservationIgnored private let client: any PetWeatherFetching
    @ObservationIgnored private let location: any PetLocationProviding
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var preferences = WeatherPreferences()
    @ObservationIgnored private var active = false
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var searchGeneration = 0
    @ObservationIgnored private var lastAttempt: Date?
    @ObservationIgnored private var readingLocation: WeatherCoordinate?
    @ObservationIgnored private var fetchTask: Task<Void, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var loop: Task<Void, Never>?
    @ObservationIgnored private var locationTimeout: Task<Void, Never>?

    init(client: any PetWeatherFetching = OpenMeteoPetWeather(), location: (any PetLocationProviding)? = nil,
         now: @escaping () -> Date = { Date() }) {
        self.client = client
        self.location = location ?? PetWeatherLocation()
        self.now = now
        self.location.onEvent = { [weak self] in self?.locationChanged($0) }
    }

    var isStale: Bool { reading != nil && (status == .stale || reading?.isStale(at: now()) == true) }

    func apply(_ preferences: WeatherPreferences, visible: Bool) {
        let active = preferences.enabled && visible
        guard self.preferences != preferences || self.active != active else { return }
        if self.preferences.source != preferences.source ||
            (preferences.source == .city && self.preferences.city != preferences.city) {
            reading = nil
            readingLocation = nil
        }
        stop()
        self.preferences = preferences
        self.active = active
        lastAttempt = nil
        guard active else {
            status = preferences.enabled ? .paused : .off
            return
        }
        refresh()
        loop = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(1800)) } catch { return }
                guard let self else { return }
                self.refresh()
            }
        }
    }

    func stop() {
        active = false
        generation += 1
        fetchTask?.cancel()
        fetchTask = nil
        loop?.cancel()
        loop = nil
        locationTimeout?.cancel()
        locationTimeout = nil
        location.stop()
        clearSearch()
    }

    func requestLocation() {
        guard active, preferences.source == .automatic else { return }
        if let lastAttempt, now().timeIntervalSince(lastAttempt) < 60 { return }
        location.start(requestPermission: true)
    }

    func refresh() {
        guard active, fetchTask == nil else { return }
        // A refresh button or repeated location callbacks must not hammer the public API.
        if let lastAttempt, now().timeIntervalSince(lastAttempt) < 60 { return }
        switch preferences.source {
        case .automatic:
            location.start(requestPermission: false)
        case .city:
            guard let city = preferences.city, city.isValid else { status = .noCity; return }
            fetch(at: city.coordinate)
        }
    }

    private func locationChanged(_ event: PetLocationEvent) {
        guard active, preferences.source == .automatic else { return }
        locationTimeout?.cancel()
        switch event {
        case .needsPermission: fail(.needsPermission)
        case .denied: fail(.denied)
        case .unavailable: fail(.locationUnavailable)
        case .locating:
            status = .locating
            locationTimeout = Task { [weak self] in
                do { try await Task.sleep(for: .seconds(20)) } catch { return }
                self?.location.stop()
                self?.fail(.locationUnavailable)
            }
        case .coordinate(let coordinate):
            guard coordinate.isValid else { fail(.locationUnavailable); return }
            fetch(at: coordinate)
        }
    }

    private func fetch(at coordinate: WeatherCoordinate) {
        guard fetchTask == nil else { return }
        if let lastAttempt, now().timeIntervalSince(lastAttempt) < 60 { return }
        let coordinate = coordinate.approximate
        if let previous = readingLocation, previous != coordinate { reading = nil }
        lastAttempt = now()
        status = .loading
        let generation = generation
        fetchTask = Task { [weak self, client] in
            do {
                let reading = try await client.weather(at: coordinate)
                guard let self, self.generation == generation, self.active, !Task.isCancelled else { return }
                guard reading.pet != nil, !reading.isStale(at: self.now()) else {
                    self.fail(.unavailable)
                    self.fetchTask = nil
                    return
                }
                self.reading = reading
                self.readingLocation = coordinate
                self.status = .ready
                self.fetchTask = nil
            } catch {
                guard let self, self.generation == generation, self.active, !Task.isCancelled else { return }
                self.fail(.unavailable)
                self.fetchTask = nil
            }
        }
    }

    private func fail(_ status: Status) { self.status = reading == nil ? status : .stale }

    func search(_ query: String, language: String) {
        clearSearch()
        guard active, (2...100).contains(query.trimmingCharacters(in: .whitespacesAndNewlines).count) else { return }
        isSearching = true
        didSearch = true
        let generation = searchGeneration
        searchTask = Task { [weak self, client] in
            do {
                let cities = try await client.cities(named: query, language: language)
                guard let self, self.searchGeneration == generation, !Task.isCancelled else { return }
                self.results = cities
                self.isSearching = false
            } catch {
                guard let self, self.searchGeneration == generation, !Task.isCancelled else { return }
                self.searchFailed = true
                self.isSearching = false
            }
        }
    }

    func clearSearch() {
        searchGeneration += 1
        searchTask?.cancel()
        searchTask = nil
        results = []
        isSearching = false
        searchFailed = false
        didSearch = false
    }
}
