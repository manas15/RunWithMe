
import Foundation
import UIKit
import CoreLocation
import HealthKit

extension Run: CLLocationManagerDelegate {
    // Have to implement delegate methonds, to be notified on location updates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 100 {
                //update distance
                
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                }
                //save location
                self.locations.append(location)
            }
        }
    }
    
    
}