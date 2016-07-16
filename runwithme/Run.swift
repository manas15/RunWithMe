
import UIKit
import HealthKit
import CoreLocation
import Firebase
import SwiftyJSON



class Run: UIViewController, UserTerminates {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var buddyDistanceLbl: UILabel!
    @IBOutlet weak var buddyTimeLbl: UILabel!
    @IBOutlet weak var buddyPaceLbl: UILabel!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    
    var seconds = 0.0
    var distance = 0.0
    var withBuddy = 0
    var myRef: Firebase?
    var buddyRef: Firebase?
    var tempMe = "2"
    var tempBuddy = "1"
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        //Movement threshold for new events 
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    
    
    override func viewWillAppear(animated: Bool) {
        //performSegueWithIdentifier("timmerScreen", sender: nil)
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        self.myRef?.setValue(nil)
        
        
    }
    
    
    
    func userWillTerminate() {
        self.myRef?.setValue(nil)
    }
    
    
    override func viewDidLoad() {
        
        startLocationUpdates()
        lookForMyTempBuddy()
    }
    
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func onStartPressed(sender: AnyObject) {
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                       target: self,
                                                       selector: #selector(Run.eachSecond(_:)),
                                                       userInfo: nil,
                                                       repeats: true)
        self.stopBtn.hidden = false
        self.startBtn.hidden = true
        startLocationUpdates()
    }
    
    
    @IBAction func onStopStart(sender: AnyObject) {
        seconds = 0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        self.startBtn.hidden = false
        self.stopBtn.hidden = true
    }
    
    func eachSecond(timer: NSTimer) {
        seconds += 1
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        timeLabel.text = String(seconds)
        
        let distanceQuantity = Double(round(10 * distance)/10)
        distanceLabel.text =  String(distanceQuantity)
        
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = Double(round(10 * (distance / seconds))/10)
        paceLabel.text = String(paceQuantity)
        
        //every 2 sec: get data from server and update ui
        if Int(seconds) % 2 == 1 {
            //2 possible cases
            //tempMe = 1, tempBuddy = 2
            //In this case put data on 1 and get data from 2
            if tempMe == "1" {
                //put data on 1
                self.myRef = Global().rootUrl.childByAppendingPath("1")
                let stats = ["distance": String(distanceQuantity), "pace": String(paceQuantity)]
                self.myRef?.setValue(stats)
                
                
            }
            //tempMe = 2, tempBuddy = 1
            //In this case put data on 2 and get data from1
            if tempMe == "2" {
                //put data on 2
                self.myRef = Global().rootUrl.childByAppendingPath("2")
                let stats = ["distance": String(distanceQuantity), "pace": String(paceQuantity)]
                self.myRef?.setValue(stats)
            }
        }
        lookForMyTempBuddy()
    }
    
    
    
    func lookForMyTempBuddy(){
        if tempMe == "1" {
            
            //get data on 2
            self.buddyRef = Global().rootUrl.childByAppendingPath("2")
            //observe this buddy for any changes
            self.buddyRef?.observeEventType(.Value, withBlock: { snapshot in
                print(snapshot)
                self.buddyDistanceLbl.text = String(snapshot.value.objectForKey("distance")!)
                self.buddyPaceLbl.text = String(snapshot.value.objectForKey("pace")!)
            })
            
        }
        //tempMe = 2, tempBuddy = 1
        //In this case put data on 2 and get data from1
        if tempMe == "2" {
            //get data on 1
            self.buddyRef = Global().rootUrl.childByAppendingPath("1")
            //observe this buddy for any changes
            self.buddyRef?.observeEventType(.Value, withBlock: { snapshot in
                print(snapshot)
                self.buddyDistanceLbl.text = String(snapshot.value.objectForKey("distance")!)
                self.buddyPaceLbl.text = String(snapshot.value.objectForKey("pace")!)
            })
            
        }

    }
    func lookForABuddy() {
        // register yourself as an online user
        self.myRef = Global().online.childByAutoId()
        let userData = ["status": "looking", "distance": "0.0", "pace": "0.0", "buddyRef": "nil", "myRef": String(self.myRef)]
        self.myRef!.setValue(userData)
        
        //observe myself
        self.myRef!.observeEventType(.Value, withBlock: { snapshot in
            
            }, withCancelBlock:  { error in
                print(error.description)
        })
        
        
        // observe another online user
        Global().online.observeEventType(.Value, withBlock: { snapshot in
            var json = JSON(snapshot.value)
            
            //If I don't have a buddy, look  for one
            if self.withBuddy == 0 {
                //Parse the json to find the idle user
                for (key,subJson):(String, JSON) in json {
                    // If I'm still looking for a buddy
                    if self.withBuddy == 0 {
                        //search for idle partner
                        print(subJson)
                        if String(subJson["status"]) == "looking" {
                            //set this as the buddy
                            self.buddyRef = Firebase(url: String(subJson["myRef"]))
                            //Add observer on buddy and feed the ui
                            
                            
                            self.myRef!.childByAppendingPath("status").setValue("found")
                            self.withBuddy = 1
                            

                        }

                    }
                }

            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        // queue algorithm
        
        // pair with him
        
        // run together
    }
    
    @IBAction func onClickRecordBtn(sender: AnyObject) {
        
    }

}
