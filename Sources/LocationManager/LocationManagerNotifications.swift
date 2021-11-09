//
//  LocationManagerNotifications.swift
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

import Foundation

public extension LocationManager {
    
    static var authorizationStatusChanged: Notification.Name {
        return Notification.Name(rawValue: "com.locationManager.authorizationStatusChanged")
    }
    
    static var locationManagerDidFail: Notification.Name {
        return Notification.Name(rawValue: "com.locationManager.locationManagerDidFail")
    }

    static var locationUpdated: Notification.Name {
        return Notification.Name(rawValue: "com.locationManager.locationUpdated")
    }
    
    static var authorizedBackgroundLocation: Notification.Name {
        return Notification.Name(rawValue: "com.locationManager.authorizedBackgroundLocation")
    }
}
