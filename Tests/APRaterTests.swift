import XCTest
@testable import APRater
@preconcurrency import SwiftyUserDefaults
import SwifterSwift

@MainActor
final class APRaterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset persisted values so each test is deterministic
        Defaults[\.APRaterUseCount] = 0
        Defaults[\.APRaterEventCount] = 0
        Defaults[\.APRaterInstalledDate] = nil
    }

    override func tearDown() {
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

        rater.usesUntilPrompt = 3
        XCTAssertFalse(rater.shouldRequestReview)

        Defaults[\.APRaterUseCount] = 2
        XCTAssertFalse(rater.shouldRequestReview)

        Defaults[\.APRaterUseCount] = 3
        XCTAssertTrue(rater.shouldRequestReview)
    }

    // MARK: - Events gate

    func testShouldRequestReview_EventsGate() {
        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -30)

        let rater = APRater()
        rater.usesUntilPrompt = 0
        rater.daysUntilPrompt = 0
        rater.eventsUntilPrompt = 2

        XCTAssertFalse(rater.shouldRequestReview)

        rater.logEvent()
        XCTAssertEqual(Defaults[\.APRaterEventCount], 1)
        XCTAssertFalse(rater.shouldRequestReview)

        rater.logEvent()
        XCTAssertEqual(Defaults[\.APRaterEventCount], 2)
        XCTAssertTrue(rater.shouldRequestReview)
    }

    // MARK: - Days gate

    func testShouldRequestReview_DaysGate() {
        Defaults[\.APRaterUseCount] = 0
        Defaults[\.APRaterEventCount] = 0

        Defaults[\.APRaterInstalledDate] = Date()
        let rater = APRater()
        rater.usesUntilPrompt = 0
        rater.eventsUntilPrompt = 0
        rater.daysUntilPrompt = 3

        XCTAssertFalse(rater.shouldRequestReview, "Should be false until 3 days have passed")

        Defaults[\.APRaterInstalledDate] = Date().adding(.day, value: -4)
        XCTAssertTrue(rater.shouldRequestReview, "Should be true after threshold date")
    }

    // MARK: - Combined gates

    func testShouldRequestReview_AllGatesMustPass() {
        Defaults[\.APRaterInstalledDate] = Date()
        Defaults[\.APRaterEventCount] = 1
        Defaults[\.APRaterUseCount] = 1

        let rater = APRater()
        rater.usesUntilPrompt = 2
        rater.eventsUntilPrompt = 2
        rater.daysUntilPrompt = 2

        XCTAssertFalse(rater.shouldRequestReview)

        Defaults[\.APRaterUseCount] = 2
        XCTAssertFalse(rater.shouldRequestReview)

        Defaults[\.APRaterEventCount] = 2
        XCTAssertFalse(rater.shouldRequestReview)

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
