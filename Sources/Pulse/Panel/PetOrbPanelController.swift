// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
import AppKit
import Observation
import SwiftUI

@MainActor @Observable
final class PetOrbState {
    var isPresented = false
    var isExpanded = false
    var selectedID: String?
    var page = 0
    var isHeld = false
    var size = CGSize.zero
    var cardOnLeft = true
    var verticalCentre: CGFloat?
    var openedAt = Date.distantPast
    @ObservationIgnored let probe = PointerProbe()

    var layout: PetOrbLayout {
        PetOrbLayout(size: size, scale: PanelMetrics.scale, cardOnLeft: cardOnLeft, verticalCentre: verticalCentre)
    }

    func expand() {
        if !isExpanded { openedAt = Date() }
        isExpanded = true
        probe.reportAgain()
    }

    func collapse() {
        selectedID = nil
        isExpanded = false
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
            let range = PetOrbLayout.indices(count: slots.count, page: state.page)
            guard let local = state.layout.ringIndex(at: point, count: range.count) else { return }
            store.refresh(slots[range.lowerBound + local].account)
        }
        panel.didMoveOrb = { [weak self] in self?.savePosition() }
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
        guard let screen, !state.isHeld else { return }
        let room = screen.visibleFrame
        let scale = PanelMetrics.scale
        let width = min((PanelMetrics.orbUnitDiameter + PanelMetrics.orbUnitGap + PanelMetrics.orbUnitMargin * 2) * scale
                        + DetailCardLayout.width + DetailCardLayout.pointerWidth, room.width)
        let height = min(PanelMetrics.orbUnitWindowHeight * scale, room.height)
        state.size = CGSize(width: width.rounded(.down), height: height.rounded(.down))
        let saved = settings.defaults.array(forKey: AppSettings.Key.orbPosition) as? [Double]
        let valid = saved?.count == 2 && saved?.allSatisfy(\.isFinite) == true
        let x = valid ? min(max(saved![0], 0), 1) : 0.9
        let y = valid ? min(max(saved![1], 0), 1) : 0.5
        state.cardOnLeft = x >= 0.5
        state.verticalCentre = nil
        let centre = state.layout.centre
        let inset = state.layout.diameter / 2 + state.layout.margin
        let targetY = min(max(room.minY + room.height * y, room.minY + inset), room.maxY - inset)
        let desired = CGPoint(x: room.minX + room.width * x - centre.x,
                              y: targetY - (state.size.height - centre.y))
        let origin = CGPoint(x: min(max(desired.x, room.minX), room.maxX - state.size.width),
                             y: min(max(desired.y, room.minY), room.maxY - state.size.height))
        state.verticalCentre = origin.y + state.size.height - targetY
        panel.setFrame(CGRect(origin: origin, size: state.size), display: true)
        state.probe.reportAgain()
    }

    private func savePosition() {
        guard let screen = panel.screen else { return }
        let room = screen.visibleFrame
        let centre = state.layout.centre
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
    var onRingClick: ((CGPoint) -> Void)?
    var didMoveOrb: (() -> Void)?
    private var press: (screen: CGPoint, origin: CGPoint, local: CGPoint, refreshAllowed: Bool)?
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
            if state.isExpanded && state.layout.pagerFrame.contains(point) { break }
            state.isHeld = true
            press = (NSEvent.mouseLocation, frame.origin, point,
                     Date().timeIntervalSince(state.openedAt) >= PanelIntent.ringClickGuard)
            dragged = false
            return
        case .leftMouseDragged:
            if let press {
                let now = NSEvent.mouseLocation
                if hypot(now.x - press.screen.x, now.y - press.screen.y) > 3 { dragged = true }
                if dragged {
                    state.selectedID = nil
                    setFrameOrigin(CGPoint(x: press.origin.x + now.x - press.screen.x,
                                           y: press.origin.y + now.y - press.screen.y))
                }
                return
            }
        case .leftMouseUp:
            if let press {
                self.press = nil
                state.isHeld = false
                if dragged { didMoveOrb?() }
                else if state.isExpanded && press.refreshAllowed { onRingClick?(press.local) }
                else { state.expand() }
                state.probe.reportAgain()
                return
            }
        default: break
        }
        super.sendEvent(event)
    }
}
