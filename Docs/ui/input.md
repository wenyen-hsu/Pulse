# Pointer, drag, clicks

SwiftUI `.onHover` **does not work here**. It tracks only while the app is active. Pulse is `.accessory` behind a non-activating panel that never becomes key, so it is essentially never active.

Do not treat `hitTest` or synthesised `NSEvent`s as proof that a real click arrives. They have reported handles as reachable at widths the rail did not have, and they bypass whatever a material installs. Geometry probes are useful (“is this point in `grabArea`?”). Whether a person can drag the panel is **real input**: last verified by hand on the docked glass rail after #68.

Why enter/leave are split, why the window owns the drag, and the Liquid Glass episode: [../decisions/hover-and-drag.md](../decisions/hover-and-drag.md), [../decisions/liquid-glass.md](../decisions/liquid-glass.md).

## Liquid pet input

In weather mode, a press that begins on the centred pet and ends without dragging refreshes weather in either presentation. `PetOrbPanel.sendEvent` owns this click, as it owns ring refreshes and drag: no SwiftUI tap gesture takes over the glass or its drag target. Account-ring clicks take priority over an overlapping pet frame; the 300ms account guard and pager handling are unchanged. A collapsed pet click still expands the orb. Weather clicks use the controller's active-state, single-flight and 60-second guards, do not enable weather, and do not refresh quota providers. The avatar also exposes an accessibility action. Geometry/unit checks are not native input evidence.

Liquid mode retains the enter-only tracker, sampled-pointer departure and window-owned drag. Its glass `contentShape`, `PetOrbLayout.containsOrb` and `PetOrbPanel.sendEvent` use the same liquid outline and motion state, with a small approach halo for pointer intent. The tail and recoil never alter ring positions, the pet centre, or window size. A new press cancels recoil; hiding or switching presentation also cancels it. These geometry checks still require bundled desktop input testing.

Liquid accounts use one shared packed layout with no pages: rendering, sampled hover and `onRingClick` all address the entire slot list. Each node's visual and hit radius shrink together when the list is dense. Only a circular Pet orb with more than eight slots reserves the pager buttons for SwiftUI; the former pager area in Liquid pet remains a drag target or a normal account target. Opening details or changing the slot count does not resize the window.

Orb drags clear the card selection once the three-point drag threshold is crossed. Reselecting a ring after release can reopen details, but is not a new reading visit: `PetOrbState` defers the `noteLooked` callback until the sampled pointer genuinely leaves the content or the orb collapses. Otherwise a fixed slow usage interval can turn drag release into a full-provider hover refresh. Explicit ring/weather clicks and normal hover after departure retain their existing refresh rules. The state tests cover this callback policy; bundled-app mouse input must still verify delivery.

## Hover (open / close the card)

The pet presentation uses `PetOrbContent` and the same enter-only reporter plus sampled-pointer approach. Collapsed hit geometry includes the dot, the pet and a small approach halo; expanded geometry includes the circle, selected card and connecting bridge. Both pet modes sample every 50ms, while the classic rail retains its 150ms cadence. `PetOrbTiming` gives departure a cancellable 120ms delay, or 200ms with an open detail card; returning to the orb, card or bridge cancels it. The deadline rechecks the live pointer before clearing the card and collapsing the orb when **Hide until pointed at** is on. Expansion and collapse use a 200ms spring response with 0.9 damping; Reduced Motion still disables this animation. These are configured timings, not measured end-to-end latency. Holding the panel suspends departure. `PetOrbPanel.sendEvent` owns drag and ring-refresh clicks; a press in the first 300ms after expansion cannot refresh an account. Pager buttons are left to SwiftUI. Geometry and timing checks do not prove that these controls receive real input.

`FloatingUsagePanelView` builds rail readings from observed store/settings inputs; `FloatingUsagePanelContent` owns pointer, hover and card state below it. Layout and pointer hit tests share the same entry array, so pointer samples do not reconstruct account slots, labels and quota readings.

Two `NSViewRepresentable` backgrounds:

- `PointerEntryReporter` — `.activeAlways` `NSTrackingArea`, reports **only entering** a ring.
- `PanelPointerWatcher` — samples `NSEvent.mouseLocation` on a timer. `FloatingUsagePanelContent.isOverContent` tests against the **rail and the card**, not the window frame (the panel is full-size and mostly transparent).

For a top-docked notch rail, an unpainted `PointerEntryReporter` covers exactly the physical housing rectangle (`PanelIntent.notchHousing`). **Arriving there does not open the rail; staying does.** Entry — from the tracking area, or from a sample that finds the pointer there, for a pointer that was already inside when the area was installed — arms `armNotch`, which waits `PanelIntent.notchDwell` (250ms) and then opens only if the pointer is still in the housing *at that moment*, read through `PointerProbe` rather than the last sample (which can be 150ms old, most of the wait). A sample outside the housing calls the wait off. The housing sits on the way between the two halves of the menu bar, so opening on entry put the rail over whatever the pointer was heading for. Nothing in the wait closes anything, so the enter-only rule below still holds. The housing counts in `isOverContent` only once the rail is out, where it holds the rail open like the rest of its surface. The hidden rail has no sliver or grab target. Once expanded, the full surface from the screen top through the added bottom padding counts as content. One derived `isNotchHeld` state covers a press, drag, or open menu; releasing the last of these re-evaluates the pointer so a stationary pointer cannot leave it stuck open.

**A ring click needs the rail to have been out for `PanelIntent.ringClickGuard` (300ms)**, measured from mouse-down against `placement.railOpenedAt`. A press sooner than that was started at whatever was under the pointer before the rings appeared. It still picks up the panel; only the refresh is dropped. Every dock, not just the notch.

**Do not close on exit events.** Views appearing, moving, or animating under a stationary pointer fire spurious exits; closing reopens; it loops. Enter from tracking areas, leave from sampling the real pointer. That loop is then structurally impossible.

**Samples are deduplicated, so whatever opens the panel by another path asks for a fresh one** (`PointerProbe.reportAgain`). A ring's enter can arrive late — queued behind a busy main thread, or for a ring crossed between two samples — after the sampler has already reported the pointer gone; every later sample was that same "gone", so the card stayed open until the pointer came back and left again. Now `select` opens nothing unless the pointer is on the content **now** (`pointerProbe`; refusing closes nothing, so no loop), and `select`, `show`, the end of a drag and the menu closing each have the next sample report the pointer even if it has not moved.

The sliver’s tracking area cannot be the only way `isHovered` gets set: a floating panel dragged onto an edge docks with `isHovered` still false and snaps shut in the hand. `pointerMoved` sets it from the same test that decides when to hide.

`PanelHitArea.stripIsContainedInRail()` asserts the sliver never pokes outside the rail’s hit area (or leave-rail lands on the sliver, which shows the rail, which hides it). Bound is rail capacity / slots, not `Provider.allCases.count`. Run from `FloatingPanelController.init` once metrics are settled.

## Drag belongs to the window

Two things, different files:

1. Something in the panel must **claim** the point or the window is never handed the press — `PanelSurface`, hit-testable, `contentShape` of the capsule. `allowsHitTesting(false)` killed dragging in the empty black between rings (rings still worked via tracking areas).
   On glass that is not enough: the window server only hands a transparent window a press on a pixel it has drawn, and glass is composited outside the window. `PanelGlass.claim` puts a near-invisible fill under it. [rings-and-surface.md](rings-and-surface.md)
2. The press must be **taken** — `FloatingPanel.sendEvent`. A SwiftUI-hosted handle only sees a press if SwiftUI claims the point first. Laying a shape *over* the handle swallows the press. `sendEvent` sees events before SwiftUI hit testing and before anything Liquid Glass installs.

The window is handed **two** rects: `grabArea` (rail, or sliver when collapsed) decides whether a press is taken; `railFrame` (always the rail) is what placement arithmetic runs on. Collapsed, grabbing a 20pt sliver and placing it as a 64pt rail throws the panel across the screen. Both sized to what is drawn, or a press in the transparent band moves the panel instead of passing through.

## Ring click vs ring drag

Same window-level path. `FloatingPanel` records the press, marks a drag only after a real `leftMouseDragged`, reports a click on mouse-up otherwise. The press also sets `placement.isPressed`, and **nothing may move the panel while that is set** — not merely while `isDragging` is. The grab offset is measured at mouse-down, so a re-place in the gap before the first movement does not slide the panel, it makes it jump by that much on the frame the pointer first travels. `PanelHoldTests` pins it. `PanelHitArea.slot(at:)` accepts only the visible circle; labels and berth gaps stay drag-only. It indexes **slots**, not accounts — a split provider draws two rings from one login, so counting accounts aims every click after the split at the wrong ring. The controller builds the same list the panel draws from, through `RailSlot.rail(for:isSplit:groups:)`.

Click starts an account-scoped refresh. `UsageStore.isRefreshing` : the usage arc **dims but does not move**; a short bright segment travels around. Do not rotate the usage arc (at 0% there is no arc; at 95% a rotated arc looks still; it also takes the gauge away). Travelling mark is usage colour, not white (white is the CLI-activity mark). Hold at least 650ms so a local read still registers. Keep the physical click here; `sendEvent` takes the press before SwiftUI. Default accessibility action can still live on the ring.

A click is matched against the **displayed slots** the controller builds through `RailSlot.rail(for:isSplit:groups:)`, not `Provider.allCases`.

## Secondary click opens the panel's menu

`FloatingPanel.sendEvent` also takes `.rightMouseDown`, and `.leftMouseDown` **with control held** — a control-click is a right click on macOS, and letting it fall through to `begin(_:)` starts carrying the panel instead. Same geometry as the drag (`grabArea`), so what can be picked up can be right-clicked, **the sliver included** — the rail is wound down most of the time, and a menu reachable only after hovering is one more thing to know.

Taken in `sendEvent` rather than with SwiftUI's `.contextMenu`, for the reason every other press is: this is a non-key accessory panel and SwiftUI's own input handling is not reliable on it.

`AppDelegate.panelMenu()` builds it — the menu bar menu's plain items: Show floating panel, Settings…, Quit, and an available update — and builds it **fresh on every click**, so an update found since the last one is on it. The menu exists because a full menu bar is where Pulse's icon stops being reachable ([issue #24](https://github.com/qunqin24/Pulse/issues/24)).

`placement.isMenuOpen` is set for the span of `popUp`, which runs its own tracking loop. Without it the pointer is on the menu — off the panel by every test `pointerMoved` makes — and the rail winds down to its sliver the moment the menu appears beside it. `scheduleHide` guards on it exactly as it guards on `isDragging`, and re-arms the same way.

## Global shortcuts

`GlobalShortcut` / `GlobalShortcutMonitor` (App/). `RegisterEventHotKey`, **not** an event tap: a tap that sees other apps' keystrokes needs Accessibility permission, and that is not a trade worth offering to open a settings window. Two actions, both **unset until somebody sets one** — a default combination is a key taken out of every other app's hands on behalf of someone who never asked.

A combination needs ⌘, ⌥ or ⌃ in it; ⇧ alone is refused, and so is a bare key, function keys included. `⇧P` would take the letter P away from every text field on the Mac. A registration the window server refuses (another app holds the keys — or Pulse's own other shortcut does) lands in `unavailable`, and settings says so: a shortcut that quietly does nothing is worse than none, because the reader blames the feature. Recording is a **local event monitor**, installed only while recording and swallowing what it sees, which is what lets ⌘Q be recorded rather than quitting the app. [settings.md](settings.md)

## Settings fields

Click-away ending editing is `SettingsWindow.sendEvent`, geometry vs the field, never `hitTest`. [settings.md](settings.md).
