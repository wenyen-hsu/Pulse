# Nokori branding

Nokori (のこり, “what remains”) is the chosen name for this independent Pulse fork, formerly called Pulse Pet. An existing coding-agent tool also uses Nokori; choosing this name is not trademark clearance or an assertion of exclusivity.

The fork artwork uses a white-glass background, a complete glass track with a fixed red inner arc, and a saturated yellow sun with navy outlines and a hard shadow. Subtle halftone dots retain the Pop style; there is no blue accent dot. Both circular and liquid panel modes remain available.

The red arc is a static brand illustration, not current usage, a quota percentage, or a live Dock indicator. It stays unchanged regardless of account data, including when no quota is reported. Actual usage remains in the panel's account rings and cards. Dock visibility is unchanged. This artwork is licensed with the repository under Apache 2.0; the original Pulse author is not its designer and does not endorse the fork.

## Sources and generation

- `AppIcon/nokori-mark.svg`: transparent vector mark.
- `AppIcon/nokori-icon.svg`: preview tile used by the READMEs.
- `AppIcon/nokori-icon-1024.png`: Default macOS rendition exported from Icon Composer with `ictool`.
- `AppIcon/AppIcon.icon`: Icon Composer input; the system supplies the macOS icon mask/material.
- `Scripts/make-app-icon.swift`: reproduces both SVGs and the Composer foreground from the same geometry, and updates the Composer background to white. Strokes are outlined; curved arcs avoid overlapping polygon joins. Filled gradients and shapes provide the preview's glass highlights without SVG blur filters. The Composer foreground is opaque and does not use glass/translucency effects, preserving the saturated Pop colours and outlines; the system supplies the white background material, mask, shadow and appearance variants.
- `Scripts/make-dmg-background.swift`: reproduces the independent installer heading and author credits from AppIdentity.json.

Run the relevant Swift script from the repository root after editing artwork or display identity. After changing icon artwork, export its PNG as well:

```bash
swift Scripts/make-app-icon.swift
"$(xcode-select -p)/../Applications/Icon Composer.app/Contents/Executables/ictool" AppIcon/AppIcon.icon --export-image --output-file AppIcon/nokori-icon-1024.png --platform macOS --rendition Default --width 1024 --height 1024 --scale 1
python3 -m unittest discover -s Scripts/tests -p 'test_*.py'
```

Use the exporter inside Icon Composer; Xcode's `xcrun ictool` may instead select the asset compiler, which does not support `--export-image`.

`bundle.sh` compiles Icon Composer input using actool; it does not use the preview tile as a flat replacement for the system icon. The SVG's explicit white gradient and the system's automatic gradient/material are separate renderings of the same artwork, not pixel-identical images. Original Pulse and integration-specific artwork remain unchanged.

The [`67923c1` white-Pop trial](../Downloads/README.md) package the frozen native-tested app with this artwork, without rebuilding or re-signing. The earlier `f5370ee` blue-glass installer and its checksums remain archived unchanged. The contained apps are ad-hoc signed, not Apple-notarized; native icon tests do not establish first-download Gatekeeper approval. The installer background and download guide explain Done → Privacy & Security → Open Anyway for the verification warning, without disabling protection or removing quarantine.

**Accepted on a healthy Mac.** On the owner's Apple Silicon Mac (macOS 27.2) the downloaded DMG kept quarantine, mounted without a damage warning and opened after the standard Done → Privacy & Security → Open Anyway step. The earlier block came from a test VM whose XProtect rules were missing. The diagnostic ZIP was not retested; the DMG is the recommended download.

## Stable identity during the rename

The display name, executable and download filenames become Nokori. The bundle identifier `io.github.wenyen-hsu.PulsePet`, preferences domain, Application Support/Pulse Pet directory, login label, `pulse-pet://` links and status-line cache deliberately remain stable. This is the same app renamed, not a second copy of its data, and never imports original Pulse data.

An existing owned PulsePet status-line command is still recognized so the normal repair path can update it to the Nokori executable. Original Pulse commands remain foreign and are not automatically taken over.

Quit the earlier Pulse Pet before upgrading. Install Nokori and remove only the old Pulse Pet application bundle, without deleting its preferences/data. Do not run both names of this same app at once. The separate original Pulse.app stays installed and may run alongside Nokori.
