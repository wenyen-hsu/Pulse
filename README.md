<p align="center"><img src="AppIcon/nokori-icon.svg" width="144" height="144" alt="Nokori liquid sun logo" /></p>

# Nokori

**English · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

A native macOS AI-usage monitor with a centred sun pet and an optional liquid-glass puddle.

> Independent development fork of [Pulse by qunqin24](https://github.com/qunqin24/Pulse). **Nokori (formerly Pulse Pet)** is the chosen name for this fork. This repository is not an official upstream release and is not endorsed by its original author.

## What changes in this fork?

| Panel style | Behaviour |
| --- | --- |
| Pet orb | The existing circular surface, with the pet at its centre. |
| Liquid pet | An uneven, spread surface; dragging pulls a trailing tail and releasing lets it settle. |
| Classic rail | The original edge-docked panel remains available. |

- Hover to expand account rings; point at a ring for its existing detail card; leave the panel and card to collapse.
- Animated Little sun by default; Cat, Fox, Rabbit and custom transparent PNG pets, with size controls.
- Existing provider usage, account management, history, menu bar, notifications and integrations remain available. [Full feature guide](Docs/features.md) · [Supported services](Docs/supported-services.md).
- Keep the 75%, 80%, 90% and 95% warning presets, or enter a custom **1–100%** threshold.
- Liquid motion approximates surface tension and viscosity visually; it is **not a fluid simulation**. Reduce Motion disables drag stretch and recoil.

## Install without replacing Pulse

Use a **Nokori** trial package supplied by the maintainer or listed under [this fork's Releases](https://github.com/wenyen-hsu/Pulse/releases). If no fork package is available, build from source below. Upstream Pulse downloads do not contain these custom features.

1. Open the fork's DMG and drag **Nokori.app** into Applications.
2. Leave **Pulse.app** untouched. Preferences, application data, login item and URL scheme are separate; original preferences are not migrated.
3. Open Nokori and select the services to monitor. It runs in the menu bar; right-click the floating panel for Settings.
4. Trial packages are ad-hoc signed, **not Apple-notarized**. If blocked, use System Settings → Privacy & Security → Open Anyway only for a package you trust.

**Requirements:** macOS 14+; full Liquid Glass appearance on macOS 26+. Universal packages target Apple Silicon and Intel; Intel hardware and older macOS behaviour are not yet verified for these custom surfaces. Upstream automatic updates are disabled.

> Both apps may use the same provider account, CLI login or OS keychain. Independent app data does not create a separate service quota. Enable the shared Claude Code status-line integration in **only one** app.

## Choose a style and language

- **Settings → Appearance → Panel style:** Pet orb / Liquid pet / Classic rail.
- **Settings → General → Interface language:** English, Traditional or Simplified Chinese, Japanese, Korean, Russian, or follow the system.
- **Settings → Notifications:** choose a preset or custom percentage, apply it and allow macOS notifications. Alerts depend on observed readings, not a continuous real-time feed.

The links at the top switch this repository's README language; the app's language is a separate setting.

> **Upgrading from Pulse Pet:** quit it, install Nokori, then remove only the old Pulse Pet application, not its data. The existing independent preferences/data identity is retained. Do not run both old and new names together; original Pulse may still run alongside Nokori. See [branding and compatibility](Docs/branding.md).

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
