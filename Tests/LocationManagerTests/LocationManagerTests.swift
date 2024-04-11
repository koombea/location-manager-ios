import XCTest
import Nimble
import CoreLocation

@testable import LocationManager

final class LocationManagerTests: XCTestCase {
    
    override func tearDown() async throws {
        LocationManager.authorizationStatus = .notDetermined
    }
    
    func test_requestAuthorization_returns_whenInUse() {
        waitUntil(timeout: .seconds(4)) { done in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                LocationManager.shared.locationManager(
                    CLLocationManager(),
                    didChangeAuthorization: .authorizedWhenInUse
                )
            }
            Task {
                let status = await LocationManager.requestAuthorization(for: .whenInUse)
                expect(status).to(equal(.authorizedWhenInUse))
                done()
            }
        }
    }
    
    func test_requestAuthorization_returns_Always() {
        waitUntil(timeout: .seconds(4)) { done in
            LocationManager.shared.locationManager(
                CLLocationManager(),
                didChangeAuthorization: .authorizedWhenInUse
            )
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                LocationManager.shared.locationManager(
                    CLLocationManager(),
                    didChangeAuthorization: .authorizedAlways
                )
            }
            Task {
                let status = await LocationManager.requestAuthorization(for: .always)
                expect(status).to(equal(.authorizedAlways))
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
    
    func test_invalidCurrentLocation() {
        expect(LocationManager.currentLocation).to(beNil())
    }
}
