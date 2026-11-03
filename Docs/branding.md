# Nokori branding

Nokori (のこり, “what remains”) is the chosen name for this independent Pulse fork, formerly called Pulse Pet. An existing coding-agent tool also uses Nokori; choosing this name is not trademark clearance or an assertion of exclusivity.

The original fork artwork uses an ice-blue glass remaining-quota ring with a gap, a smiling warm sun, and a deep-blue background. The former mint liquid silhouette is no longer part of the icon; both circular and liquid panel modes remain available. The icon's ring is a brand mark, not a live usage reading. This artwork is licensed with the repository under Apache 2.0; the original Pulse author is not its designer and does not endorse the fork.

## Sources and generation

- `AppIcon/nokori-mark.svg`: transparent vector mark.
- `AppIcon/nokori-icon.svg`: preview tile used by the READMEs.
- `AppIcon/nokori-icon-1024.png`: Default macOS rendition exported from Icon Composer with `ictool`.
- `AppIcon/AppIcon.icon`: Icon Composer input; the system supplies the macOS icon mask/material.
- `Scripts/make-app-icon.swift`: reproduces both SVGs and the Composer foreground from the same geometry, and updates the Composer background to deep blue. Open strokes are outlined so their shadows do not close across the ring's gap. The source uses filled gradients rather than SVG blur filters; Icon Composer supplies the native glass, shadow and appearance variants.
- `Scripts/make-dmg-background.swift`: reproduces the independent installer heading and author credits from AppIdentity.json.

Run the relevant Swift script from the repository root after editing artwork or display identity. After changing icon artwork, export its PNG as well:

```bash
swift Scripts/make-app-icon.swift
"$(xcode-select -p)/../Applications/Icon Composer.app/Contents/Executables/ictool" AppIcon/AppIcon.icon --export-image --output-file AppIcon/nokori-icon-1024.png --platform macOS --rendition Default --width 1024 --height 1024 --scale 1
python3 -m unittest discover -s Scripts/tests -p 'test_*.py'
```

Use the exporter inside Icon Composer; Xcode's `xcrun ictool` may instead select the asset compiler, which does not support `--export-image`.

`bundle.sh` compiles Icon Composer input using actool; it does not use the preview tile as a flat replacement for the system icon. The SVG's explicit blue gradient and the system's automatic gradient/material are separate renderings of the same artwork, not pixel-identical images. Original Pulse and integration-specific artwork remain unchanged.

## Stable identity during the rename

The display name, executable and download filenames become Nokori. The bundle identifier `io.github.wenyen-hsu.PulsePet`, preferences domain, Application Support/Pulse Pet directory, login label, `pulse-pet://` links and status-line cache deliberately remain stable. This is the same app renamed, not a second copy of its data, and never imports original Pulse data.

An existing owned PulsePet status-line command is still recognized so the normal repair path can update it to the Nokori executable. Original Pulse commands remain foreign and are not automatically taken over.

Quit the earlier Pulse Pet before upgrading. Install Nokori and remove only the old Pulse Pet application bundle, without deleting its preferences/data. Do not run both names of this same app at once. The separate original Pulse.app stays installed and may run alongside Nokori.
