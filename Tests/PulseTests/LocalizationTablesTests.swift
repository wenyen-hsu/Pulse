import Foundation
import Testing
@testable import Pulse

/// Every language table loads, whole. One malformed line makes macOS drop the
/// entire file and the app falls back to English everywhere — 1.12.5 shipped
/// that way, with every key still present.
struct LocalizationTablesTests {
    @Test("Each language's table parses and has as many entries as English")
    func everyTableLoads() throws {
        let english = try #require(Self.table("en"))
        for language in ["zh-Hans", "zh-Hant", "ja", "ko", "ru"] {
            let table = try #require(Self.table(language), "\(language) does not parse")
            #expect(table.count == english.count, "\(language)")
        }
    }

    @Test("The app's own lookup returns the translation")
    func lookupIsTranslated() {
        LocalizationSource.use(.chineseSimplified)
        defer { LocalizationSource.use(.system) }
        #expect(String.localized("Close") == "关闭")
    }

    @Test("Application branding preserves translations and argument order", arguments: ["en", "zh-Hans", "zh-Hant", "ja", "ko", "ru"])
    func applicationBranding(language: String) throws {
        let root = try #require(LocalizationSource.moduleBundle.resourceURL)
        let folders = try FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
        let folder = try #require(folders.first {
            $0.lastPathComponent.caseInsensitiveCompare("\(language).lproj") == .orderedSame
        })
        let bundle = try #require(Bundle(url: folder))
        let provider = "Example Browser"
        let repeatedNameMessages = [
            String(localized: "An extension is a program you add yourself that reports one account's usage. \(AppIdentity.name) draws what it prints as a ring, runs it only once you switch it on, and gives it no credentials.", bundle: bundle),
            String(localized: "This is not a feature of Anthropic or OpenAI. Starting usage windows automatically may be treated as getting around usage limits, and could get your account restricted or suspended. \(AppIdentity.name) only sends one short message through the tool you are already signed in to, and is not responsible for anything that happens to your account as a result. Turn it on only if you accept that.", bundle: bundle)
        ]
        for message in repeatedNameMessages {
            #expect(message.contains(AppIdentity.name))
            if language.hasPrefix("zh") {
                #expect(message.components(separatedBy: AppIdentity.name).count == 3)
            }
        }
        let table = try #require(Self.table(language))
        let placeholder = try NSRegularExpression(pattern: #"(?<!%)%(?:(\d+)\$)?@"#)
        for (rawKey, rawValue) in table {
            let key = try #require(rawKey as? String)
            let value = try #require(rawValue as? String)
            let argumentCount = placeholder.numberOfMatches(in: key, range: NSRange(key.startIndex..., in: key))
            var nextArgument = 1
            for match in placeholder.matches(in: value, range: NSRange(value.startIndex..., in: value)) {
                let position: Int
                if let range = Range(match.range(at: 1), in: value) {
                    position = try #require(Int(value[range]))
                } else {
                    position = nextArgument
                    nextArgument += 1
                }
                #expect(position <= argumentCount, "\(language): \(key)")
            }
        }
        let messages = [
            String(localized: "Start \(AppIdentity.name) automatically when you log in.", bundle: bundle),
            String(localized: "Remove \(AppIdentity.name) from the menu bar; use the panel menu or shortcut to open settings.", bundle: bundle),
            String(localized: "This is a test notification. \(AppIdentity.name)'s notifications look like this.", bundle: bundle)
        ]
        for message in messages {
            #expect(message.contains(AppIdentity.name))
            #expect(!message.contains("Pulse"))
        }
        let access = String(localized: "macOS didn't allow \(AppIdentity.name) to read \(provider)'s cookies. In System Settings › Privacy & Security › Full Disk Access, turn on \(AppIdentity.name) (if it is already on, remove it and add it again), then quit and reopen \(AppIdentity.name).", bundle: bundle)
        #expect(access.contains(provider))
        #expect(access.components(separatedBy: AppIdentity.name).count == 4)
        #expect(!access.contains("%@"))
        let schema = String(localized: "Written for extension schema \(String(99)), which this version of \(AppIdentity.name) doesn't read.", bundle: bundle)
        #expect(schema.contains("99"))
        #expect(schema.contains(AppIdentity.name))
        let credit = String(localized: "Based on Pulse by qunqin24, licensed under Apache 2.0. Thank you to the original author and contributors. This independent version is not endorsed by them.", bundle: bundle)
        #expect(credit.contains("Pulse"))
        #expect(credit.contains("qunqin24"))
    }

    /// Pulse's own resource bundle — `Bundle.module` written here would be
    /// the test target's — found by listing it: SwiftPM may lowercase
    /// `zh-Hans.lproj` on the way in, so a lookup by the source spelling can
    /// come up empty.
    private static func table(_ language: String) -> NSDictionary? {
        guard let root = LocalizationSource.moduleBundle.resourceURL,
              let folders = try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil),
              let folder = folders.first(where: {
                  $0.lastPathComponent.caseInsensitiveCompare("\(language).lproj") == .orderedSame
              })
        else { return nil }
        return NSDictionary(contentsOf: folder.appending(path: "Localizable.strings"))
    }
}
