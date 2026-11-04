# Set up Devin in Nokori

Nokori shows Devin's daily and weekly usage remaining, as percentages, when your plan reports them, plus a credit balance if your account carries one. A free plan with no percentages shows a messages-left count instead.

## What you need

A Devin (Cognition) account. Use a Chromium-based browser (Chrome, Edge, Brave, Arc, or Vivaldi — not Safari or Firefox) signed in at app.devin.ai, or the Devin Mac app **if its saved plan includes usage figures**. A saved plan name alone is not enough; some app/account combinations save subscription details without quotas.

## Steps

1. Sign in at https://app.devin.ai in a supported Chromium browser. Use the account and organization whose quota you want to monitor. The app-only alternative below works only when the app saves usage figures.
2. In Nokori, go to Settings → Devin and turn on "Show in panel". Set **Read usage from** to **Automatic** or **Usage endpoint**. Under **Read from browser**, pick the browser you signed in with (or leave it on Automatic) and click **Read**. Nothing needs to be pasted, and there is no keychain prompt.
3. A successful reading shows the daily and weekly usage remaining (or a messages-left count on a free plan), when that account reports them. Check **Connection diagnostics** to see whether the result came from `endpoint` or `appCache`.

Nokori can only read Chrome, Edge, Brave, Arc, and Vivaldi for Devin. If you use Safari or Firefox, sign in at app.devin.ai once in a supported browser, or use the app-only route when available. Without a browser session, **Automatic** reads the plan the app saved the last time it started; **Provider tooling** always uses that saved plan. A usable snapshot is marked "as of" when it ages. Reopening the app may refresh it, but does not guarantee that usage fields will be saved.

On one observed Devin 3.11.238 Pro installation, the saved plan had no daily/weekly percentages and only "not applicable" message counters. In this case the app-only route cannot supply a ring. Use the browser steps above; do not assume missing figures mean zero remaining or that the subscription is inactive. [Saved-plan evidence and limitations](../providers/devin.md#a-saved-plan-without-usage-figures).

## If it doesn't work

| Message Nokori shows | What to do |
|---|---|
| Devin isn't installed. | Install the Devin Mac app, or use the browser session route instead. |
| Open Devin and sign in, so it can record your plan. | Open the Devin Mac app and sign in — it saves your plan the moment it starts. |
| No Devin session found. Sign in at app.devin.ai first. | Sign in at app.devin.ai in the browser Nokori is set to read, then click "Read" again. |
| The app's saved plan has no usage figures. Use a signed-in browser to check usage. | Use the browser steps above, including changing Provider tooling to Automatic or Usage endpoint. Restarting the app alone is not a reliable remedy for missing fields. |
| No limits reported. | Check the route in Connection diagnostics. A saved plan may have no unexpired windows, or an endpoint may report no visible allocation. This does not itself establish that an allowance was exhausted. |

## What Nokori reads

Nokori reads your app.devin.ai session from a Chromium browser's local storage each time it checks and sends it only to app.devin.ai — nothing is saved on this Mac. The saved-plan fallback reads, read-only, a file the Devin Mac app already wrote to your Application Support folder; it needs no permission and no network access.

To share a failed check, use **Connection diagnostics → Copy diagnostics**. The report includes only the source, status and timestamps; it excludes account details, credentials and raw server replies. There is no need to share tokens or the contents of the app's database.
