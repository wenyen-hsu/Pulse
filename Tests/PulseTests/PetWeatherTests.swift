// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import Foundation
import Testing
@testable import Pulse

private let weatherTestDate = Date(timeIntervalSince1970: 1_790_000_000)
private let weatherTestCity = WeatherCity(id: 1, name: "Taipei", country: "Taiwan", admin1: nil, latitude: 25.033, longitude: 121.5654)

@Suite("Weather pet mapping and persistence")
struct PetWeatherTests {
    @Test("All documented WMO codes map explicitly; day/night changes only clear and partly cloudy skies")
    func mapping() {
        let groups: [(OrbPet, [Int])] = [(.cloud, [3]), (.fog, [45, 48]),
            (.rain, [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]),
            (.snow, [71, 73, 75, 77, 85, 86]), (.thunderstorm, [95, 96, 99])]
        for (pet, codes) in groups {
            for code in codes {
                #expect(PetWeatherReading.pet(code: code, isDay: true) == pet)
                #expect(PetWeatherReading.pet(code: code, isDay: false) == pet)
            }
        }
        #expect(PetWeatherReading.pet(code: 0, isDay: true) == .sun)
        #expect(PetWeatherReading.pet(code: 0, isDay: false) == .moon)
        for code in [1, 2] {
            #expect(PetWeatherReading.pet(code: code, isDay: true) == .cloudSun)
            #expect(PetWeatherReading.pet(code: code, isDay: false) == .cloudMoon)
        }
        for code in [-1, 4, 50, 60, 70, 90, 100, Int.max] {
            #expect(PetWeatherReading.pet(code: code, isDay: true) == nil)
        }
    }

    @Test("Automatic weather defaults off, preserves manual pets and uses a dedicated callback")
    @MainActor func settings() throws {
        let (defaults, cleanup) = TestDefaults.make("WeatherPets")
        defer { cleanup() }
        let settings = AppSettings(defaults: defaults)
        var refreshes = 0
        var layouts = 0
        var weather = 0
        settings.onChange = { refreshes += 1 }
        settings.onLayoutChange = { layouts += 1 }
        settings.onWeatherChange = { weather += 1 }
        #expect(!settings.weatherPreferences.enabled)
        settings.orbPet = .fox
        settings.orbPetImage = Data([1, 2, 3])
        layouts = 0
        settings.weatherPreferences = WeatherPreferences(enabled: true, source: .city, city: weatherTestCity)
        let same = settings.weatherPreferences
        settings.weatherPreferences = same
        #expect(weather == 1 && refreshes == 0 && layouts == 0)
        let restored = AppSettings.restoredSettings(from: defaults, detected: [], scan: ExtensionCatalog.Scan())
        #expect(restored.weatherPreferences == settings.weatherPreferences)
        #expect(restored.orbPet == .fox && restored.orbPetImage == settings.orbPetImage)
        let invalid = WeatherCity(id: 1, name: "Bad", country: nil, admin1: nil, latitude: 200, longitude: 10)
        defaults.set(try JSONEncoder().encode(WeatherPreferences(enabled: true, source: .city, city: invalid)), forKey: WeatherPreferences.key)
        #expect(!WeatherPreferences.restored(from: defaults).enabled)
        defaults.set(Data("not json".utf8), forKey: WeatherPreferences.key)
        #expect(!WeatherPreferences.restored(from: defaults).enabled)
    }

    @Test("Automatic weather locks fixed-pet controls and restores saved choices when turned off", arguments: [false, true])
    @MainActor func exclusiveSelection(hasImage: Bool) {
        let (defaults, cleanup) = TestDefaults.make("ExclusiveWeatherPet")
        defer { cleanup() }
        let settings = AppSettings(defaults: defaults)
        let image = hasImage ? Data([1, 2, 3]) : nil
        settings.orbPet = .rabbit
        settings.orbPetImage = image
        settings.orbPetSize = 1.2
        #expect(settings.isFixedPetSelectionEnabled && settings.effectivePetImage == image)

        settings.weatherPreferences.enabled = true
        #expect(!settings.isFixedPetSelectionEnabled && settings.effectivePetImage == nil)
        #expect(settings.orbPet == .rabbit && settings.orbPetImage == image && settings.orbPetSize == 1.2)
        let restored = AppSettings.restoredSettings(from: defaults, detected: [], scan: ExtensionCatalog.Scan())
        #expect(!restored.isFixedPetSelectionEnabled && restored.effectivePetImage == nil)
        #expect(restored.orbPet == .rabbit && restored.orbPetImage == image && restored.orbPetSize == 1.2)

        restored.weatherPreferences.enabled = false
        #expect(restored.isFixedPetSelectionEnabled && restored.effectivePetImage == image)
        let fixed = AppSettings.restoredSettings(from: defaults, detected: [], scan: ExtensionCatalog.Scan())
        #expect(fixed.isFixedPetSelectionEnabled && fixed.effectivePetImage == image)
        #expect(fixed.orbPet == .rabbit && fixed.orbPetImage == image && fixed.orbPetSize == 1.2)
    }

    @Test("Coordinates are validated and rounded before network use; city queries are encoded")
    func urls() throws {
        let url = try OpenMeteoPetWeather.weatherURL(at: weatherTestCity.coordinate)
        let parts = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = Dictionary(uniqueKeysWithValues: (parts.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        #expect(parts.scheme == "https" && parts.host == "api.open-meteo.com")
        #expect(items["latitude"] == "25.03" && items["longitude"] == "121.57")
        #expect(items["current"] == "weather_code,is_day")
        #expect(items["timeformat"] == "unixtime")
        for point in [WeatherCoordinate(latitude: .nan, longitude: 0), .init(latitude: 91, longitude: 0),
                      .init(latitude: 0, longitude: 181), .init(latitude: 0, longitude: .infinity)] {
            #expect(throws: OpenMeteoPetWeather.Failure.self) { try OpenMeteoPetWeather.weatherURL(at: point) }
        }
        let cityURL = try OpenMeteoPetWeather.cityURL(query: "  台北 & Osaka  ", language: "zh-Hant")
        let cityItems = try #require(URLComponents(url: cityURL, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(cityItems.first { $0.name == "name" }?.value == "台北 & Osaka")
        #expect(cityItems.first { $0.name == "language" }?.value == "zh")
        #expect(throws: OpenMeteoPetWeather.Failure.self) { try OpenMeteoPetWeather.cityURL(query: "x", language: "en") }
    }

    @Test("Hidden and Reduced Motion weather animation is completely still")
    func motion() {
        let still = WeatherPetPose(time: 0, isAnimated: false)
        for time in [0.0, 0.8, 5, 1000] {
            let pose = WeatherPetPose(time: time, isAnimated: false)
            #expect(pose.bob == still.bob && pose.fall == still.fall && pose.glow == still.glow)
        }
        let moving = WeatherPetPose(time: 0.8, isAnimated: true)
        #expect(moving.bob != still.bob && moving.fall != still.fall && moving.glow != still.glow)
    }

    @Test("Credentialless weather and geocoding sessions honour every proxy mode and refuse redirects")
    func proxyConfiguration() {
        let modes: [NetworkProxySettings] = [.default,
            .init(mode: .direct, kind: .http, host: "", port: nil),
            .init(mode: .systemRequired, kind: .http, host: "", port: nil),
            .init(mode: .manual, kind: .http, host: "127.0.0.1", port: 8888),
            .init(mode: .manual, kind: .socks5, host: "127.0.0.1", port: 1080)]
        for mode in modes {
            let config = OpenMeteoPetWeather.configuration(for: mode)
            #expect(config.protocolClasses?.first == ProxyGuard.self)
            #expect(config.httpCookieStorage == nil && config.urlCredentialStorage == nil && !config.httpShouldSetCookies)
            #expect(config.timeoutIntervalForRequest == 15 && config.timeoutIntervalForResource == 20)
            if mode.mode == .manual { #expect(config.proxyConfigurations.count == 1) }
            if mode.mode == .direct { #expect(config.connectionProxyDictionary?.isEmpty == true) }
        }
        let session = URLSession(configuration: .ephemeral)
        defer { session.invalidateAndCancel() }
        let url = URL(string: "https://api.open-meteo.com/v1/forecast")!
        let task = session.dataTask(with: url)
        let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)!
        PetWeatherRedirectGuard().urlSession(session, task: task, willPerformHTTPRedirection: response,
                                            newRequest: URLRequest(url: URL(string: "https://example.com/")!)) { request in
            #expect(request == nil)
        }
    }
}

private final class PetWeatherStub: URLProtocol, @unchecked Sendable {
    final class State: @unchecked Sendable {
        let lock = NSLock()
        var json = "{}"
        var status = 200
        func set(_ json: String, status: Int = 200) { lock.withLock { self.json = json; self.status = status } }
    }
    static let state = State()
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let (json, status) = Self.state.lock.withLock { (Self.state.json, Self.state.status) }
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(json.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@Suite("Weather HTTP decoding", .serialized)
struct PetWeatherHTTPTests {
    private func client() -> OpenMeteoPetWeather {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [PetWeatherStub.self]
        return OpenMeteoPetWeather(session: URLSession(configuration: config), now: { weatherTestDate })
    }

    @Test("Current conditions require code, valid day/night, a fresh timestamp and HTTP success")
    func decoding() async throws {
        let client = client()
        let time = weatherTestDate.timeIntervalSince1970
        for (code, day, expected) in [(0, 0, OrbPet.moon), (2, 1, .cloudSun), (61, 1, .rain), (95, 0, .thunderstorm)] {
            PetWeatherStub.state.set("{\"current\":{\"weather_code\":\(code),\"is_day\":\(day),\"time\":\(time)}}")
            #expect(try await client.weather(at: weatherTestCity.coordinate).pet == expected)
        }
        for json in ["{}", "{\"current\":null}", "{\"current\":{\"weather_code\":0,\"time\":\(time)}}",
                     "{\"current\":{\"weather_code\":0,\"is_day\":3,\"time\":\(time)}}",
                     "{\"current\":{\"weather_code\":999,\"is_day\":1,\"time\":\(time)}}",
                     "{\"current\":{\"weather_code\":0,\"is_day\":1,\"time\":0}}",
                     "{\"current\":{\"weather_code\":0,\"is_day\":1,\"time\":\(time + 10000)}}", "not json"] {
            PetWeatherStub.state.set(json)
            await #expect(throws: (any Error).self) { try await client.weather(at: weatherTestCity.coordinate) }
        }
        PetWeatherStub.state.set("{}", status: 429)
        await #expect(throws: OpenMeteoPetWeather.Failure.self) { try await client.weather(at: weatherTestCity.coordinate) }
        for (body, status) in [("", 200), (String(repeating: "x", count: 1_000_001), 200), ("{}", 302)] {
            PetWeatherStub.state.set(body, status: status)
            await #expect(throws: OpenMeteoPetWeather.Failure.self) { try await client.weather(at: weatherTestCity.coordinate) }
        }
    }

    @Test("City results include regions and countries, filter invalid coordinates, and distinguish no matches from failure")
    func cities() async throws {
        let client = client()
        PetWeatherStub.state.set("{\"results\":[{\"id\":1,\"name\":\"Taipei\",\"latitude\":25.033,\"longitude\":121.5654,\"country\":\"Taiwan\"},{\"id\":2,\"name\":\"Bad\",\"latitude\":999,\"longitude\":0}]}")
        let cities = try await client.cities(named: "Taipei", language: "en")
        #expect(cities == [weatherTestCity])
        #expect(cities.first?.title == "Taipei, Taiwan")
        PetWeatherStub.state.set("{}")
        #expect(try await client.cities(named: "No match", language: "en").isEmpty)
        PetWeatherStub.state.set("invalid")
        await #expect(throws: (any Error).self) { try await client.cities(named: "Taipei", language: "en") }
    }
}

private actor WeatherTestClient: PetWeatherFetching {
    enum Failure: Error { case offline }
    var calls: [WeatherCoordinate] = []
    var searches = 0
    var fails = false
    var holds = false
    var pending: CheckedContinuation<PetWeatherReading, any Error>?
    func configure(fails: Bool = false, holds: Bool = false) { self.fails = fails; self.holds = holds }
    func weather(at coordinate: WeatherCoordinate) async throws -> PetWeatherReading {
        calls.append(coordinate)
        if holds { return try await withCheckedThrowingContinuation { pending = $0 } }
        if fails { throw Failure.offline }
        return PetWeatherReading(code: 61, isDay: true, observedAt: weatherTestDate)
    }
    func finish() {
        pending?.resume(returning: PetWeatherReading(code: 95, isDay: false, observedAt: weatherTestDate))
        pending = nil
    }
    func cities(named query: String, language: String) async throws -> [WeatherCity] {
        searches += 1
        if fails { throw Failure.offline }
        return [weatherTestCity]
    }
}

@MainActor private final class WeatherTestLocation: PetLocationProviding {
    var onEvent: ((PetLocationEvent) -> Void)?
    var requests: [Bool] = []
    var stopped = 0
    func start(requestPermission: Bool) { requests.append(requestPermission); onEvent?(.needsPermission) }
    func stop() { stopped += 1 }
}

@Suite("Weather coordinator consent, cancellation and fallback") @MainActor
struct PetWeatherControllerTests {
    private func eventually(_ predicate: () async -> Bool) async {
        for _ in 0..<100 {
            if await predicate() { return }
            try? await Task.sleep(for: .milliseconds(5))
        }
        #expect(await predicate())
    }

    @Test("Saved PNGs do not pause weather; hidden panels and Classic rail still do")
    func imageAndVisibility() async {
        let (defaults, cleanup) = TestDefaults.make("WeatherImageVisibility")
        defer { cleanup() }
        let settings = AppSettings(defaults: defaults)
        let client = WeatherTestClient()
        let store = PetWeatherController(client: client, location: WeatherTestLocation(), now: { weatherTestDate })
        defer { store.stop() }
        settings.orbPetImage = Data([1, 2, 3])
        settings.weatherPreferences = WeatherPreferences(enabled: true, source: .city, city: weatherTestCity)
        for presentation in PanelPresentation.allCases {
            settings.panelPresentation = presentation
            for visible in [false, true] {
                settings.isPanelVisible = visible
                let expectedVisible = visible && presentation.usesOrb
                #expect(settings.isPetOrbVisible == expectedVisible)
                store.apply(settings.weatherPreferences, visible: settings.isPetOrbVisible)
                if expectedVisible {
                    await eventually { store.status == .ready }
                    #expect(store.reading?.pet == .rain)
                } else {
                    #expect(store.status == .paused)
                }
            }
        }
        #expect(await client.calls.count == 2)
        settings.weatherPreferences.enabled = false
        store.apply(settings.weatherPreferences, visible: settings.isPetOrbVisible)
        #expect(store.status == .off && settings.effectivePetImage == settings.orbPetImage)
    }

    @Test("Off never locates, fetches or searches; paused presentation permits explicit city setup without a weather request")
    func off() async {
        let client = WeatherTestClient()
        let location = WeatherTestLocation()
        let store = PetWeatherController(client: client, location: location, now: { weatherTestDate })
        defer { store.stop() }
        store.apply(WeatherPreferences(), visible: true)
        store.requestLocation()
        store.refresh()
        store.search("Taipei", language: "en")
        #expect(await client.searches == 0)
        store.apply(WeatherPreferences(enabled: true, source: .automatic), visible: false)
        store.requestLocation()
        store.refresh()
        store.search("Taipei", language: "en")
        await eventually { !store.isSearching }
        #expect(location.requests.isEmpty)
        let calls = await client.calls
        let searches = await client.searches
        #expect(calls.isEmpty && searches == 1 && store.results == [weatherTestCity])
        #expect(store.status == .paused)
    }

    @Test("Enabling checks existing permission; only an explicit button requests authorization; denial allows city fallback")
    func permission() async {
        let client = WeatherTestClient()
        let location = WeatherTestLocation()
        let store = PetWeatherController(client: client, location: location, now: { weatherTestDate })
        defer { store.stop() }
        store.apply(WeatherPreferences(enabled: true), visible: true)
        #expect(location.requests == [false] && store.status == .needsPermission)
        #expect(await client.calls.isEmpty)
        store.requestLocation()
        #expect(location.requests == [false, true])
        location.onEvent?(.denied)
        #expect(store.status == .denied && store.reading == nil)
        store.search("Taipei", language: "zh")
        await eventually { !store.isSearching }
        #expect(store.results == [weatherTestCity])
        store.apply(WeatherPreferences(enabled: true, source: .city, city: weatherTestCity), visible: true)
        await eventually { store.status == .ready }
        #expect(store.reading?.pet == .rain)
        #expect(location.stopped > 0)
        #expect(await client.calls == [weatherTestCity.coordinate.approximate])
    }

    @Test("Authorized locations are coarsened, repeated callbacks and refresh clicks are throttled")
    func authorized() async {
        let client = WeatherTestClient()
        let location = WeatherTestLocation()
        let store = PetWeatherController(client: client, location: location, now: { weatherTestDate })
        defer { store.stop() }
        store.apply(WeatherPreferences(enabled: true), visible: true)
        location.onEvent?(.coordinate(weatherTestCity.coordinate))
        await eventually { store.status == .ready }
        store.refresh()
        location.onEvent?(.coordinate(weatherTestCity.coordinate))
        #expect(await client.calls == [weatherTestCity.coordinate.approximate])
    }

    @Test("No reading is not sunshine; failed refreshes keep the last actual reading and mark it stale")
    func stale() async {
        let client = WeatherTestClient()
        var now = weatherTestDate
        let store = PetWeatherController(client: client, location: WeatherTestLocation(), now: { now })
        defer { store.stop() }
        let prefs = WeatherPreferences(enabled: true, source: .city, city: weatherTestCity)
        await client.configure(fails: true)
        store.apply(prefs, visible: true)
        await eventually { store.status == .unavailable }
        #expect(store.reading == nil)
        await client.configure()
        now = now.addingTimeInterval(61)
        store.refresh()
        await eventually { store.status == .ready }
        let saved = store.reading
        await client.configure(fails: true)
        now = now.addingTimeInterval(61)
        store.refresh()
        await eventually { store.status == .stale }
        #expect(store.reading == saved && store.isStale)
        #expect(saved?.isStale(at: weatherTestDate.addingTimeInterval(3601)) == true)
    }

    @Test("Manual city refresh respects cooldown, single flight and paused state")
    func manualRefresh() async {
        let client = WeatherTestClient()
        var now = weatherTestDate
        let store = PetWeatherController(client: client, location: WeatherTestLocation(), now: { now })
        defer { store.stop() }
        let prefs = WeatherPreferences(enabled: true, source: .city, city: weatherTestCity)
        store.apply(prefs, visible: true)
        await eventually { store.status == .ready }
        #expect(!store.canRefresh)
        now = now.addingTimeInterval(59)
        store.refresh()
        #expect(await client.calls.count == 1)
        now = now.addingTimeInterval(1)
        #expect(store.canRefresh)
        await client.configure(holds: true)
        store.refresh()
        store.refresh()
        await eventually { await client.pending != nil }
        #expect(store.isRefreshing && !store.canRefresh)
        #expect(await client.calls.count == 2)
        await client.finish()
        await eventually { store.status == .ready }
        store.apply(prefs, visible: false)
        now = now.addingTimeInterval(60)
        #expect(!store.canRefresh)
        store.refresh()
        #expect(store.status == .paused)
        #expect(await client.calls.count == 2)
    }

    @Test("Manual retry retains a failed reading's clock until fresh success")
    func retryKeepsClock() async {
        let client = WeatherTestClient()
        var now = weatherTestDate
        let store = PetWeatherController(client: client, location: WeatherTestLocation(), now: { now })
        defer { store.stop() }
        store.apply(WeatherPreferences(enabled: true, source: .city, city: weatherTestCity), visible: true)
        await eventually { store.status == .ready }
        let saved = store.reading
        now = now.addingTimeInterval(60)
        await client.configure(fails: true)
        store.refresh()
        await eventually { store.status == .stale }
        now = now.addingTimeInterval(60)
        await client.configure(holds: true)
        store.refresh()
        await eventually { await client.pending != nil }
        #expect(store.isRefreshing && store.isStale && store.reading == saved)
        await client.finish()
        await eventually { store.status == .ready }
        #expect(!store.isStale && !store.isRefreshing)
    }

    @Test("A pending location request is not duplicated by manual refresh or authorization")
    func locationSingleFlight() async {
        let location = WeatherTestLocation()
        var now = weatherTestDate
        let store = PetWeatherController(client: WeatherTestClient(), location: location, now: { now })
        defer { store.stop() }
        store.apply(WeatherPreferences(enabled: true), visible: true)
        location.onEvent?(.locating)
        let count = location.requests.count
        #expect(store.isRefreshing && !store.canRefresh)
        store.refresh()
        store.requestLocation()
        #expect(location.requests.count == count)
        location.onEvent?(.unavailable)
        #expect(store.canRefresh && !store.isRefreshing)
        location.onEvent?(.locating)
        location.onEvent?(.coordinate(weatherTestCity.coordinate))
        await eventually { store.status == .ready }
        now = now.addingTimeInterval(60)
        #expect(store.canRefresh)
        store.refresh()
        #expect(location.requests.count == count + 1)
    }

    @Test("Switching off or changing cities cancels and discards late results")
    func cancellation() async {
        let client = WeatherTestClient()
        await client.configure(holds: true)
        let store = PetWeatherController(client: client, location: WeatherTestLocation(), now: { weatherTestDate })
        defer { store.stop() }
        let prefs = WeatherPreferences(enabled: true, source: .city, city: weatherTestCity)
        store.apply(prefs, visible: true)
        await eventually { await client.pending != nil }
        store.apply(WeatherPreferences(), visible: true)
        await client.finish()
        await eventually { store.status == .off }
        #expect(store.reading == nil && store.results.isEmpty)
        await client.configure()
        store.apply(prefs, visible: true)
        await eventually { store.status == .ready }
        store.apply(WeatherPreferences(enabled: true, source: .city), visible: true)
        #expect(store.reading == nil && store.status == .noCity)
    }

    @Test("A late reading for the previous city cannot overwrite the selected city's weather")
    func cityCancellation() async {
        let client = WeatherTestClient()
        await client.configure(holds: true)
        let store = PetWeatherController(client: client, location: WeatherTestLocation(), now: { weatherTestDate })
        defer { store.stop() }
        store.apply(WeatherPreferences(enabled: true, source: .city, city: weatherTestCity), visible: true)
        await eventually { await client.pending != nil }
        await client.configure()
        let other = WeatherCity(id: 2, name: "Osaka", country: "Japan", admin1: nil, latitude: 34.69, longitude: 135.50)
        store.apply(WeatherPreferences(enabled: true, source: .city, city: other), visible: true)
        await eventually { store.status == .ready }
        await client.finish()
        try? await Task.sleep(for: .milliseconds(10))
        #expect(store.reading?.pet == .rain && store.status == .ready)
        #expect(await client.calls == [weatherTestCity.coordinate.approximate, other.coordinate.approximate])
    }
}
