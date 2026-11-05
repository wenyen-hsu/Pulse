# Build from source

> This fork is **Nokori**, installed beside the original Pulse with independent preferences and data. See [independent application identity](architecture.md#nokori-independent-application). Packaging produces `build.noindex/Nokori.app`, `Nokori-<version>.zip` and `Nokori-<version>.dmg`; no upstream updater is enabled.

Pulse is a Swift package (`Package.swift`), macOS 14+, Swift tools 6.0. No linter; `swift test` covers rules and parsing ([testing.md](testing.md)). Open the package in Xcode or use the CLI.

User-facing clone-and-run stays in the README. **This file is the toolchain contract.** Shipping a tagged build, Sparkle, and the DMG: [releasing.md](releasing.md).

```bash
swift run Pulse              # build and run (no app bundle, no Sparkle, no SMAppService)
swift build                  # type-check, including #Preview
./Scripts/bundle.sh          # → build.noindex/Nokori.app
./Scripts/dmg.sh             # → build.noindex/Nokori-<version>.dmg
./Scripts/check-localization.sh
```

Python 3 runs the localization and packaged-startup scripts. Swift and the preview plugins come with full Xcode; the Liquid Glass source requires a macOS 26 SDK or newer. No mise configuration is included in this repository. Use the commands above rather than undocumented task aliases.

## Xcode, not Command Line Tools

`xcode-select` must point at **Xcode**. The `#Preview` macro is expanded by a plugin that ships with Xcode. Without it every build fails with `PreviewsMacros plugin not found`.

```bash
xcode-select -p
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

One-off without changing the system setting:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
```

**Never strip `#Preview` blocks to make the build green.** That hides errors inside them and has shipped a broken build. [decisions/never-strip-previews.md](decisions/never-strip-previews.md).

## Swift 6 and warnings

A clean `swift build` is not the check Xcode runs. Actor-isolation mistakes can be warnings here and hard errors in Xcode, where every `View` is `@MainActor` and one isolation slip produces a wall of “cannot find type X in scope.” Before claiming a change builds:

```bash
swift build
```

Treat remaining warnings as failures.

`RobotFace` gives its sine/cosine components explicit `CGFloat` result types so Darwin and CoreGraphics overloads are unambiguous on Intel as well as ARM. A local ARM build alone does not establish Intel compiler compatibility; keep the Intel CI build and universal bundle checks.

CI's initial build and tests use `--cache-path "$RUNNER_TEMP/swiftpm-cache"` to isolate SwiftPM downloads from the runner's shared cache. The later bundle assembly reuses the workspace's resolved dependencies and extracted artifacts; this does not disable dependency checks or any build/test gate.

CI uses the standard **`macos-15-intel`** runner and explicitly sets `DEVELOPER_DIR` to **Xcode 26.1.1**, which includes the macOS 26.1 SDK. The runner's macOS version and the selected SDK are separate: `glassEffect` requires a macOS 26 SDK even behind `#available`, but the build host need not run macOS 26. The Sequoia image's default Xcode 16.4 is insufficient, so do not remove the Xcode selection. Release retains `macos-26` with its SDK check. See [GitHub's supported runner labels](https://docs.github.com/en/actions/reference/runners/github-hosted-runners) and the [Sequoia Intel image's Xcode and SDK inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md).

Both Tahoe ARM and Intel jobs have encountered hosted-runner allocation failures. Moving CI to the mature Sequoia Intel pool does not guarantee capacity or remove the SDK check, warning gate, tests, or universal bundle verification. This CI job runs on macOS 15; it does not replace native macOS 26 input and Liquid Glass verification. A local build on an older SDK will not match CI.

When a workflow is red before any step starts, inspect its run annotations. A cancelled job with “The job was not acquired by Runner of type hosted even after multiple attempts” is a runner-allocation failure, not a compiler or test result; do not count it as a passed or merely skipped build.

macOS also draws an app's controls to the SDK recorded in its binary, not to the version it is running on, and SwiftPM has stamped the **deployment target** there instead. `Package.swift` sets it explicitly in `linkerSettings` so that every build path agrees — including running the package from Xcode, which does not go through `Scripts/bundle.sh`. If a build ever comes out with the pre-Tahoe controls, read the stamp before looking for a UI bug: `otool -arch arm64 -l <binary> | grep -A 4 LC_BUILD_VERSION`, and anything below 26 is this. [decisions/sdk-stamp-and-appearance.md](decisions/sdk-stamp-and-appearance.md)

## What `swift run` is not

A loose executable and `Nokori.app` share the existing independent preferences domain, but differ in system integration:

- Independent `AppIdentity.defaults` domain in both builds: standard defaults in the app bundle, a named suite in the loose executable ([architecture.md](architecture.md))
- Launch-agent login item instead of `SMAppService`
- No Sparkle (`SUFeedURL` / framework missing)
- Safari Full Disk Access, if ever needed for a session cookie, is granted **per application** — the bundled app and `swift run` are not the same grant

Do not test shipping behaviour (updates, login item, Gatekeeper, DMG layout) on `swift run`.
