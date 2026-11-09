#!/bin/bash
#
# Notarises a packaged DMG (and optionally the zip beside it) with Apple's
# notary service and staples the ticket to the image, so Gatekeeper accepts
# the download without the Open Anyway step. bundle.sh must already have
# signed the app with a Developer ID certificate (SIGNING_IDENTITY) — the
# notary service rejects ad-hoc signatures.
#
# One-time credential setup on the Mac doing the release:
#
#   xcrun notarytool store-credentials notarytool-profile \
#       --apple-id you@example.com --team-id ABCDE12345 \
#       --password <app-specific-password>
#
# The password is an app-specific password from appleid.apple.com, stored in
# that Mac's keychain; nothing is written to the repository.
#
#   ./Scripts/notarize.sh build.noindex/Nokori-<version>.dmg [zip]
#
# NOTARY_PROFILE overrides the keychain profile name.

set -euo pipefail

PROFILE="${NOTARY_PROFILE:-}"
[ -z "$PROFILE" ] && PROFILE="notarytool-profile"

DMG="${1:-}"
if [ -z "$DMG" ]; then
    echo "usage: notarize.sh <dmg> [zip]" >&2
    exit 1
fi
ZIP="${2:-}"

if ! xcrun notarytool history --keychain-profile "$PROFILE" >/dev/null 2>&1; then
    echo "No notarytool keychain profile '$PROFILE'." >&2
    echo "Create one first: xcrun notarytool store-credentials $PROFILE --apple-id … --team-id … --password …" >&2
    exit 1
fi

echo "Submitting $DMG to the notary service…"
xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait

echo "Stapling the ticket to $DMG…"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"

if [ -n "$ZIP" ] && [ -f "$ZIP" ]; then
    # A zip cannot carry a stapled ticket; submitting it lets Gatekeeper find
    # the notarisation online when the archive is opened.
    echo "Submitting $ZIP to the notary service…"
    xcrun notarytool submit "$ZIP" --keychain-profile "$PROFILE" --wait
fi

echo "Notarised. Gatekeeper accepts this download without the Open Anyway step."
