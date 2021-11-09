import XCTest
import Nimble
import CoreLocation

@testable import LocationManager

final class LocationManagerTests: XCTestCase {

    func test_promptForLocationAuthorization() {
        waitUntil(timeout: .seconds(4)) { done in
            LocationManager.promptForLocationAuthorization { status in
                expect(status).to(equal(.restricted))
                done()
            }
        }
    }
    
    func test_authorizationStatusChanges() {
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .authorizedWhenInUse)
        expect(LocationManager.authorizationStatus).to(equal(.authorizedWhenInUse))
        
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .denied)
        expect(LocationManager.authorizationStatus).to(equal(.denied))
    }
}
