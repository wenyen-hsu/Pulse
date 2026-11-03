// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
import AppKit
import SwiftUI

/// The executable's entry point.
///
/// Claude Code runs this same binary as its status line command (see
/// `StatusLineHook`), so that case has to be settled before any of the app
/// starts: it must read stdin, print one line and exit rather than open a
/// window. Hence a separate entry type — `PulseApp` keeps the plain `main()`
/// that `App` provides.
@main
enum PulseMain {
    static func main() {
        if CommandLine.arguments.contains(StatusLineHook.modeArgument) {
            StatusLineHook.runAsStatusLine()
            exit(0)
        }

        // Registering has to run from this executable, since what gets written
        // into Claude Code's settings is this binary's own path.
        if CommandLine.arguments.contains("--install-statusline") {
            print(StatusLineHook.install() ? "installed" : "failed")
            exit(0)
        }
        if CommandLine.arguments.contains("--uninstall-statusline") {
            print(StatusLineHook.uninstall() ? "uninstalled" : "failed")
            exit(0)
        }

        // Read-only commands must not mark a fresh installation as configured.
        if CommandLine.arguments.contains(UsageReport.modeArgument) {
            exit(UsageReport.run())
        }

        // The recap probe: read-only like `--json`, so it is settled before
        // the migration for the same reason.
        if CommandLine.arguments.contains(RecapReport.modeArgument) {
            RecapReport.run(arguments: CommandLine.arguments)
        }

        // Before restoring settings, which marks even a fresh install as run.
        UpdateMessage.noteLaunch()

        PulseApp.main()
    }
}

struct PulseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The AppKit delegate owns the status item so it can remove it at
        // runtime. This scene supplies SwiftUI's required app scene without
        // opening a second settings window; AppDelegate owns the real one.
        Settings {
            EmptyView()
        }
        // The delegate owns the real settings window. Replacing the standard
        // command keeps Command-, from opening this required but empty scene.
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(String.localized("Settings…")) {
                    appDelegate.showSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
