//
//  LocationManagerConfiguration.swift
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
import CoreLocation

public struct LocationManagerConfiguration {
    /// iOS automatically prompt permissions if asked from settings
    public var autoPromptLocationAuthorization = false
    public var useDefaultLocation = false
    /// Default Location in case of denied or restricted permissions
    public var defaultLocation = CLLocation(latitude: 40.657537, longitude: -96.661502)
}
