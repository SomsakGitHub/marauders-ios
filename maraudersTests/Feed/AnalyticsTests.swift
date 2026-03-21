@testable import Marauders
import XCTest

@MainActor
final class AnalyticsTests: XCTestCase {

    func test_trackWatch_flushAfterFive() {

        let analytics = AnalyticsManager.shared

        for i in 0..<5 {
            analytics.trackWatch(id: "\(i)", duration: 5)
        }

        // ดูจาก print หรือ inject mock network
    }
}

