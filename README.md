<p align="center"><img src="AppIcon/nokori-icon.svg" width="144" height="144" alt="Nokori white-glass Pop sun logo with a fixed red arc" /></p>

# Nokori

**English · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

A native macOS AI-usage monitor with a centred sun pet and a liquid-glass puddle.

> **Notarized download:** the Developer ID-signed, Apple-notarized DMG opens directly on any Mac — no Open Anyway step. Built and accepted on macOS 27.2. [Download and status](Downloads/README.md).

The trial below includes the white-glass Pop icon. Its **red arc is fixed branding, not live usage**. [Artwork and generation](Docs/branding.md).

> Independent development fork of [Pulse by qunqin24](https://github.com/qunqin24/Pulse). **Nokori (formerly Pulse Pet)** is the chosen name for this fork. This repository is not an official upstream release and is not endorsed by its original author.

**[Download notarized DMG — Apple Silicon + Intel](Downloads/Nokori-1.12.6-notarized-32ecd7f.dmg?raw=true)** · [Checksums and verification limits](Downloads/README.md)

> **Trial, not a stable release.** Ad-hoc signed, not Apple-notarized. Keep original Pulse installed; replace only an older Nokori. First-time location permission and successful device location still need testing on your Mac.

## What changes in this fork?

New settings default to **Liquid pet**; saved style choices are preserved. The `67923c1` trial includes this default, all-account Liquid scatter, weather-click refresh and the drag-release refresh fix.

**Known limitation:** With 77 enabled accounts, the legacy Classic rail extends beyond the display and may not be visible. Use Liquid pet or the circular Pet orb for large lists. See the [trial's verification scope and limitations](Downloads/README.md).

Liquid pet displays every enabled account ring inside the drop, without pages. Dense lists use smaller icons; hover opens the full name and usage card. The pet stays in the centre. Circular Pet orb keeps its existing pages.

| Panel style | Behaviour |
| --- | --- |
| Pet orb | The existing circular surface, with the pet at its centre. |
| Liquid pet | An uneven, spread surface; dragging pulls a trailing tail and releasing lets it settle. |
| Classic rail | The original edge-docked panel remains available. |

- Hover to expand account rings; point at a ring for its existing detail card; leave the panel and card to collapse.
- Animated Little sun by default; Cat, Fox, Rabbit and custom transparent PNG pets, with size controls.
- Optional [weather pets](Docs/weather-pet.md): clouds, rain, thunderstorms, snow, fog and moonlight. Choose fixed artwork offline, or enable local weather with explicit location permission and manual city fallback. Open-Meteo's free service is for non-commercial use only.
- Existing provider usage, account management, history, menu bar, notifications and integrations remain available. [Full feature guide](Docs/features.md) · [Supported services](Docs/supported-services.md).
- Keep the 75%, 80%, 90% and 95% warning presets, or enter a custom **1–100%** threshold.
- Liquid motion approximates surface tension and viscosity visually; it is **not a fluid simulation**. Reduce Motion disables drag stretch and recoil.

## Install without replacing Pulse

Use the **[Nokori notarized DMG](Downloads/Nokori-1.12.6-notarized-32ecd7f.dmg?raw=true)** above, built from the same native-tested sources with Developer ID signing and Apple notarization. [Download details and SHA-256](Downloads/README.md). This is a repository-hosted trial, not a tagged GitHub Release. Upstream Pulse downloads do not contain these custom features.

1. Open the fork's DMG and drag **Nokori.app** into Applications.
2. Leave **Pulse.app** untouched. Preferences, application data, login item and URL scheme are separate; original preferences are not migrated.
3. Open Nokori and select the services to monitor. It runs in the menu bar; right-click the floating panel for Settings.
4. Open **Nokori** from Applications. The notarized build is Developer ID signed and Apple-notarized, so it opens directly without the Open Anyway step. Stop for an explicit malware detection or “will damage your computer” warning; never disable Gatekeeper or remove quarantine. Older ad-hoc archives still need the Open Anyway steps. [First-launch guide](Downloads/README.md).

**Requirements:** macOS 14+; full Liquid Glass appearance on macOS 26+. Universal packages target Apple Silicon and Intel; Intel hardware and older macOS behaviour are not yet verified for these custom surfaces. Upstream automatic updates are disabled.

> Both apps may use the same provider account, CLI login or OS keychain. Independent app data does not create a separate service quota. Enable the shared Claude Code status-line integration in **only one** app.

## Choose a style and language

- **Settings → Appearance → Panel style:** Pet orb / Liquid pet / Classic rail.
- **Settings → General → Interface language:** English, Traditional or Simplified Chinese, Japanese, Korean, Russian, or follow the system.
- **Settings → Notifications:** choose a preset or custom percentage, apply it and allow macOS notifications. Alerts depend on observed readings, not a continuous real-time feed.

The links at the top switch this repository's README language; the app's language is a separate setting.

> **Upgrading from Pulse Pet:** quit it, install Nokori, then remove only the old Pulse Pet application, not its data. The existing independent preferences/data identity is retained. Do not run both old and new names together; original Pulse may still run alongside Nokori. See [branding and compatibility](Docs/branding.md).

## Weather source and cost

For automatic weather, Nokori uses **Open-Meteo, not Apple's Weather app or WeatherKit**. It is off by default and refreshes about every 30 minutes while active, not in real time. The free API needs no key but is **non-commercial only**, rate-limited and provided without an uptime guarantee. Location authorization does not grant access to the Weather app; no WeatherKit developer quota is used. See [weather source, cost and privacy](Docs/weather-pet.md#data-source-and-cost).

## Build and verify

Full Xcode with the **macOS 26 SDK or newer**, Swift tools 6.0+ and Python 3 for the repository scripts are required. Do not strip SwiftUI previews or use Command Line Tools alone.

```bash
git clone https://github.com/wenyen-hsu/Pulse.git Nokori
cd Nokori
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

Outputs: `build.noindex/Nokori.app`, `Nokori-<version>.zip` and `Nokori-<version>.dmg`. Local packaging does not create a public release. [Toolchain guide](Docs/build-from-source.md) · [Packaging and release boundaries](Docs/releasing.md).

## Privacy and contributing

There is no Pulse backend or Pulse account. Enabled providers are contacted to read usage; credentials and local usage records stay on your Mac. See [provider access](Docs/providers/README.md) before enabling a source. Do not publish tokens, cookies, keychain data or unredacted logs.

Report fork problems in [this repository's Issues](https://github.com/wenyen-hsu/Pulse/issues), not to the upstream author. Include macOS, architecture, panel style and reproduction steps, without secrets. [Contributing](CONTRIBUTING.md) · [Security reporting](SECURITY.md) · [Documentation map](Docs/README.md).

## License and thanks

Thank you to **qunqin24 and the Pulse contributors** for the original project. This independent fork retains the [Apache 2.0 license](LICENSE), [NOTICE](NOTICE) and [third-party notices](THIRD_PARTY_NOTICES.md); credit also appears in About and the installer.

Apache 2.0 allows modification and redistribution subject to its terms: retain required notices and licensing, identify modifications, and preserve applicable third-party terms. It grants neither trademark rights nor upstream endorsement. Name and logo selection is not trademark clearance.

[English](README.md) · **[繁體中文](README.zh-Hant.md)**
