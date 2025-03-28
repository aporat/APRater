import StoreKit
import SwifterSwift
import SwiftyUserDefaults

extension DefaultsKeys {
    var APRaterEventCount: DefaultsKey<Int> { .init("APRaterEventCount", defaultValue: 0) }
    var APRaterUseCount: DefaultsKey<Int> { .init("APRaterUseCount", defaultValue: 0) }
    var APRaterInstalledDate: DefaultsKey<Date?> { .init("APRaterInstalledDate") }
}

public class APRater {
    public static let shared = APRater()
    public var appId: String?
    public var usesUntilPrompt: Int = 2
    public var eventsUntilPrompt: Int = 4
    public var daysUntilPrompt: Int = 4
    
    public init() {
        if Defaults.APRaterInstalledDate == nil {
            Defaults.APRaterInstalledDate = Date()
        }
        
        Defaults.APRaterUseCount = Defaults.APRaterUseCount + 1
    }
    
    public var debugDescription: String {
        "APRater(APRaterUseCount: \(Defaults.APRaterUseCount), APRaterEventCount: \(Defaults.APRaterEventCount)"
    }
    
    public func logEvent() {
        Defaults.APRaterEventCount = Defaults.APRaterEventCount + 1
    }
    
    public func requestReview() {
        if shouldRequestReview {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    public var shouldRequestReview: Bool {
        if usesUntilPrompt > 0, usesUntilPrompt > Defaults.APRaterUseCount {
            return false
        }
        
        if eventsUntilPrompt > 0, eventsUntilPrompt > Defaults.APRaterEventCount {
            return false
        }
        
        let installDate = Defaults.APRaterInstalledDate
        
        if daysUntilPrompt > 0, var currentInstallDate = installDate {
            currentInstallDate.add(.day, value: daysUntilPrompt)
            
            if currentInstallDate.isInFuture {
                return false
            }
        }
        
        return true
    }
    
    public func showInAppStore() {
        guard let currentAppId = appId else {
            return
        }
        
        if let url = URL(string: String(format: "itms-apps://apps.apple.com/app/id%@", currentAppId)) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    public func reviewInAppStore() {
        guard let currentAppId = appId else {
            return
        }
        
        if let url = URL(string: String(format: "itms-apps://apps.apple.com/app/id%@?action=write-review", currentAppId)) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
