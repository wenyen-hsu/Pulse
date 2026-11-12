# Weather pet

**English · [繁體中文](weather-pet.zh-Hant.md)** · [Trial download and verification limits](../Downloads/README.md)

Settings → Appearance → **Automatic weather pet** is optional and **off by default**. The built-in pet menu also offers sun/cloud, moon/cloud, cloud, rain, thunderstorm, snow, fog and moon artwork without any network access. All artwork is drawn locally; the app icon remains the static Nokori blue-glass sun. Hidden panels and Reduced Motion pause pet animation. The existing avatar frame, centred pet, pointer handling, ring geometry and circular/liquid presentations are unchanged.

## Pet modes and installer version

Automatic weather and manual pets are mutually exclusive modes. While weather is enabled, the fixed-pet picker, **Import PNG** and **Use built-in pet** are disabled. Saved pet, PNG and size settings are retained; weather temporarily replaces the PNG, including when no current reading is available. Turning weather off restores the saved fixed pet or PNG. Pet size and Panel style remain adjustable.

The primary trial from source `58c8a96` includes these exclusive-mode controls and was packaged from the exact app accepted in a fresh native Apple Silicon run, without rebuilding. See [download notes and verification limits](../Downloads/README.md). The older `64e1028` trial is retained separately and still gives PNGs priority.

## Manual refresh

With automatic weather enabled and the orb visible, **click the central weather pet** to check again. This works collapsed or expanded, in circular and liquid modes. Dragging moves the orb without refreshing; provider-ring clicks still refresh only that account. Appearance settings also offer **Refresh weather**, with a progress indicator while locating/fetching. Fixed pets and saved PNGs do not initiate weather requests.

Manual checks share the existing **one-attempt-per-minute** limit, reject duplicate in-flight location/network requests, and do not restart or replace the half-hour automatic schedule. The settings button is disabled while paused, busy or cooling down. A previous failure's clock badge stays until a successful fresh reading, including while retrying; the condition and source timestamp can stay unchanged after a successful check. Hidden panels and Classic rail remain paused.

These controls are source changes, not included in the existing `58c8a96` trial installer.

## Data source and cost

- **Current source: Open-Meteo.** Nokori requests model-based current weather conditions from the Forecast API and city results from the Geocoding API. It does not read Apple's Weather app, its saved cities or cache, and does not use WeatherKit. Fixed weather artwork works offline and is not evidence of a live weather reading.
- **Free does not mean unrestricted.** The public API needs no key for non-commercial use. Its [terms](https://open-meteo.com/en/terms) and [pricing](https://open-meteo.com/en/pricing) set request limits, apply rate limiting by IP address and application, require attribution, and give no uptime guarantee. This is not a guaranteed free allowance for each Nokori user. Commercial use needs an appropriate service plan/design even if the app is free to download; Apache 2.0 does not override those API terms.
- **No Apple developer quota is used.** Location permission only grants device location access; it does not grant access to the Weather app. If Apple Weather is offered later, the official integration is [WeatherKit](https://developer.apple.com/weatherkit/), whose included API allowance is shared per Apple Developer Program membership, not per end user. That integration is not implemented, and querying the same weather service would not guarantee simultaneous updates with the Weather app.
- **Not a real-time feed.** Automatic weather refreshes about every 30 minutes while active. Network availability, forecast timestamps and stale readings can differ from what another weather app shows. Weather mode can be disabled without losing fixed pets, custom PNGs or usage monitoring.

## Consent and location

Turning on automatic weather, or switching the weather location source to the current location, requests Core Location's when-in-use authorization, just as **Allow location access** does; launching with it already enabled does not re-prompt. If access was declined, **Open Location Settings** opens the Location Services pane directly. An already-authorized device can resolve its location when weather is enabled again. Nokori requests a one-shot location with three-kilometre desired accuracy, not continuous tracking, on enable and each scheduled refresh. It ignores invalid or more-than-five-minute-old fixes, rounds coordinates to two decimal places before weather requests, and times out a pending fix after 20 seconds. Denial, restriction or unavailable location is reported in settings, where city search remains available. There is no IP geolocation fallback.

Search **City name**, then select a result (name, region and country). Selecting a result switches the source to **Choose a city** and stops location updates. A typed name alone never silently picks the first result. Device location can be selected again later. Searching happens only on the search button/Return, not while typing. The query must contain 2–100 characters.

Open-Meteo receives the weather request's approximate coordinates, or the city search text, plus the connection's IP address. No provider credential, account, usage data or device identifier is attached. Requests use a separate ephemeral URLSession without cookie or credential storage and are not added to provider response logs. City selection (including its coordinates) and the enabled/source settings are stored in Nokori's own defaults. Device fixes and weather readings are held **in memory only**, not a location history; after relaunch, a connection is needed for a fresh reading. System location prompts use the Mac's language, independently of Nokori's in-app language selection.

The in-memory-only statement concerns Nokori's local storage, not the weather provider's servers. Open-Meteo's [privacy policy](https://open-meteo.com/en/terms) says request logs may include coordinates and are deleted after 90 days.

Weather and city-search requests both honour **Network → Proxy**, including custom HTTP/SOCKS settings and **System Proxy Only**'s per-request refusal when the system proxy is absent. Each request configures its credentialless session from the current proxy settings; redirects are refused instead of forwarding a city/location request to another host. A paused orb still allows **explicit city search and selection** for later use, but does not acquire device location or fetch weather; the location-authorization button is disabled while paused and the pause reason remains visible.

## Reading, cadence and failure

`OpenMeteoPetWeather` calls the [Forecast API](https://open-meteo.com/en/docs) with `current=weather_code,is_day` and Unix timestamps. These are model-based current conditions, not a claim of a local weather-station observation. `PetWeatherReading.pet` maps the documented WMO codes: clear sky → sun/moon; mainly clear/partly cloudy → sun/cloud or moon/cloud; overcast → cloud; fog → fog; drizzle/rain/showers (including freezing rain) → rain; snow/grains/showers → snow; thunderstorms (with or without hail) → thundercloud. Unknown codes, missing values, invalid day/night flags, malformed replies, HTTP errors, and stale/future-dated readings are failures, **never default sunshine**.

`PetWeatherController` refreshes every 30 minutes while enabled and the visible panel uses an orb, even if a PNG is saved. Repeated callbacks within 60 seconds cannot start another weather request. A city/source/visibility change cancels pending HTTP/location/search work and invalidates late completions. Disabling weather cancels all work; it does not refresh usage providers. Original pets and PNG data are not changed: turning weather off restores the fixed choice or PNG. Classic rail and a hidden panel pause fetching.

No reading displays a neutral cloud with a **question-mark badge**. A failed refresh keeps the last reading for the same location with a **clock badge** and an out-of-date message; a reading over one hour old is also stale. Selecting another city clears the old city's reading rather than displaying it as the new city's weather. Settings show the weather condition and the source timestamp (not just when the app fetched it).

## Attribution and deployment terms

- Weather: [Open-Meteo](https://open-meteo.com/) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- City search: [Open-Meteo Geocoding](https://open-meteo.com/en/docs/geocoding-api), based on [GeoNames](https://www.geonames.org/), CC BY 4.0.
- The bundled public endpoint is **for non-commercial use only** and is limited to fewer than 10,000 calls/day, 5,000/hour and 600/minute; the published free-plan table also lists 300,000 calls/month. Limits apply by IP address and application, not a separate guaranteed quota per user. Availability and accuracy are not guaranteed. See [terms and privacy](https://open-meteo.com/en/terms). These API terms do not replace Nokori's Apache 2.0 source licence. Commercial weather deployment requires a suitable provider/subscription and an appropriate client authentication design, not a shared secret embedded in a public app.
- Attribution, privacy disclosure and the non-commercial restriction appear next to the setting even before it is enabled. Weather data and city names are reduced to local pet artwork; no forecast dataset is redistributed in the bundle.

## Verification boundaries

`PetWeatherTests` checks WMO/day-night mapping, settings isolation and persistence, fixed-pet/PNG mode selection and restoration, visibility gating with a saved PNG, rounding and URL encoding, fresh/missing/malformed/unsupported HTTP replies, city validation, paused/disabled behaviour, explicit permission requests, denial/manual fallback, throttling, stale readings, cancellation and still Reduced Motion poses using **synthetic API/location fixtures**. Those checks do not prove disabled controls through real input, OS permission prompts, device location, real network availability, actual animation or pointer input. Those require a bundled-app native desktop run. Current weather at one selected city cannot prove every possible real weather transition; fixed weather choices can demonstrate each drawing without falsifying the live weather source.

The `58c8a96` native run exercised disabled manual/image controls through real input, live Taipei weather overriding a saved transparent PNG, preservation across relaunch, restoration when weather is off, hidden-panel pause/resume, circular/liquid interaction, held dragging and coexistence with original Pulse. The full packaged bundle matches the accepted app, including file modes, symlinks and resources. Classic rail usability and resumption were observed, but the internal paused state is covered only by automated tests. First-use OS permission and successful GPS remain for the user's Mac; the VM's global Location Services was unchanged. Intel hardware, older macOS, narrow/multiple displays, first-use security approval, exact grace-window timing, provider authentication/notifications and every real weather transition were not tested. The separate Devin Mac App usage report is not fixed by this build.
