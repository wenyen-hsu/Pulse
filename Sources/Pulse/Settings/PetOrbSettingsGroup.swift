// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
// Modified by wenyen-hsu: liquid pet mode and independent-fork attribution.
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct PetOrbSettingsGroup: View {
    @Bindable var settings: AppSettings
    @State private var importFailed = false

    var body: some View {
        SettingsGroup {
            SettingsRow(String.localized("Panel style"),
                        subtitle: String.localized("Hover over your pet to reveal accounts around it.")) {
                Picker(String.localized("Panel style"), selection: $settings.panelPresentation) {
                    ForEach(PanelPresentation.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: SettingsLayout.controlWidth)
            }
            if settings.panelPresentation.usesOrb {
                SettingsRowDivider()
                SettingsRow(String.localized("Pet"),
                            subtitle: String.localized("Choose a companion or import a transparent PNG.")) {
                    HStack {
                        OrbPetAvatar(pet: settings.orbPet, imageData: settings.orbPetImage)
                            .frame(width: 42, height: 42)
                        Picker(String.localized("Pet"), selection: $settings.orbPet) {
                            ForEach(OrbPet.allCases) { pet in
                                Text(pet.title).tag(pet)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .disabled(settings.orbPetImage != nil)
                    }
                    .frame(width: SettingsLayout.controlWidth)
                }
                SettingsRowDivider()
                SettingsRow(String.localized("Pet image")) {
                    HStack {
                        if settings.orbPetImage != nil {
                            Button(String.localized("Use built-in pet")) { settings.orbPetImage = nil }
                        }
                        Button(String.localized("Import PNG…"), action: importImage)
                    }
                }
                if settings.weatherPreferences.enabled {
                    Text(localized: "Turn off automatic weather to use the selected fixed pet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(12)
                }
                SettingsRowDivider()
                SettingsRow(String.localized("Pet size")) {
                    Slider(value: $settings.orbPetSize, in: 0.7...1.3)
                        .accessibilityLabel(String.localized("Pet size"))
                        .frame(width: SettingsLayout.controlWidth)
                }
                Text(localized: "The pet orb always uses Liquid Glass. Rail docking options apply to the classic rail.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(12)
            }
        }
        .alert(String.localized("Could not import image"), isPresented: $importFailed) {
            Button(String.localized("OK"), role: .cancel) {}
        } message: {
            Text(localized: "Choose a PNG smaller than 20 MB. The image is stored locally at up to 512 pixels.")
        }
    }

    private func importImage() {
        let picker = NSOpenPanel()
        picker.allowedContentTypes = [.png]
        picker.canChooseDirectories = false
        picker.allowsMultipleSelection = false
        guard picker.runModal() == .OK, let url = picker.url else { return }
        do { settings.orbPetImage = try PetImageImport.png(from: url) }
        catch { importFailed = true }
    }
}
