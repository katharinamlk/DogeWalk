//
//  ViewController.swift
//  DogeWalk
//
//  Created by Katharina Müllek on 12.03.21.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class CurrentWalkViewController: UIViewController {
    
    @IBOutlet weak var currentWalkMapView: MKMapView!
    @IBOutlet weak var currentWalkCollectionView: UICollectionView!
    // Saving Indicators
    @IBOutlet weak var savingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var greatJobLabel: UILabel!
    @IBOutlet weak var savingLabel: UILabel!
    // Play/Pause/Stop
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseImage: UIImageView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopImage: UIImageView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pressPlayLabel: UILabel!
    // Walkstats
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    // NavigationBar
    @IBOutlet weak var backSelectDogs: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var userLocations: [CLLocation] = []
    var secondCounter = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        currentWalkMapView.delegate = self
        currentWalkMapView.mapType = MKMapType(rawValue: 0)!
        currentWalkMapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        enableButton(play: true, pause: false, stop: false)
    }
    
    
    // Dismiss this ViewController when select Dogs is pressed
    // backSelectDogs must be hidden during the run!
    /*
    @IBAction func backSelectDogsPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 */
    
    // start the distance and time tracking
    
    @IBAction func playButtonPressed(_ sender: Any) {
        pressPlayLabel.isHidden = true
        enableButton(play: false, pause: true, stop: true)
        buttonReaction(play: true, pause: false, stop: false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    @objc func updateTimer() {
        secondCounter = secondCounter + 1
        timeLabel.text = displayTime(seconds: secondCounter)
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        buttonReaction(play: false, pause: true, stop: false)
        enableButton(play: true, pause: false, stop: true)
        stopLocationUpdate()
        timer.invalidate()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        saveIndication()
        buttonReaction(play: false, pause: false, stop: true)
        enableButton(play: false, pause: false, stop: false)
        stopLocationUpdate()
        timer.invalidate()
        // segue to WalkDetailController with the latest walk
    }

//MARK: - Location Service
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // show alert to let user know why they need to enable this
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            currentWalkMapView.showsUserLocation = true
        case.denied:
            // show alert to turn on locationservice
        break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            currentWalkMapView.showsUserLocation = true
        case .restricted:
            // show alert that locationusage is restricted
        break
        case .authorizedAlways:
            break
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
            currentWalkMapView.showsUserLocation = true
        }
    }
    
    func stopLocationUpdate() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    //MARK: - Timer
    func displayTime(seconds:Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds: seconds)
      return ("\(h):\(m):\(s)")
    }
    
    func secondsToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
//MARK: - Button UI
    fileprivate func saveIndication() {
        savingIndicator.startAnimating()
        greatJobLabel.isHidden = false
        savingLabel.isHidden = false
    }
    
    fileprivate func buttonReaction(play: Bool, pause: Bool, stop: Bool) {
        playImage.isHighlighted = play
        pauseImage.isHighlighted = pause
        stopImage.isHighlighted = stop
    }
    
    fileprivate func enableButton(play: Bool, pause: Bool, stop: Bool) {
        playButton.isEnabled = play
        pauseButton.isEnabled = pause
        stopButton.isEnabled = stop
    }
}

//MARK: - MapKit Extension

extension CurrentWalkViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func addPolyLineToMap(locations: [CLLocation]) {
        let coordinates = locations.map({ (location: CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        let polyLine = MKPolyline(coordinates: coordinates, count: locations.count)
        currentWalkMapView.addOverlay(polyLine)
    }
    
    // is called when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentUserLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: currentUserLocation!.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        self.userLocations.append(currentUserLocation!)
        addPolyLineToMap(locations: userLocations)
        currentWalkMapView.setRegion(viewRegion, animated: true)
    }
    
    // This specifies how the map reads the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            polyLineRenderer.strokeColor = #colorLiteral(red: 0.9803921569, green: 0.7568627451, blue: 0.4470588235, alpha: 1)
            polyLineRenderer.lineWidth = 5
            return polyLineRenderer
        }
        return MKOverlayRenderer()
    }

}
