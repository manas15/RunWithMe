
import UIKit
import MapKit


class HomeVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var imgRunBtn: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
    
        // Ask for Authorisation from the User.
        self.locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
        }

    }

    override func viewWillAppear(animated: Bool) {
        locationAuthStatus()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let centre:CLLocationCoordinate2D = manager.location!.coordinate
        let getLat: CLLocationDegrees = centre.latitude
        let getLon: CLLocationDegrees = centre.longitude
        
        
        let getMovedMapCenter: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
        
        centerMapOnLocation(getMovedMapCenter)
        

    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            map.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            centerMapOnLocation(loc)
            
        }
    }
    
    @IBAction func onClickRun(sender: AnyObject) {
        performSegueWithIdentifier("runScreen", sender: self)
    }
    
    
}
