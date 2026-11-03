// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
import Foundation

/// Shared by the app and packaging scripts. The former Pulse Pet data identity stays stable.
enum AppIdentity {
    private struct Configuration: Decodable, Sendable {
        let name: String
        let executableName: String
        let bundleIdentifier: String
        let storageDirectory: String
        let urlScheme: String
        let repository: String
    }

    private static let configuration: Configuration = {
        guard let url = Bundle.module.url(forResource: "AppIdentity", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(Configuration.self, from: data)
        else { preconditionFailure("Missing or invalid AppIdentity.json") }
        return value
    }()

    static var name: String { configuration.name }
    static var executableName: String { configuration.executableName }
    static var statusLineExecutableNames: Set<String> { [executableName, "PulsePet"] }
    static var bundleIdentifier: String { configuration.bundleIdentifier }
    static var urlScheme: String { configuration.urlScheme }
    static var repository: String { configuration.repository }
    static var repositoryURL: URL { URL(string: "https://github.com/\(repository)")! }
    static var storageDirectory: URL {
        URL.applicationSupportDirectory.appending(path: configuration.storageDirectory)
    }
    static var defaults: UserDefaults {
        defaults(runningBundleIdentifier: Bundle.main.bundleIdentifier)
    }

    static func defaults(runningBundleIdentifier: String?) -> UserDefaults {
        if runningBundleIdentifier == bundleIdentifier { return .standard }
        return UserDefaults(suiteName: bundleIdentifier)!
    }
    static var loginItemLabel: String { "\(bundleIdentifier).launch-at-login" }
}
