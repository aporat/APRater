import StoreKit
import SwifterSwift
@preconcurrency import SwiftyUserDefaults
import UIKit

// MARK: - UserDefaults Keys

extension DefaultsKeys {
    var APRaterEventCount: DefaultsKey<Int> { .init("APRaterEventCount", defaultValue: 0) }
    var APRaterUseCount: DefaultsKey<Int> { .init("APRaterUseCount", defaultValue: 0) }
    var APRaterInstalledDate: DefaultsKey<Date?> { .init("APRaterInstalledDate") }
}

// MARK: - APRater

@MainActor
public final class APRater: CustomDebugStringConvertible {

    public static let shared = APRater()

    // MARK: Configuration

    public var appId: String?
    public var usesUntilPrompt: Int = 2
    public var eventsUntilPrompt: Int = 4
    public var daysUntilPrompt: Int = 4

    // MARK: Lifecycle

    public init() {
        if Defaults.APRaterInstalledDate == nil {
            Defaults.APRaterInstalledDate = Date()
        }
        Defaults.APRaterUseCount += 1
    }

    // MARK: Public

    public nonisolated var debugDescription: String {
        MainActor.assumeIsolated {
            "APRater(APRaterUseCount: \(Defaults.APRaterUseCount), APRaterEventCount: \(Defaults.APRaterEventCount))"
        }
    }

    public func logEvent() {
        Defaults.APRaterEventCount += 1
    }

    public func requestReview() {
        guard shouldRequestReview else { return }
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    public var shouldRequestReview: Bool {
        if usesUntilPrompt > 0, Defaults.APRaterUseCount < usesUntilPrompt {
            return false
        }

        if eventsUntilPrompt > 0, Defaults.APRaterEventCount < eventsUntilPrompt {
            return false
        }

        if daysUntilPrompt > 0, let installDate = Defaults.APRaterInstalledDate {
            let threshold = installDate.adding(.day, value: daysUntilPrompt)
            if Date() < threshold {
                return false
            }
        }

        return true
    }

    public func showInAppStore() {
        guard let currentAppId = appId,
              let url = URL(string: "itms-apps://apps.apple.com/app/id\(currentAppId)") else { return }
        UIApplication.shared.open(url, options: [:])
    }

    public func reviewInAppStore() {
        guard let currentAppId = appId,
              let url = URL(string: "itms-apps://apps.apple.com/app/id\(currentAppId)?action=write-review") else { return }
        UIApplication.shared.open(url, options: [:])
    }
}
