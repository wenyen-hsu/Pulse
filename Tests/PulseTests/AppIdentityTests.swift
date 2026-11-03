import Foundation
import Testing
@testable import Pulse

@Suite("Independent Pulse Pet identity")
struct AppIdentityTests {
    @Test("App, storage, links and login agent cannot resolve to the original Pulse")
    func identity() {
        #expect(AppIdentity.name == "Pulse Pet")
        #expect(AppIdentity.executableName == "PulsePet")
        #expect(AppIdentity.bundleIdentifier == "io.github.wenyen-hsu.PulsePet")
        #expect(PulseStorage.directory.lastPathComponent == "Pulse Pet")
        #expect(PulseStorage.directory != URL.applicationSupportDirectory.appending(path: "Pulse"))
        #expect(LoginItem.label == AppIdentity.bundleIdentifier + ".launch-at-login")
        #expect(LoginItem.label != "com.pulse.launch-at-login")
        #expect(StatusLineHook.cacheFile.lastPathComponent == "pulse-pet-usage.json")
        #expect(PulseLink.settings.url.scheme == "pulse-pet")
        #expect(PulseLink(url: URL(string: "pulse://settings")!) == nil)
        #expect(AppIdentity.repositoryURL.absoluteString == "https://github.com/wenyen-hsu/Pulse")
    }

    @Test("A packaged app uses its own standard domain, not an invalid same-name suite")
    func packagedPreferences() {
        #expect(AppIdentity.defaults(runningBundleIdentifier: AppIdentity.bundleIdentifier) === UserDefaults.standard)
    }

    @Test("Preferences stay in the same independent domain even outside an app bundle")
    func preferences() {
        let key = "PulsePetIdentityTest." + UUID().uuidString
        let defaults = AppIdentity.defaults
        defer { defaults.removeObject(forKey: key) }
        defaults.set("pet", forKey: key)
        #expect(AppIdentity.defaults.string(forKey: key) == "pet")
        #expect(defaults.persistentDomain(forName: AppIdentity.bundleIdentifier)?[key] as? String == "pet")
    }

    @Test("The current loose executable also owns its hook without claiming another Pulse binary")
    func looseExecutable() throws {
        let executable = try #require(Bundle.main.executableURL)
        #expect(StatusLineHook.owns("\"\(executable.path)\" --statusline"))
        #expect(!StatusLineHook.owns("\"/Applications/Pulse.app/Contents/MacOS/Pulse\" --statusline"))
    }

    @Test("Only this app's status line is repaired or disconnected", arguments: [
        ("\"/Applications/Pulse Pet.app/Contents/MacOS/PulsePet\" --statusline", true),
        ("\"/Users/me/Old Location/PulsePet\" --statusline", true),
        ("/tmp/PulsePet --statusline", true),
        ("PulsePet --statusline", true),
        ("\"/Applications/Pulse.app/Contents/MacOS/Pulse\" --statusline", false),
        ("echo PulsePet --statusline", false),
        ("other --statusline", false),
        (" --statusline", false),
        ("PulsePet --statusline-extra", false)
    ])
    func statusLine(_ value: (String, Bool)) {
        #expect(StatusLineHook.owns(value.0) == value.1)
    }
}
