# Nokori branding

Nokori (のこり, “what remains”) is the chosen name for this independent Pulse fork, formerly called Pulse Pet. An existing coding-agent tool also uses Nokori; choosing this name is not trademark clearance or an assertion of exclusivity.

The original fork artwork combines a spread mint liquid shape, a dark remaining-quota ring with a gap, and a smiling warm sun. The background is deep teal. This artwork is licensed with the repository under Apache 2.0; the original Pulse author is not its designer and does not endorse the fork.

## Sources and generation

- `AppIcon/nokori-mark.svg`: transparent vector mark.
- `AppIcon/nokori-icon.svg`: preview tile used by the READMEs.
- `AppIcon/AppIcon.icon`: Icon Composer input; the system supplies the macOS icon mask/material.
- `Scripts/make-app-icon.swift`: reproduces both SVGs and the Composer foreground from the same geometry. Open strokes are outlined so their shadows do not close across the ring's gap.
- `Scripts/make-dmg-background.swift`: reproduces the independent installer heading and author credits from AppIdentity.json.

Run both Swift scripts from the repository root after editing artwork or display identity. `bundle.sh` compiles Icon Composer input using actool; it does not use the preview tile as a flat replacement for the system icon.

## Stable identity during the rename

The display name, executable and download filenames become Nokori. The bundle identifier `io.github.wenyen-hsu.PulsePet`, preferences domain, Application Support/Pulse Pet directory, login label, `pulse-pet://` links and status-line cache deliberately remain stable. This is the same app renamed, not a second copy of its data, and never imports original Pulse data.

An existing owned PulsePet status-line command is still recognized so the normal repair path can update it to the Nokori executable. Original Pulse commands remain foreign and are not automatically taken over.

Quit the earlier Pulse Pet before upgrading. Install Nokori and remove only the old Pulse Pet application bundle, without deleting its preferences/data. Do not run both names of this same app at once. The separate original Pulse.app stays installed and may run alongside Nokori.
