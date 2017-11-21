//
//  HomeController.swift
//  Pace
//
//  Created by Ben Porter on 9/21/17.
//  Copyright © 2017 Ben Porter. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeController: UIViewController {

    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblPace: UILabel!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var gpsView: UIView!
    @IBOutlet weak var statView: UIView!
    @IBOutlet weak var StatViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusBarBlurHeight: NSLayoutConstraint!
    @IBOutlet weak var GPSViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnResume: UIButton!
    @IBOutlet weak var btnFinish: UIButton!
    @IBOutlet weak var btnView: UIView!
    
    var run: Run!
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var savedDistance = 0.0
    private var savedTime = 0

    
    
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .default
        
        btnResume.layer.cornerRadius = btnResume.frame.width / 2
        btnResume.layer.borderWidth = 2
        btnResume.layer.borderColor = UIColor.JustRunning.purple.cgColor
        btnResume.isHidden = true
        btnResume.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        btnResume.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnResume.layer.shadowRadius = 2
        btnResume.layer.shadowColor = UIColor.black.cgColor
        btnResume.layer.shadowOpacity = 0.25
        
        btnFinish.layer.cornerRadius = btnFinish.frame.width / 2
        btnFinish.isHidden = true
        btnFinish.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        btnFinish.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnFinish.layer.shadowRadius = 2
        btnFinish.layer.shadowColor = UIColor.black.cgColor
        btnFinish.layer.shadowOpacity = 0.25
        
        
        btnStop.layer.cornerRadius = btnStop.frame.width / 2
        btnStop.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnStop.layer.shadowRadius = 3
        btnStop.layer.shadowColor = UIColor.black.cgColor
        btnStop.layer.shadowOpacity = 0.35
        btnStop.isHidden = true
        
        btnGo.layer.cornerRadius = btnGo.frame.width / 2
        btnGo.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnGo.layer.shadowRadius = 3
        btnGo.layer.shadowColor = UIColor.black.cgColor
        btnGo.layer.shadowOpacity = 0.35
        
        gpsView.isHidden = true
        
        statView.isHidden = true
        statView.layer.cornerRadius = 20
        statView.layer.masksToBounds = false
        statView.layer.shadowOffset = CGSize(width: 1, height: -3)
        statView.layer.shadowColor = UIColor.black.cgColor
        statView.layer.shadowRadius = 1
        statView.layer.shadowOpacity = 0.2
        
        btnView.layer.cornerRadius = 20
        btnView.layer.masksToBounds = false
        btnView.layer.shadowOffset = CGSize(width: 1, height: -3)
        btnView.layer.shadowColor = UIColor.black.cgColor
        btnView.layer.shadowRadius = 1
        btnView.layer.shadowOpacity = 0.2

        StatViewHeight.constant = 0
        GPSViewHeight.constant = 0
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                //iPhone x
                statusBarBlurHeight.constant = 44
            default:
                statusBarBlurHeight.constant = 20
            }
        }
        
        //Inital ask:
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
            
        // for ios 10 and lower
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Map
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 1)!
        mapView.tintColor = UIColor.JustRunning.purple
        
        checkLocationServices()
       
       
        super.viewDidLoad()
    }
    
    func checkLocationServices() {
        // If location services allowed
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                UIView.animate(withDuration: 0.5, animations: {
                    self.gpsView.isHidden = false
                    self.GPSViewHeight.constant = 44
                    self.view.layoutIfNeeded()
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.gpsView.isHidden = true
                        self.GPSViewHeight.constant = 0
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func startAction() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            
            // for ios 10 and lower
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            break
            
        case .restricted, .denied:
            
            let actionSheetController: UIAlertController = UIAlertController(title: "Location Services", message: "You have not allowed access to your location, Just Running needs your location to track runs.", preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
                
                //Takse user to settings
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            actionSheetController.addAction(okAction)
            actionSheetController.addAction(cancelAction)
            
            self.present(actionSheetController, animated: true, completion: nil)

            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
            btnGo.isHidden = true
            btnStop.isHidden = false
            animateStatView()
            
            mapView.removeOverlays(mapView.overlays)
            
            seconds = 0
            distance = Measurement(value: 0, unit: UnitLength.meters)
            locationList.removeAll()
            updateDisplay()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.eachSecond()
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            tabBarController?.setTabBarVisible(visible: false, duration: 0.25, animated: true)
            startLocationUpdates()
            break
        }
        
       
    }
    
    
    //More of a pause
    @IBAction func stopAction() {
        
        btnFinish.isHidden = false
        btnStop.isHidden = true
        btnResume.isHidden = false
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 6.0,
                       options: .allowUserInteraction, animations: { [weak self] in
                        self!.btnResume.transform = .identity
                        self!.btnFinish.transform = .identity
            }, completion: nil)
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Pause actions
        locationManager.stopUpdatingLocation()
        stopTimer()
        
        var formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        let stringTime = FormatDisplay.timeSeconds(seconds)
        
        lblMiles.text = "\(formattedDistance)"
        lblTime.text = "\(formattedTime)"
        lblPace.text = "\(formattedPace)"
        
        //Distance
        let removeString = " mi"
        if let range = formattedDistance.range(of: removeString) {
            formattedDistance.removeSubrange(range)
        }
        let distanceDouble = Double(formattedDistance)
        savedDistance = distanceDouble! * 1609.344
        
        //Time
        savedTime = Int(stringTime)!
    }
    
    @IBAction func btnResumeAction(_ sender: Any) {
        //Hide resume and finish
        btnFinish.isHidden = true
        btnResume.isHidden = true
        btnStop.isHidden = false
        btnResume.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        btnFinish.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        distance = Measurement(value: savedDistance, unit: UnitLength.meters)
        seconds = savedTime
        
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func btnFinishAction(_ sender: Any) {
        if locationList.count == 0 {
            let alert = UIAlertController(title: "🏃YOU GOTTA MOVE!",
                                          message: "Sorry, you have not moved so this 'run' is not going to be saved. Next time try to move a bit more!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            
            resetView()
            
        }else {
            saveRun()
            resetView()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func resetView() {
        tabBarController?.setTabBarVisible(visible: true, duration: 0.25, animated: true)
        btnFinish.isHidden = true
        btnStop.isHidden = true
        btnResume.isHidden = true
        btnGo.isHidden = false
        deAnimateStatView()
        
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func deAnimateStatView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.btnView.layer.shadowOpacity = 0.2
            self.StatViewHeight.constant = 0
            self.statView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    func animateStatView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.statView.isHidden = false
            self.btnView.layer.shadowOpacity = 0
            self.StatViewHeight.constant = 160
            self.view.layoutIfNeeded()
        })
    }
   
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        
        lblMiles.text = "\(formattedDistance)"
        lblTime.text = "\(formattedTime)"
        lblPace.text = "\(formattedPace)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 8
        locationManager.startUpdatingLocation()
    }
    
    private func saveRun() {
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        CoreDataStack.saveContext()
        //run = newRun
    }
}

// MARK: - Location Manager Delegate

extension HomeController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
                mapView.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
        
        if UIApplication.shared.applicationState == .background {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
    }
}

// MARK: - Map View Delegate

extension HomeController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.JustRunning.purple
        renderer.lineWidth = 6
        return renderer
    }
}

//USAGE: .roundCorners([.topLeft, .bottomRight], radius: 10)

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UIColor {
    struct JustRunning {
        static let purple = UIColor(hex: "692AC6")
    }
}

extension UITabBarController {
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        // animation
        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
            }.startAnimation()
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
    }
}




