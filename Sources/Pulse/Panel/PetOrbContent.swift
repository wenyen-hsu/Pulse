// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
// Modified by wenyen-hsu: liquid pet mode and independent-fork attribution.
import SwiftUI

enum PetOrbTiming {
    static let pointerInterval: TimeInterval = 0.05
    static let animationResponse: TimeInterval = 0.2

    static func departureDelay(hasCard: Bool) -> Duration {
        hasCard ? .milliseconds(200) : .milliseconds(120)
    }
}

struct PetOrbContent: View {
    let store: UsageStore
    let settings: AppSettings
    let entries: [RailEntry]
    let state: PetOrbState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hideTask: Task<Void, Never>?
    @State private var cardHeight = DetailCardLayout.estimatedHeight
    @State private var ledgers = CardLedgers()

    private var layout: PetOrbLayout { state.drawingLayout }
    private var visible: [RailEntry] { Array(entries[PetOrbLayout.indices(count: entries.count, page: state.page)]) }
    private var selected: RailEntry? { visible.first { $0.id == state.selectedID } }
    private var cardRect: CGRect {
        layout.cardFrame(height: cardHeight, width: DetailCardLayout.width + DetailCardLayout.pointerWidth)
    }
    private var animation: Animation? {
        reduceMotion ? nil : .spring(response: PetOrbTiming.animationResponse, dampingFraction: 0.9)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            orb
            if state.isExpanded {
                ForEach(Array(visible.enumerated()), id: \.element.id) { index, entry in
                    node(entry)
                        .position(layout.ringCentre(index: index, count: visible.count))
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                }
                if entries.isEmpty {
                    Text(localized: "Enable a service in its settings to start monitoring.")
                        .font(.system(size: PanelMetrics.orbCaptionSize))
                        .multilineTextAlignment(.center)
                        .frame(width: PanelMetrics.orbEmptyWidth)
                        .position(x: layout.centre.x, y: layout.centre.y + PanelMetrics.orbEmptyOffset)
                } else if PetOrbLayout.pageCount(for: entries.count) > 1 {
                    pager.position(x: layout.pagerFrame.midX, y: layout.pagerFrame.midY)
                }
                if let selected { detail(selected) }
            }
            let pet = layout.petFrame(expanded: state.isExpanded, petSize: settings.orbPetSize)
            WeatherAwarePetAvatar(settings: settings, isAnimating: state.isPresented)
                .frame(width: pet.width, height: pet.height)
                .shadow(color: .black.opacity(0.2), radius: 5, y: 4)
                .position(x: pet.midX, y: pet.midY)
                .allowsHitTesting(false)
        }
        .frame(width: layout.size.width, height: layout.size.height)
        .scaleEffect(state.viewportScale, anchor: .topLeading)
        .frame(width: state.size.width, height: state.size.height, alignment: .topLeading)
        .background(PanelPointerWatcher(onChange: pointerMoved, probe: state.probe,
                                        interval: PetOrbTiming.pointerInterval))
        .animation(animation, value: state.isExpanded)
        .foregroundStyle(PanelGlass.ink(transparency: settings.glassTransparency).map(AnyShapeStyle.init) ?? AnyShapeStyle(.primary))
        .environment(\.colorScheme, PanelGlass.scheme(transparency: settings.glassTransparency))
        .environment(\.glassTransparency, settings.glassTransparency)
        .environment(\.usageWarningThreshold, settings.warningThreshold.fraction)
        .onChange(of: entries.map(\.id)) {
            state.page = min(state.page, PetOrbLayout.pageCount(for: entries.count) - 1)
            if selected == nil { state.selectedID = nil }
            state.probe.reportAgain()
        }
        .onChange(of: state.selectedID) { readHistory() }
        .onChange(of: state.isPresented) {
            hideTask?.cancel()
            hideTask = nil
            state.probe.reportAgain()
        }
        .onChange(of: state.isHeld) { _, held in
            if held {
                hideTask?.cancel()
                hideTask = nil
            } else { state.probe.reportAgain() }
        }
        .onChange(of: settings.autoCollapse) { state.probe.reportAgain() }
        .onDisappear { hideTask?.cancel() }
    }

    private var orb: some View {
        let diameter = state.isExpanded ? layout.diameter : layout.dotDiameter
        return surface(diameter: diameter)
            .position(layout.centre)
            .background {
                let target = layout.circle
                // Entry is only a hint; recheck the sampled pointer before opening.
                Color.clear
                    .frame(width: target.width, height: target.height)
                    .position(layout.centre)
                    .background(PointerEntryReporter { pointerMoved(state.probe.current()) })
                    .allowsHitTesting(false)
            }
            .accessibilityLabel(String.localized("Pet orb"))
            .accessibilityAction(named: Text(localized: "Show accounts")) { state.expand() }
            .accessibilityAction(named: Text(localized: "Hide accounts")) { state.collapse() }
    }

    @ViewBuilder
    private func surface(diameter: CGFloat) -> some View {
        if settings.panelPresentation == .liquidPet {
            let shape = layout.liquidShape(expanded: state.isExpanded, petSize: settings.orbPetSize)
            let frame = layout.liquidFrame(expanded: state.isExpanded)
            PanelSurface(shape: shape, usesGlass: true)
                .overlay { shape.stroke(.white.opacity(0.24), lineWidth: 1) }
                .frame(width: frame.width, height: frame.height)
        } else {
            PanelSurface(shape: Circle(), usesGlass: true)
                .frame(width: diameter, height: diameter)
                .overlay {
                    Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1)
                }
        }
    }

    private func node(_ entry: RailEntry) -> some View {
        UsageRingView(
            provider: entry.usage.provider, usedFraction: entry.headline?.usedFraction,
            hasReading: entry.headline != nil || entry.figure != nil, chosenTint: entry.tint,
            isSpent: UsageTint.isSpent(entry.headline), showsRemaining: entry.showsRemaining,
            diameter: DockLayout.ringDiameter, lineWidth: DockLayout.ringLineWidth,
            isBusy: entry.isRunning, isRefreshing: entry.isRefreshing,
            animatesActivity: settings.animatesRingActivity, highlight: entry.id == state.selectedID,
            windowClockFraction: entry.windowClock, secondFraction: entry.second?.usedFraction,
            secondIsSpent: UsageTint.isSpent(entry.second), robot: entry.robot, isLive: state.isExpanded
        )
        .overlay(alignment: .top) {
            Text(entry.title)
                .font(.system(size: PanelMetrics.orbLabelSize, weight: .medium))
                .lineLimit(1)
                .frame(width: PanelMetrics.orbLabelWidth)
                .offset(y: DockLayout.ringDiameter + PanelMetrics.orbTitleGap)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            Text(entry.headline?.percentText(remaining: entry.showsRemaining) ?? entry.figure ?? "—")
                .font(.system(size: PanelMetrics.orbLabelSize, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: PanelMetrics.orbLabelWidth)
                .offset(y: -DockLayout.ringDiameter - PanelMetrics.orbFigureGap)
                .allowsHitTesting(false)
        }
        .background(PointerEntryReporter { select(entry) })
        .help(entry.title)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(entry.title)
        .accessibilityAction(named: Text(localized: "Show details")) { state.selectedID = entry.id }
        .accessibilityAction(named: Text(localized: "Refresh")) { store.refresh(entry.slot.account) }
    }

    private var pager: some View {
        HStack(spacing: layout.gap) {
            Button { turnPage(-1) } label: { Image(systemName: "chevron.left") }
                .accessibilityLabel(String.localized("Previous accounts"))
                .disabled(state.page == 0)
            Text(verbatim: "\(state.page + 1) / \(PetOrbLayout.pageCount(for: entries.count))")
                .monospacedDigit()
            Button { turnPage(1) } label: { Image(systemName: "chevron.right") }
                .accessibilityLabel(String.localized("Next accounts"))
                .disabled(state.page + 1 >= PetOrbLayout.pageCount(for: entries.count))
        }
        .font(.system(size: PanelMetrics.orbCaptionSize))
        .buttonStyle(.plain)
    }

    private func turnPage(_ step: Int) {
        state.page = min(max(state.page + step, 0), PetOrbLayout.pageCount(for: entries.count) - 1)
        state.selectedID = nil
        state.probe.reportAgain()
    }

    private func detail(_ entry: RailEntry) -> some View {
        UsageDetailCard(
            usesGlass: true, usage: entry.usage, title: entry.title,
            edge: state.cardOnLeft ? .right : .left,
            showsRemaining: settings.showsRemaining, showsForecast: settings.showsForecast,
            showsAmounts: entry.usage.provider == .qoder && settings.qoderShowsAmounts,
            resetCredits: entry.usage.account == AccountKey(.codex) ? store.codexResetCredits : nil,
            isDetailed: settings.showsDetailedCard(for: entry.usage.account),
            spend: showsSpend(entry) ? ledgers.spend(for: entry.usage.provider) : nil,
            qoderCredits: entry.usage.provider == .qoder ? ledgers.qoderCredits : nil,
            promptCache: showsSpend(entry) ? ledgers.promptCache[entry.usage.provider] : nil,
            usedElsewhere: Set(entry.usage.windows.filter {
                store.usedElsewhere($0, account: entry.usage.account)
            }.map(\.id)),
            pointerCenter: layout.ringCentre(index: visible.firstIndex(where: { $0.id == entry.id }) ?? 0,
                                             count: visible.count).y - cardRect.minY,
            maxHeight: layout.size.height - layout.margin * 2
        )
        .fixedSize()
        .background(GeometryReader { proxy in
            Color.clear.onChange(of: proxy.size.height, initial: true) { _, height in cardHeight = height }
        })
        .position(x: cardRect.midX, y: cardRect.midY)
        .transition(.opacity)
    }

    private func select(_ entry: RailEntry) {
        guard state.isPresented, !state.isHeld, state.isExpanded,
              let point = state.probe.current(),
              let index = layout.ringIndex(at: state.drawingPoint(point), count: visible.count), visible[index].id == entry.id
        else { return }
        if state.selectedID != entry.id {
            state.selectedID = entry.id
            store.noteLooked()
            state.probe.reportAgain()
        }
    }

    private func pointerMoved(_ point: CGPoint?) {
        guard state.isPresented, !state.isHeld else { return }
        let inside = containsContent(point)
        if inside {
            hideTask?.cancel()
            hideTask = nil
            if !state.isExpanded { state.expand() }
            if let point, let index = layout.ringIndex(at: state.drawingPoint(point), count: visible.count) { select(visible[index]) }
        } else if hideTask == nil {
            let delay = PetOrbTiming.departureDelay(hasCard: selected != nil)
            hideTask = Task { @MainActor in
                do { try await Task.sleep(for: delay) } catch { return }
                guard !Task.isCancelled else { return }
                hideTask = nil
                guard state.isPresented, !state.isHeld else { return }
                if containsContent(state.probe.current()) {
                    pointerMoved(state.probe.current())
                    return
                }
                state.selectedID = nil
                if settings.autoCollapse { state.collapse() }
            }
        }
    }

    private func containsContent(_ point: CGPoint?) -> Bool {
        point.map(state.drawingPoint).map {
            layout.containsOrb($0, expanded: state.isExpanded, petSize: settings.orbPetSize)
                || (selected != nil && layout.containsBridge($0, card: cardRect))
        } ?? false
    }

    private func showsSpend(_ entry: RailEntry) -> Bool {
        guard settings.showsDetailedCard(for: entry.usage.account), entry.usage.account.isPrimary,
              let source = entry.usage.provider.cardHistory else { return false }
        return !source.readsThisMac || settings.readsTokenSpend
    }

    private func readHistory() {
        guard state.isPresented, let selected else { return }
        let provider = selected.usage.provider
        if showsSpend(selected), let source = provider.cardHistory {
            ledgers.read(provider, from: source)
            if source.readsThisMac { ledgers.readPromptCache(provider) }
        }
        if provider == .qoder, settings.showsDetailedCard(for: selected.usage.account),
           let cookie = APIKeyStore.key(for: .qoder) {
            ledgers.readQoderCredits(cookie: cookie, site: settings.qoderSite)
        }
    }
}
