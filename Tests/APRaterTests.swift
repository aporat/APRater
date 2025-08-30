import XCTest
@testable import APRater
import SwiftyUserDefaults
import SwifterSwift

final class APRaterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset persisted values so each test is deterministic
        Defaults[\.APRaterUseCount] = 0
        Defaults[\.APRaterEventCount] = 0
        Defaults[\.APRaterInstalledDate] = nil
    }

    override func tearDown() {
        // Clean up any persisted state
        Defaults[\.APRaterUseCount] = 0
        Defaults[\.APRaterEventCount] = 0
        Defaults[\.APRaterInstalledDate] = nil
        super.tearDown()
    }

    // MARK: - Init side effect

    func testInitIncrementsUseCount() {
        XCTAssertEqual(Defaults[\.APRaterUseCount], 0)
        _ = APRater() // init should set install date (if nil) and +1 use
        XCTAssertEqual(Defaults[\.APRaterUseCount], 1)
        XCTAssertNotNil(Defaults[\.APRaterInstalledDate])
    }

    // MARK: - Uses gate

    func testShouldRequestReview_UsesGate() {
        // Disable other gates
        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -30)
        let rater = APRater()
        rater.eventsUntilPrompt = 0
        rater.daysUntilPrompt = 0

        // Set a threshold higher than current uses
        rater.usesUntilPrompt = 3
        // After init, use count is 1 -> should be false
        XCTAssertFalse(rater.shouldRequestReview)

        // Simulate more uses
        Defaults[\.APRaterUseCount] = 2
        XCTAssertFalse(rater.shouldRequestReview)

        Defaults[\.APRaterUseCount] = 3
        XCTAssertTrue(rater.shouldRequestReview)
    }

    // MARK: - Events gate

    func testShouldRequestReview_EventsGate() {
        // Disable other gates
        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -30)
        let rater = APRater()
        rater.usesUntilPrompt = 0
        rater.daysUntilPrompt = 0
        rater.eventsUntilPrompt = 2

        // Start at 0 events
        XCTAssertFalse(rater.shouldRequestReview)

        // 1 event still below threshold
        rater.logEvent()
        XCTAssertEqual(Defaults[\.APRaterEventCount], 1)
        XCTAssertFalse(rater.shouldRequestReview)

        // 2 events meets threshold
        rater.logEvent()
        XCTAssertEqual(Defaults[\.APRaterEventCount], 2)
        XCTAssertTrue(rater.shouldRequestReview)
    }

    // MARK: - Days gate

    func testShouldRequestReview_DaysGate() {
        // Keep uses/events disabled so only days gate applies
        Defaults[\.APRaterUseCount] = 0
        Defaults[\.APRaterEventCount] = 0

        // Install "now" -> not enough days yet
        Defaults[\.APRaterInstalledDate] = Date()
        let rater = APRater()
        rater.usesUntilPrompt = 0
        rater.eventsUntilPrompt = 0
        rater.daysUntilPrompt = 3

        XCTAssertFalse(rater.shouldRequestReview, "Should be false until 3 days have passed")

        // Move install date into the past beyond the threshold
        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -4)
        XCTAssertTrue(rater.shouldRequestReview, "Should be true after threshold date")
    }

    // MARK: - Combined gates

    func testShouldRequestReview_AllGatesMustPass() {
        // Fresh install, no events yet
        Defaults[\.APRaterInstalledDate] = Date()
        Defaults[\.APRaterEventCount] = 1
        Defaults[\.APRaterUseCount] = 1

        let rater = APRater()
        rater.usesUntilPrompt = 2
        rater.eventsUntilPrompt = 2
        rater.daysUntilPrompt = 2

        // Not enough uses, not enough events, not enough days
        XCTAssertFalse(rater.shouldRequestReview)

        // Satisfy uses
        Defaults[\.APRaterUseCount] = 2
        XCTAssertFalse(rater.shouldRequestReview)

        // Satisfy events
        Defaults[\.APRaterEventCount] = 2
        XCTAssertFalse(rater.shouldRequestReview)

        // Satisfy days
        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -3)
        XCTAssertTrue(rater.shouldRequestReview)
    }

    // MARK: - Debug string

    func testDebugDescriptionContainsCounts() {
        Defaults[\.APRaterUseCount] = 5
        Defaults[\.APRaterEventCount] = 7
        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -10)

        let rater = APRater()
        let desc = rater.debugDescription
        XCTAssertTrue(desc.contains("APRaterUseCount: \(Defaults[\.APRaterUseCount])"))
        XCTAssertTrue(desc.contains("APRaterEventCount: \(Defaults[\.APRaterEventCount])"))
    }
}
