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
dependencies: [
        .package(name: "LocationManager",
                 url: "https://github.com/koombea/location-manager-ios.git", 
                 from: "1.0.0"),
    ],
```

## The Basics

### Get Location Auhtorization

```swift
LocationManager.promptForLocationAuthorization { status in

}	
```

### Background Location

```swift
LocationManager.requestBackgroundLocation()	
```

### Notifications Observers

```swift
NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                               name: LocationManager.authorizationStatus, object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                               name: LocationManager.locationManagerDidFail, object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                               name: LocationManager.locationUpdated, object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(yourSelector),
                                               name: LocationManager.authorizedBackgroundLocation, object: nil)
```