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
    private static var authorizationCompletion: ((CLAuthorizationStatus) -> Void)?
    public var configuration = LocationManagerConfiguration()
    
    private static var isBackgroundLocationEnabled: Bool {
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
        return CLLocation(latitude: currentLatitude, longitude: currentLongitude)
    }
    
    private override init() { }
    
    /// Use this method to get location authorization
    /// - Parameters:
    ///   - completion: Completion closure to return location manager Authorization Status.
    public static func promptForLocationAuthorization(_ completion: @escaping ((CLAuthorizationStatus) -> Void)) {
        guard locationManager == nil else { return completion(CLLocationManager.authorizationStatus()) }
        let manager = CLLocationManager()
        manager.delegate = shared
        locationManager = manager
        self.authorizationCompletion = completion
    }

    /// Use this method to get background location authorization, it must be used before `promptForLocationAuthorization`
    public static func requestBackgroundLocation() {
        let status = CLLocationManager.authorizationStatus()
        guard status != .notDetermined else { return }
        if status == .restricted || status == .denied || (
            status == .authorizedWhenInUse && isBackgroundLocationEnabled
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
            return
        }
        locationManager?.requestAlwaysAuthorization()
    }

    private func updateCurrentLocation(_ location: CLLocation? = nil) {
        if let newLocation = location,
            newLocation.coordinate.latitude != 0.0 &&
            newLocation.coordinate.longitude != 0.0 {
            LocationManager.currentLatitude = newLocation.coordinate.latitude
            LocationManager.currentLongitude = newLocation.coordinate.longitude
        } else if configuration.useDefaultLocation {
            let defaultLocation = configuration.defaultLocation
            LocationManager.currentLatitude = defaultLocation.coordinate.latitude
            LocationManager.currentLongitude = defaultLocation.coordinate.longitude
        }
        LocationManager.authorizationCompletion?(LocationManager.authorizationStatus)
        LocationManager.authorizationCompletion = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        print("Location Authorization Status: \(status.rawValue)")
        if LocationManager.authorizationStatus != status {
            LocationManager.authorizationStatus = status
        }
        switch status {
        case .notDetermined:
            print("Asking for location authorization")
            if configuration.autoPromptLocationAuthorization ||
                LocationManager.authorizationCompletion != nil {
                manager.requestWhenInUseAuthorization()
            }
            return
        case .restricted, .denied:
            print("Location services disabled")
            updateCurrentLocation()
        case .authorizedAlways, .authorizedWhenInUse:
            if status == .authorizedAlways {
                if !LocationManager.isBackgroundLocationEnabled {
                    LocationManager.isBackgroundLocationEnabled = true
                    NotificationCenter.default.post(name: LocationManager.authorizedBackgroundLocation,
                                                    object: nil)
                }
            }
            print("Location services enabled")
            #if targetEnvironment(simulator) //DEVELOPMENT
            updateCurrentLocation()
            #else
            manager.startUpdatingLocation()
            #endif
        @unknown default: break
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
