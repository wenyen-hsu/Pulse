// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import CoreLocation

enum PetLocationEvent {
    case needsPermission, denied, locating, unavailable
    case coordinate(WeatherCoordinate)
}

@MainActor
protocol PetLocationProviding: AnyObject {
    var onEvent: ((PetLocationEvent) -> Void)? { get set }
    func start(requestPermission: Bool)
    func stop()
}

@MainActor
final class PetWeatherLocation: NSObject, PetLocationProviding, @preconcurrency CLLocationManagerDelegate {
    var onEvent: ((PetLocationEvent) -> Void)?
    private var manager: CLLocationManager?
    private var active = false
    private var requesting = false

    func start(requestPermission: Bool) {
        active = true
        if manager == nil {
            let manager = CLLocationManager()
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            manager.delegate = self
            self.manager = manager
        }
        guard let manager else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            onEvent?(.needsPermission)
            if requestPermission { manager.requestWhenInUseAuthorization() }
        case .denied, .restricted:
            onEvent?(.denied)
        case .authorized, .authorizedAlways:
            guard !requesting else { return }
            requesting = true
            onEvent?(.locating)
            manager.requestLocation()
        @unknown default:
            onEvent?(.unavailable)
        }
    }

    func stop() {
        active = false
        requesting = false
        manager?.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard active else { return }
        start(requestPermission: false)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard active else { return }
        requesting = false
        guard let location = locations.last, location.horizontalAccuracy >= 0,
              abs(location.timestamp.timeIntervalSinceNow) < 300 else {
            onEvent?(.unavailable)
            return
        }
        let coordinate = WeatherCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        guard coordinate.isValid else { onEvent?(.unavailable); return }
        manager.stopUpdatingLocation()
        onEvent?(.coordinate(coordinate.approximate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard active else { return }
        requesting = false
        onEvent?(.unavailable)
    }
}
