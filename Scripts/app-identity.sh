# Sourced from repository-root packaging scripts.
eval "$(python3 - <<'PY'
import json
import shlex

with open("Sources/Pulse/Resources/AppIdentity.json") as source:
    identity = json.load(source)
for variable, key in {
    "APP_NAME": "name",
    "EXECUTABLE": "executableName",
    "BUNDLE_ID": "bundleIdentifier",
    "URL_SCHEME": "urlScheme",
    "REPOSITORY": "repository",
}.items():
    value = identity[key]
    if not isinstance(value, str) or not value:
        raise ValueError(f"Invalid application identity: {key}")
    print(f"{variable}={shlex.quote(value)}")
PY
)"
test -n "${APP_NAME:-}" && test -n "${EXECUTABLE:-}" && test -n "${BUNDLE_ID:-}"
