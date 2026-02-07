# APRater

[![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/aporat/APRater/ci.yml?style=flat-square)
[![Codecov](https://img.shields.io/codecov/c/github/aporat/APRater?style=flat-square)](https://codecov.io/github/aporat/APRater)

A lightweight Swift library for intelligently prompting users to review your app on the App Store. APRater tracks app usage and only requests a review when configurable thresholds are met.

## Features

- Tracks app launch count, custom event count, and days since install
- Configurable thresholds for each gate before prompting
- Uses StoreKit's `SKStoreReviewController` for native review prompts
- Direct links to your App Store page and review page
- Built with Swift 6 strict concurrency (`@MainActor`, `Sendable`)
- Persists state across launches with `SwiftyUserDefaults`

## Requirements

- iOS 16.0+
- Swift 6.0+

## Installation

### Swift Package Manager

Add APRater to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aporat/APRater.git", from: "1.0.0")
]
```

Or add it in Xcode via **File > Add Package Dependencies** and enter the repository URL.

## Usage

### Configuration

Configure APRater early in your app lifecycle (e.g. in your `App.init` or `AppDelegate`):

```swift
import APRater

APRater.shared.appId = "123456789"
APRater.shared.usesUntilPrompt = 5      // minimum app launches
APRater.shared.eventsUntilPrompt = 10   // minimum logged events
APRater.shared.daysUntilPrompt = 7      // minimum days since install
```

### Requesting a Review

Call `requestReview()` at natural points in your app. The review prompt only appears when all configured gates are satisfied:

```swift
APRater.shared.requestReview()
```

### Logging Events

Track meaningful user actions that indicate engagement:

```swift
APRater.shared.logEvent()
```

### App Store Links

Open your App Store page or go directly to the review form:

```swift
APRater.shared.showInAppStore()
APRater.shared.reviewInAppStore()
```

## How It Works

APRater uses three configurable gates that must **all** be satisfied before a review prompt is shown:

| Gate | Property | Default | Description |
|------|----------|---------|-------------|
| Uses | `usesUntilPrompt` | 2 | Minimum number of app launches |
| Events | `eventsUntilPrompt` | 4 | Minimum number of logged events |
| Days | `daysUntilPrompt` | 4 | Minimum days since first launch |

Set any gate to `0` to disable it.

## License

APRater is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
