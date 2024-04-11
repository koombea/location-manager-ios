//
//  LocationManager.swift
//  LocationManager
//
// Copyright (c) 2021 Koombea, Inc All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import CoreLocation

public class LocationManager: NSObject {
    
    public static var shared = LocationManager()
    private static var locationManager: CLLocationManager?
    private static var currentLatitude: Double = 0
    private static var currentLongitude: Double = 0
    private static var authorizationCompletion: CheckedContinuation<CLAuthorizationStatus, Never>?
    private static var isAuthorizedAlways: Bool {
        get {
            UserDefaults.standard.bool(forKey: "backgroundLocationEnabled")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "backgroundLocationEnabled")
        }
    }
    
    /// Current authorization status - `CLAuthorizationStatus`
    public static var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            guard authorizationStatus != .notDetermined else { return }
            NotificationCenter.default.post(name: authorizationStatusChanged,
                                            object: authorizationStatus)
        }
    }
    
    /// Current location - `CLLocation`
    public static var currentLocation: CLLocation? {
        guard currentLatitude != 0.0 && currentLongitude != 0.0 else { return nil }
        return CLLocation(latitude: currentLatitude, longitude: currentLongitude)
    }
    
    private override init() { }
    
    /// Use this method to get location authorization
    /// - Parameters:
    ///   - type: Location authorization type (Once, whenInUse,  always)
    @MainActor
    public static func requestAuthorization(for type: LocationAuthorizationType) async -> CLAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            if locationManager == nil {
                let manager = CLLocationManager()
                manager.delegate = shared
                locationManager = manager
            }
            let authorizationStatus = LocationManager.authorizationStatus
            switch type {
            case .once, .whenInUse:
                guard authorizationStatus == .notDetermined else {
                    continuation.resume(returning: authorizationStatus)
                    return
                }
                if type == .once {
                    locationManager?.requestLocation()
                } else {
                    locationManager?.requestWhenInUseAuthorization()
                }
            case .always:
                guard authorizationStatus == .notDetermined || authorizationStatus == .authorizedWhenInUse else {
                    continuation.resume(returning: LocationManager.authorizationStatus)
                    return
                }
                if authorizationStatus == .authorizedWhenInUse && isAuthorizedAlways {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                } else {
                    locationManager?.requestAlwaysAuthorization()
                }
            }
            self.authorizationCompletion = continuation
        }
    }

    private func updateCurrentLocation(_ location: CLLocation? = nil) {
        if let newLocation = location,
            newLocation.coordinate.latitude != 0.0 &&
            newLocation.coordinate.longitude != 0.0 {
            LocationManager.currentLatitude = newLocation.coordinate.latitude
            LocationManager.currentLongitude = newLocation.coordinate.longitude
        }
        LocationManager.authorizationCompletion?.resume(returning: LocationManager.authorizationStatus)
        LocationManager.authorizationCompletion = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        if LocationManager.authorizationStatus != status {
            LocationManager.authorizationStatus = status
        }
        switch status {
        case .restricted, .denied:
            updateCurrentLocation()
        case .authorizedAlways, .authorizedWhenInUse:
            if status == .authorizedAlways && !LocationManager.isAuthorizedAlways {
                LocationManager.isAuthorizedAlways = true
                NotificationCenter.default.post(
                    name: LocationManager.authorizedBackgroundLocation,
                    object: nil
                )
            }
            #if targetEnvironment(simulator) //DEVELOPMENT
            updateCurrentLocation()
            #else
            manager.startUpdatingLocation()
            #endif
        default: break
        }
    }
    
    #if !targetEnvironment(simulator) //!DEVELOPMENT
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        if LocationManager.authorizationCompletion != nil {
            updateCurrentLocation(newLocation)
            return
        }
        guard newLocation.coordinate.latitude != LocationManager.currentLatitude else { return }
        guard newLocation.coordinate.longitude != LocationManager.currentLongitude else { return }
        updateCurrentLocation(newLocation)
        NotificationCenter.default.post(name: LocationManager.locationUpdated, object: newLocation)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if LocationManager.authorizationCompletion != nil {
            updateCurrentLocation()
        }
        if let error = error as? CLError {
            switch error {
            case CLError.locationUnknown:
                return
            default: break
            }
        }
        NotificationCenter.default.post(name: LocationManager.locationManagerDidFail, object: error)
    }
    #endif
}
