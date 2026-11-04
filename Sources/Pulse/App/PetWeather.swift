// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import Foundation

struct WeatherCoordinate: Codable, Equatable, Sendable {
    let latitude: Double
    let longitude: Double

    var isValid: Bool {
        latitude.isFinite && longitude.isFinite && (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }

    /// About one kilometre; precise device coordinates never enter a URL.
    var approximate: Self {
        Self(latitude: (latitude * 100).rounded() / 100, longitude: (longitude * 100).rounded() / 100)
    }
}

struct WeatherCity: Codable, Equatable, Identifiable, Sendable {
    let id: Int
    let name: String
    let country: String?
    let admin1: String?
    let latitude: Double
    let longitude: Double

    var coordinate: WeatherCoordinate { .init(latitude: latitude, longitude: longitude) }
    var title: String { [name, admin1, country].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ") }
    var isValid: Bool { id > 0 && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && coordinate.isValid }
}

struct WeatherPreferences: Codable, Equatable {
    enum Source: String, Codable, CaseIterable, Identifiable {
        case automatic, city
        var id: Self { self }
        var title: String {
            switch self {
            case .automatic: .localized("Current location")
            case .city: .localized("Choose a city")
            }
        }
    }

    var enabled = false
    var source: Source = .automatic
    var city: WeatherCity?
    static let key = "settings.weatherPet"

    static func restored(from defaults: UserDefaults) -> Self {
        guard let data = defaults.data(forKey: key),
              let value = try? JSONDecoder().decode(Self.self, from: data),
              value.city?.isValid != false else { return Self() }
        return value
    }
}

struct PetWeatherReading: Equatable, Sendable {
    let code: Int
    let isDay: Bool
    let observedAt: Date

    var pet: OrbPet? { Self.pet(code: code, isDay: isDay) }
    func isStale(at date: Date) -> Bool { date.timeIntervalSince(observedAt) > 3600 || observedAt > date.addingTimeInterval(900) }

    static func pet(code: Int, isDay: Bool) -> OrbPet? {
        switch code {
        case 0: isDay ? .sun : .moon
        case 1, 2: isDay ? .cloudSun : .cloudMoon
        case 3: .cloud
        case 45, 48: .fog
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82: .rain
        case 71, 73, 75, 77, 85, 86: .snow
        case 95, 96, 99: .thunderstorm
        default: nil
        }
    }
}

protocol PetWeatherFetching: Sendable {
    func weather(at coordinate: WeatherCoordinate) async throws -> PetWeatherReading
    func cities(named query: String, language: String) async throws -> [WeatherCity]
}

struct OpenMeteoPetWeather: PetWeatherFetching {
    enum Failure: Error { case invalidInput, invalidResponse, unsupportedWeather }
    static func configuration(for settings: NetworkProxySettings) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.httpCookieStorage = nil
        config.urlCredentialStorage = nil
        config.httpShouldSetCookies = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 20
        return NetworkSession.configured(config, for: settings)
    }
    let session: URLSession?
    var now: @Sendable () -> Date = { Date() }

    init(session: URLSession? = nil, now: @escaping @Sendable () -> Date = { Date() }) {
        self.session = session
        self.now = now
    }

    static func weatherURL(at coordinate: WeatherCoordinate) throws -> URL {
        guard coordinate.isValid else { throw Failure.invalidInput }
        let point = coordinate.approximate
        return try url(host: "api.open-meteo.com", path: "/v1/forecast", items: [
            .init(name: "latitude", value: String(point.latitude)),
            .init(name: "longitude", value: String(point.longitude)),
            .init(name: "current", value: "weather_code,is_day"),
            .init(name: "timeformat", value: "unixtime"),
            .init(name: "forecast_days", value: "1")
        ])
    }

    static func cityURL(query: String, language: String) throws -> URL {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...100).contains(query.count) else { throw Failure.invalidInput }
        let languages = ["en", "zh", "ja", "ko", "ru"]
        let language = language.split(separator: "-").first.map(String.init) ?? "en"
        return try url(host: "geocoding-api.open-meteo.com", path: "/v1/search", items: [
            .init(name: "name", value: query), .init(name: "count", value: "8"),
            .init(name: "language", value: languages.contains(language) ? language : "en"),
            .init(name: "format", value: "json")
        ])
    }

    private static func url(host: String, path: String, items: [URLQueryItem]) throws -> URL {
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = host
        parts.path = path
        parts.queryItems = items
        guard let url = parts.url else { throw Failure.invalidInput }
        return url
    }

    func weather(at coordinate: WeatherCoordinate) async throws -> PetWeatherReading {
        struct Reply: Decodable {
            struct Current: Decodable { let weather_code: Int; let is_day: Int; let time: Double }
            let current: Current
        }
        let data = try await get(Self.weatherURL(at: coordinate))
        let current = try JSONDecoder().decode(Reply.self, from: data).current
        guard current.is_day == 0 || current.is_day == 1,
              current.time.isFinite else { throw Failure.invalidResponse }
        let result = PetWeatherReading(code: current.weather_code, isDay: current.is_day == 1,
                                       observedAt: Date(timeIntervalSince1970: current.time))
        guard result.pet != nil else { throw Failure.unsupportedWeather }
        guard !result.isStale(at: now()) else { throw Failure.invalidResponse }
        return result
    }

    func cities(named query: String, language: String) async throws -> [WeatherCity] {
        struct Reply: Decodable { let results: [WeatherCity]? }
        let data = try await get(Self.cityURL(query: query, language: language))
        let result = try JSONDecoder().decode(Reply.self, from: data)
        return Array((result.results ?? []).filter(\.isValid).prefix(8))
    }

    private func get(_ url: URL) async throws -> Data {
        let session = session ?? URLSession(configuration: Self.configuration(for: NetworkSession.currentSettings),
                                             delegate: PetWeatherRedirectGuard(), delegateQueue: nil)
        defer { if self.session == nil { session.finishTasksAndInvalidate() } }
        let (data, response) = try await session.data(from: url)
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse, response.statusCode == 200,
              response.url?.scheme == "https", response.url?.host == url.host,
              !data.isEmpty, data.count <= 1_000_000 else { throw Failure.invalidResponse }
        return data
    }
}

final class PetWeatherRedirectGuard: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
