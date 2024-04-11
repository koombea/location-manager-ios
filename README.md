# Location Manager for iOS

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

**Location Manager** is a library written in Swift that makes it easy for you to use Apple CoreLocation services.

## Requirements
- iOS 13.0+ 

## Installation

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

The Package Manager is included in Swift 3.0 and above.

```swift
.package(url: "https://github.com/koombea/location-manager-ios", from: "1.0.0")
```

## The Basics

### Location Authorization

```swift
let status = await LocationManager.requestAuthorization(for: .whenInUse)
```

### Background Location Authorization

It must be used after request `whenInUse` [Read more from Apple Docs](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620551-requestalwaysauthorization)

```swift
let status = await LocationManager.requestAuthorization(for: .always)	
```

### Notifications Observers

```swift 

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                       name: LocationManager.authorizationStatusChanged, object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                       name: LocationManager.locationManagerDidFail, object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                       name: LocationManager.locationUpdated, object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                       name: LocationManager.authorizedBackgroundLocation, object: nil)
```
