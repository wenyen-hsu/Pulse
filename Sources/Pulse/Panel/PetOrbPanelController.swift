// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
// Modified by wenyen-hsu: liquid pet mode and independent-fork attribution.
import AppKit
import Observation
import SwiftUI

func petOrbDebug(_ s: String) {
    let url = URL(fileURLWithPath: "/tmp/nokori-edge.log")
    if !FileManager.default.fileExists(atPath: url.path) { FileManager.default.createFile(atPath: url.path, contents: nil) }
    guard let h = try? FileHandle(forWritingTo: url) else { return }
    h.seekToEndOfFile(); h.write(Data((s + "\n").utf8)); try? h.close()
}

@MainActor @Observable
final class PetOrbState {
    var isPresented = false
    var isExpanded = false
    var selectedID: String?
    var page = 0
    var isHeld = false
    var size = CGSize.zero
    var viewportScale: CGFloat = 1
    var cardOnLeft = true
    var verticalCentre: CGFloat?
    var openedAt = Date.distantPast
    var isLiquid = false
    var accountCount = 0
    var liquidNodes = LiquidPetNodes(count: 0)
    /// Liquid pet only: the drag's trailing pull and the nearest edge's draw.
    var stretch = CGVector.zero
    var wetting = CGVector.zero
    @ObservationIgnored let probe = PointerProbe()
    @ObservationIgnored private var recoilTask: Task<Void, Never>?
    @ObservationIgnored private var waitsForPointerDeparture = false

    /// How far the expanded liquid orb shifts vertically to stay inside the
    /// window, in window points; zero while collapsed or when it already fits.
    var edgeLift: CGFloat {
        guard isExpanded, isLiquid, size.height > 0 else { return 0 }
        let scale = PanelMetrics.scale * viewportScale
        let diameter = PanelMetrics.orbUnitDiameter * scale
        let radius = diameter / 2
        let limit = min((radius + PanelMetrics.orbUnitLiquidGap * scale * 0.9) / radius, 1.55)
        let half = diameter * limit / 2 + PanelMetrics.orbUnitMargin * scale
        let centreY = verticalCentre ?? size.height / 2
        guard half * 2 < size.height else { return size.height / 2 - centreY }
        if centreY - half < 0 { return half - centreY }
        if centreY + half > size.height { return size.height - half - centreY }
        return 0
    }

    var layout: PetOrbLayout {
        PetOrbLayout(size: size, scale: PanelMetrics.scale * viewportScale, cardOnLeft: cardOnLeft, verticalCentre: verticalCentre,
                     edgeLift: edgeLift, isLiquid: isLiquid, stretch: stretch, wetting: wetting, liquidNodes: liquidNodes)
    }

    var drawingLayout: PetOrbLayout {
        PetOrbLayout(size: CGSize(width: size.width / viewportScale, height: size.height / viewportScale),
                     scale: PanelMetrics.scale, cardOnLeft: cardOnLeft,
                     verticalCentre: verticalCentre.map { $0 / viewportScale },
                     edgeLift: edgeLift / viewportScale,
                     isLiquid: isLiquid, stretch: stretch, wetting: wetting, liquidNodes: liquidNodes)
    }

    func updateAccounts(count: Int) {
        guard accountCount != count else { return }
        accountCount = count
        liquidNodes = LiquidPetNodes(count: count)
    }

    func drawingPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x / viewportScale, y: point.y / viewportScale)
    }

    func beginDrag() {
        selectedID = nil
        waitsForPointerDeparture = true
    }

    func selectAccount(_ id: String, noteLooked: () -> Void) {
        guard selectedID != id else { return }
        selectedID = id
        if !waitsForPointerDeparture { noteLooked() }
        probe.reportAgain()
    }

    func pointerDeparted() {
        waitsForPointerDeparture = false
    }

    func stopRecoil() {
        recoilTask?.cancel()
        recoilTask = nil
        stretch = .zero
    }

    func recoil() {
        recoilTask?.cancel()
        guard stretch != .zero, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            stopRecoil()
            return
        }
        let initial = stretch
        recoilTask = Task { @MainActor [weak self] in
            let clock = ContinuousClock()
            let start = clock.now
            while !Task.isCancelled {
                do { try await Task.sleep(for: .milliseconds(16)) } catch { return }
                guard let self else { return }
                let elapsed = start.duration(to: clock.now)
                let seconds = Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
                guard seconds < 1, self.isPresented, self.isLiquid,
                      !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
                    self.stopRecoil()
                    self.probe.reportAgain()
                    return
                }
                self.stretch = LiquidMotion.rebound(initial: initial, elapsed: seconds)
                self.probe.reportAgain()
            }
        }
    }

    func expand() {
        if !isExpanded { openedAt = Date() }
        isExpanded = true
        probe.reportAgain()
        petOrbDebug("expand edgeLift=\(edgeLift) vc=\(verticalCentre ?? -1) sizeH=\(size.height) sizeW=\(size.width) isLiquid=\(isLiquid) viewport=\(viewportScale) scale=\(PanelMetrics.scale)")
    }

    func collapse() {
        pointerDeparted()
        selectedID = nil
        isExpanded = false
        petOrbDebug("collapse edgeLift=\(edgeLift) vc=\(verticalCentre ?? -1)")
    }
}

@MainActor
final class PetOrbPanelController {
    private let settings: AppSettings
    private let state = PetOrbState()
    private let panel: PetOrbPanel
    private let follower = ActiveDisplayFollower()
    nonisolated(unsafe) private var screenObserver: (any NSObjectProtocol)?
    var contextMenu: (() -> NSMenu)? {
        get { panel.contextMenu }
        set { panel.contextMenu = newValue }
    }

    init(store: UsageStore, settings: AppSettings, placement: PanelPlacement) {
        self.settings = settings
        panel = PetOrbPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.state = state
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.level = .floating
        let host = NSHostingView(rootView: FloatingUsagePanelView(
            store: store, settings: settings, placement: placement, orb: state
        ))
        host.sizingOptions = []
        host.autoresizingMask = [.width, .height]
        panel.contentView = host
        panel.petSize = { [settings] in settings.orbPetSize }
        panel.onRingClick = { [settings, store, state] point in
            let slots = RailSlot.rail(for: settings.shownAccounts, isSplit: settings.isSplit,
                                      groups: { RailSlot.modelGroups(of: store.usage(for: $0)) })
            let range = state.layout.visibleIndices(count: slots.count, page: state.page)
            guard let local = state.layout.ringIndex(at: point, count: range.count) else { return false }
            store.refresh(slots[range.lowerBound + local].account)
            return true
        }
        panel.onPetClick = { [settings] in
            guard settings.weatherPreferences.enabled else { return }
            settings.weatherPet?.refresh()
        }
        panel.didMoveOrb = { [weak self] in self?.savePosition() }
        panel.didDragOrb = { [weak self] in self?.updateWetting() }
        follower.onEnter = { [weak self] identifier in
            guard let self, !self.state.isHeld,
                  let screen = NSScreen.screens.first(where: { PanelScreen.identifier(of: $0) == identifier })
            else { return false }
            self.place(on: screen)
            return true
        }
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.panel.isVisible, !self.state.isHeld else { return }
                self.place(on: self.panel.screen ?? NSScreen.main)
                self.follower.forgetLastDisplay()
            }
        }
    }

    var isVisible: Bool { panel.isVisible }

    deinit {
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
    }

    func show() {
        place(on: panel.screen ?? NSScreen.main)
        applySettings()
        panel.orderFrontRegardless()
        state.isPresented = true
        state.probe.reportAgain()
    }

    func hide() {
        state.stopRecoil()
        state.isPresented = false
        panel.orderOut(nil)
        follower.stop()
        state.collapse()
    }

    func settingsChanged() {
        guard settings.isPanelVisible else { hide(); return }
        if !panel.isVisible { show() }
        else {
            place(on: panel.screen ?? NSScreen.main)
            applySettings()
        }
    }

    private func applySettings() {
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary,
                                    settings.hidesInFullScreen ? .fullScreenNone : .fullScreenAuxiliary]
        panel.sharingType = settings.hidesFromScreenCapture ? .none : .readOnly
        if settings.followsActiveDisplay { follower.start() } else { follower.stop() }
        if !settings.autoCollapse { state.expand() }
    }

    private func place(on screen: NSScreen?) {
        state.isLiquid = settings.panelPresentation == .liquidPet
        if !state.isLiquid { state.stopRecoil() }
        guard let screen, !state.isHeld else { return }
        let room = screen.visibleFrame
        let scale = PanelMetrics.scale
        let preferredWidth = PetOrbLayout.preferredWidth(
            scale: scale, isLiquid: state.isLiquid,
            cardWidth: DetailCardLayout.width + DetailCardLayout.pointerWidth
        )
        let width = min(preferredWidth, room.width).rounded(.down)
        state.viewportScale = min(1, width / preferredWidth)
        let height = min(PanelMetrics.orbUnitWindowHeight * scale * state.viewportScale, room.height)
        state.size = CGSize(width: width.rounded(.down), height: height.rounded(.down))
        let saved = settings.defaults.array(forKey: AppSettings.Key.orbPosition) as? [Double]
        let valid = saved?.count == 2 && saved?.allSatisfy(\.isFinite) == true
        let x = valid ? min(max(saved![0], 0), 1) : 0.9
        let y = valid ? min(max(saved![1], 0), 1) : 0.5
        state.cardOnLeft = x >= 0.5
        state.verticalCentre = nil
        let centre = state.layout.centre
        // Liquid expands by spreading along the screen edge, so the resting
        // dot only needs its own radius; the circle pet still needs the full
        // expanded circle to stay on screen.
        let inset = state.isLiquid
            ? state.layout.dotDiameter / 2 + state.layout.margin
            : state.layout.diameter / 2 + state.layout.margin
        let targetY = min(max(room.minY + room.height * y, room.minY + inset), room.maxY - inset)
        let desired = CGPoint(x: room.minX + room.width * x - centre.x,
                              y: targetY - (state.size.height - centre.y))
        let origin = CGPoint(x: min(max(desired.x, room.minX), room.maxX - state.size.width),
                             y: min(max(desired.y, room.minY), room.maxY - state.size.height))
        state.verticalCentre = origin.y + state.size.height - targetY
        petOrbDebug("place inset=\(inset) targetY=\(targetY) vc=\(state.verticalCentre ?? -1) origin=\(origin) size=\(state.size) isLiquid=\(state.isLiquid) viewport=\(state.viewportScale) scale=\(scale) roomMinY=\(room.minY) roomMaxY=\(room.maxY)")
        panel.setFrame(CGRect(origin: origin, size: state.size), display: true)
        updateWetting()
        state.probe.reportAgain()
    }

    private func updateWetting() {
        guard settings.panelPresentation == .liquidPet, let room = (panel.screen ?? NSScreen.main)?.visibleFrame else {
            state.wetting = .zero
            return
        }
        let layout = state.layout
        let centre = CGPoint(x: panel.frame.minX + layout.centre.x, y: panel.frame.maxY - layout.centre.y)
        let wetting = LiquidMotion.wetting(centre: centre, room: room, closest: layout.diameter / 2 + layout.margin,
                                           band: PanelMetrics.orbUnitWettingBand * layout.scale)
        guard wetting != state.wetting else { return }
        state.wetting = wetting
    }

    private func savePosition() {
        guard let screen = panel.screen else { return }
        let room = screen.visibleFrame
        let centre = state.layout.unliftedCentre
        let x = (panel.frame.minX + centre.x - room.minX) / max(room.width, 1)
        let y = (panel.frame.maxY - centre.y - room.minY) / max(room.height, 1)
        settings.defaults.set([x, y], forKey: AppSettings.Key.orbPosition)
        place(on: screen)
    }
}

@MainActor
private final class PetOrbPanel: NSPanel {
    var state: PetOrbState?
    var petSize: (() -> Double)?
    var contextMenu: (() -> NSMenu)?
    var onRingClick: ((CGPoint) -> Bool)?
    var onPetClick: (() -> Void)?
    var didMoveOrb: (() -> Void)?
    var didDragOrb: (() -> Void)?
    private var press: (screen: CGPoint, origin: CGPoint, local: CGPoint, refreshAllowed: Bool, onPet: Bool)?
    private var lastDrag: (point: CGPoint, time: TimeInterval)?
    private var dragged = false

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    @objc(_hasActiveAppearanceIgnoringKeyFocus)
    private func hasActiveAppearanceIgnoringKeyFocus() -> Bool { true }

    override func sendEvent(_ event: NSEvent) {
        guard let state else { super.sendEvent(event); return }
        let point = CGPoint(x: event.locationInWindow.x, y: frame.height - event.locationInWindow.y)
        let onOrb = state.layout.containsOrb(point, expanded: state.isExpanded, petSize: petSize?() ?? 1)
        switch event.type {
        case .rightMouseDown where onOrb:
            if let menu = contextMenu?(), let contentView {
                state.isHeld = true
                NSMenu.popUpContextMenu(menu, with: event, for: contentView)
                state.isHeld = false
                state.probe.reportAgain()
                return
            }
        case .leftMouseDown where onOrb:
            // Leave the pager's buttons to SwiftUI, not the window drag path.
            if state.isExpanded && state.layout.showsPager(count: state.accountCount)
                && state.layout.pagerFrame.contains(point) { break }
            state.stopRecoil()
            state.isHeld = true
            press = (NSEvent.mouseLocation, frame.origin, point,
                     Date().timeIntervalSince(state.openedAt) >= PanelIntent.ringClickGuard,
                     state.layout.petFrame(expanded: state.isExpanded, petSize: petSize?() ?? 1).contains(point))
            lastDrag = (NSEvent.mouseLocation, event.timestamp)
            dragged = false
            return
        case .leftMouseDragged:
            if let press {
                let now = NSEvent.mouseLocation
                if !dragged, hypot(now.x - press.screen.x, now.y - press.screen.y) > 3 {
                    dragged = true
                    state.beginDrag()
                }
                if dragged {
                    setFrameOrigin(CGPoint(x: press.origin.x + now.x - press.screen.x,
                                           y: press.origin.y + now.y - press.screen.y))
                    deform(to: now, at: event.timestamp)
                    didDragOrb?()
                }
                return
            }
        case .leftMouseUp:
            if let press {
                self.press = nil
                lastDrag = nil
                state.isHeld = false
                state.recoil()
                if dragged { didMoveOrb?() }
                else if state.isExpanded && press.refreshAllowed {
                    if onRingClick?(press.local) != true, press.onPet { onPetClick?() }
                } else {
                    if press.onPet { onPetClick?() }
                    state.expand()
                }
                state.probe.reportAgain()
                return
            }
        default: break
        }
        super.sendEvent(event)
    }

    private func deform(to point: CGPoint, at time: TimeInterval) {
        defer { lastDrag = (point, time) }
        guard let state, state.isLiquid, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
              let last = lastDrag, time > last.time else { return }
        let elapsed = max(time - last.time, 1.0 / 240)
        // AppKit's y grows upward; the drawing's grows downward.
        let velocity = CGVector(dx: (point.x - last.point.x) / elapsed, dy: (last.point.y - point.y) / elapsed)
        state.stretch = LiquidMotion.stretch(previous: state.stretch, velocity: velocity)
    }
}
