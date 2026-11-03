import Foundation
import Testing
@testable import Pulse

@Suite("Custom warning percentages")
struct AlertThresholdTests {
    @Test("Existing presets and off keep their stored integers")
    func presets() {
        #expect(AlertThreshold.presets.map(\.rawValue) == [0, 75, 80, 90, 95])
        #expect(AlertThreshold.default == .off)
        #expect(AlertThreshold.off.percent == nil)
    }

    @Test("Every whole percentage is accepted", arguments: 1...100)
    func percentages(_ value: Int) throws {
        let threshold = try #require(AlertThreshold(rawValue: value))
        #expect(threshold.percent == value)
        #expect(threshold.title == "\(value)%")
        #expect(AlertThreshold(percentText: String(value)) == threshold)
    }

    @Test("Invalid stored percentages are rejected", arguments: [-1, 101, Int.min, Int.max])
    func invalidRaw(_ value: Int) {
        #expect(AlertThreshold(rawValue: value) == nil)
    }

    @Test("Invalid input cannot turn alerts off or overwrite a threshold", arguments: [
        "", " ", "0", "-1", "101", "83.5", "83%", "abc", "1e2", "999999999999999999999999"
    ])
    func invalidInput(_ value: String) {
        #expect(AlertThreshold(percentText: value) == nil)
    }

    @Test("Surrounding whitespace is harmless")
    func whitespace() {
        #expect(AlertThreshold(percentText: " 83\n")?.rawValue == 83)
    }
}
