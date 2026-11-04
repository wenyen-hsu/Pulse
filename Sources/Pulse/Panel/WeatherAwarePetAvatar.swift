// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import SwiftUI

struct WeatherAwarePetAvatar: View {
    let settings: AppSettings
    var isAnimating = true

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { _ in
            let usesWeather = settings.weatherPreferences.enabled
            let weather = settings.weatherPet
            let pet = usesWeather ? weather?.reading?.pet ?? .cloud : settings.orbPet
            OrbPetAvatar(pet: pet, imageData: settings.effectivePetImage, isAnimating: isAnimating)
                .overlay(alignment: .bottomTrailing) {
                    if usesWeather && (weather?.reading == nil || weather?.isStale == true) {
                        GeometryReader { geometry in
                            Image(systemName: weather?.reading == nil ? "questionmark.circle.fill" : "clock.fill")
                                .resizable().scaledToFit()
                                .foregroundStyle(.white, Color(red: 0.16, green: 0.24, blue: 0.4))
                                .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.25)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(usesWeather ? "\(pet.title). \(weather?.isStale == true ? PetWeatherController.Status.stale.title : weather?.status.title ?? PetWeatherController.Status.unavailable.title)" : pet.title)
        }
    }
}
