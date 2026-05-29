
//
//  HoleMapViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/14/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

@objc
protocol HoleMapViewControllerDelegate {
    
    @objc optional func toggleTopPanelHoleMap()
    @objc optional func collapseTopPanelHoleMap()
    @objc optional func changeViewHoleMap(_ menu: String)
    @objc optional func handlePanGesture(_ recognizer: UIPanGestureRecognizer)
    
}

class HoleMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    var delegate: HoleMapViewControllerDelegate?
    
    var match: Match!
    var tournament: Tournament!
    
    var mapSet: Bool!
    
    var location: CLLocation!
    var locationManager: CLLocationManager!
    
    var yardagesDisplayed: Bool!
    var locationPressed: CLLocationCoordinate2D!
    var locationGreen: CLLocationCoordinate2D!
    
    @IBOutlet weak var yardCircleButton: UIButton!
    var yardCirclesDisplay = false
    
    let whiteCircle = UIImage(named: "white_circle.png") as UIImage?
    let blackCircle = UIImage(named: "black_circle.png") as UIImage?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        yardCircleButton.layer.cornerRadius = 10
        yardCircleButton.backgroundColor = UIColor.clear
        yardCircleButton.setImage(whiteCircle, for: .normal)
        yardCircleButton.setImage(whiteCircle, for: .selected)
        yardCirclesDisplay = false

        yardagesDisplayed = false
        yardageLabel1.isHidden = true
        yardageLabel2.isHidden = true
        
        self.mapView.delegate = self
        
        // UIApplication.shared.statusBarStyle = .lightContent
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        }
        
        mapView.mapType = MKMapType.satellite
        
        self.location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let latitude:CLLocationDegrees = mapView.centerCoordinate.latitude
        let longitude:CLLocationDegrees = mapView.centerCoordinate.longitude        
        let latDelta:CLLocationDegrees = 0.005
        let lonDelta:CLLocationDegrees = 0.005
        let span:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion.init(center: location, span: span)
        
        mapView.setRegion(region, animated: false)
        
        //setHeading()
        
        // Do any additional setup after loading the view.
        self.holeNumberLabel.text = String(match.getCurrentHole())
        self.holeYardsLabel.text = String(tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getLength())
        self.holeParLabel.text = String(tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getPar())
        
        self.holeYardsToCenterLabel.text = String(Int(round(tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getCenterOfGreen().distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))*1.09361)))
        
        mapSet = false
        
        setHolePin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.delegate?.toggleTopPanelHoleMap?()
        }
        
    }

    @IBAction func yardCircleButtonPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            if self.yardCirclesDisplay {
                self.yardCirclesDisplay = false
                self.yardCircleButton.backgroundColor = UIColor.clear
                self.yardCircleButton.setImage(self.whiteCircle, for: .normal)
                self.yardCircleButton.setImage(self.whiteCircle, for: .selected)
                var removeOverlays = [MKOverlay]()
                let overlays = self.mapView.overlays
                for eachOverlay in overlays {
                    if eachOverlay is MKCircle {
                        removeOverlays.append(eachOverlay)
                    }
                }
                self.mapView.removeOverlays(removeOverlays)
            }
            else {
                self.yardCirclesDisplay = true
                self.yardCircleButton.backgroundColor = UIColor.clear
                self.yardCircleButton.setImage(self.blackCircle, for: .normal)
                self.yardCircleButton.setImage(self.blackCircle, for: .selected)
                self.addRadiusCircle(location: self.location)
            }
        }
    }
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        
        DispatchQueue.main.async {
            if(sender.state == UIGestureRecognizer.State.began)
            {
                //if needed do some initial setup or init of views here
            }
            else if(sender.state == UIGestureRecognizer.State.changed)
            {
                //move your views here.
                let touchLocation = sender.location(in: self.mapView)
                let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
                
                self.drawDistanceLines(locationPressedNow: locationCoordinate)
            }
            else if(sender.state == UIGestureRecognizer.State.ended)
            {
                //else do cleanup
            }
        }
    }

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var yardageLabel1: UILabel!
    @IBOutlet weak var yardageLabel2: UILabel!
    @IBOutlet weak var holeParLabel: UILabel!
    @IBOutlet weak var holeYardsLabel: UILabel!
    @IBOutlet weak var holeNumberLabel: UILabel!
    @IBOutlet weak var holeYardsToCenterLabel: UILabel!
    
    
    @IBOutlet weak var buttonItem: UIButton!
    
    @IBAction func refreshLocation(_ sender: AnyObject) {
        
        if let locationCheck = location {
            let center = CLLocationCoordinate2D(latitude: locationCheck.coordinate.latitude, longitude: locationCheck.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            
            self.mapView.setRegion(region, animated: true)
            
            locationManager.stopUpdatingLocation()
            
            //mapView.setCenter(center, animated: false)
            //setHeading()
            
            drawLine()
            addRadiusCircle(location: locationCheck)
            
            yardageLabel1.isHidden = true
            yardageLabel1.text = ""
            yardageLabel2.isHidden = true
            yardageLabel2.text = ""
            yardagesDisplayed = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last

        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        if !mapSet {
            self.mapView.setRegion(region, animated: true)
            mapSet = true
        }
        
        //setHeading()
        
        self.holeYardsToCenterLabel.text = String(Int(round(tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getCenterOfGreen().distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))*1.09361)))
        drawLine()
        addRadiusCircle(location: location)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    func setHeading() {
        let annotation = MKPointAnnotation()
        let mapCamera = MKMapCamera(lookingAtCenter: tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getCenterOfGreen().coordinate, fromEyeCoordinate: self.location.coordinate, eyeAltitude: 200.0)
        annotation.coordinate = self.location.coordinate
        
        self.mapView.selectAnnotation(annotation, animated: false)
        self.mapView.setCamera(mapCamera, animated: false)
    }
    
    func setHolePin() {
        let dropPin = CustomPointAnnotation()
        dropPin.imageName = "crosshair_32.png"
        dropPin.coordinate = tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getCenterOfGreen().coordinate
        mapView.addAnnotation(dropPin)
        
    }
    
    func drawLine() {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        var pointsToUse: [CLLocationCoordinate2D] = []
        
        pointsToUse += [location.coordinate]
        pointsToUse += [tournament.getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()).getCenterOfGreen().coordinate]
        
        let myPolyline = MKPolyline(coordinates: &pointsToUse, count: pointsToUse.count)
        
        mapView.addOverlay(myPolyline)
        
    }
    
    func findCenterPoint(_lo1: CLLocationCoordinate2D, _loc2: CLLocationCoordinate2D) -> CGPoint {
        var center =  CLLocationCoordinate2D()
        
        center.latitude = (2 * Double(_lo1.latitude) + Double(_loc2.latitude)) / 3
        center.longitude = (2 * Double(_lo1.longitude) + Double(_loc2.longitude)) / 3

        let point = mapView.convert(CLLocationCoordinate2D(latitude:center.latitude,longitude:center.longitude), toPointTo: mapView)
        
        return point
    }
    
    func drawDistanceLines(locationPressedNow: CLLocationCoordinate2D) {
        let overlays = mapView.overlays
        var removeOverlays = [MKOverlay]()
        for eachOverlay in overlays {
            if !(eachOverlay is MKCircle) {
                removeOverlays.append(eachOverlay)
            }
        }
        mapView.removeOverlays(removeOverlays)
        
        var pointsToLocation: [CLLocationCoordinate2D] = []

        let pressedPoint = mapView.convert(locationPressedNow, toPointTo: self.mapView)
        let displayPoint = CGPoint(x: pressedPoint.x, y: (pressedPoint.y - self.mapView.frame.height * 0.075))
        
        let displayLocation = mapView.convert(displayPoint, toCoordinateFrom: mapView)

        self.locationPressed = displayLocation
        self.locationGreen = tournament.getCourseWithName(name: match.getCourse()).getHole(match.getCurrentHole()).centerOfGreen.coordinate
        
        pointsToLocation += [location.coordinate]
        pointsToLocation += [self.locationPressed]
        pointsToLocation += [locationGreen]
        
        
        
        
        let holePolyline = MKPolyline(coordinates: &pointsToLocation, count: pointsToLocation.count)
        
        let locationPressedLocation = CLLocation(latitude: locationPressed.latitude, longitude: locationPressed.longitude)
        
        let yardsToPoint = String(Int(location.distance(from: locationPressedLocation)*1.09361))
        let yardsToGreen = String(Int(locationPressedLocation.distance(from: tournament.getCourseWithName(name: match.getCourse()).getHole(match.getCurrentHole()).centerOfGreen)*1.09361))
        
        self.yardageLabel1.text = yardsToGreen
        self.yardageLabel2.text = yardsToPoint
        setYardageLabel1()
        setYardageLabel2()
        
        
        yardagesDisplayed = true

        mapView.addOverlay(holePolyline)
        locationManager.stopUpdatingLocation()
        
    }
    
    func setYardageLabel1() {
        let yardsToGreenLoc = findCenterPoint(_lo1: locationGreen, _loc2: locationPressed)
        var frame = yardageLabel1.frame
        frame.origin.y = yardsToGreenLoc.y //pass the cordinate which you want
        frame.origin.x = yardsToGreenLoc.x //pass the cordinate which you want
        yardageLabel1.frame = frame
        yardageLabel1.isHidden = false
    }
    
    func setYardageLabel2() {
        let yardsToPointLoc = findCenterPoint(_lo1: locationPressed, _loc2: location.coordinate)
        var frame2 = yardageLabel2.frame
        frame2.origin.y = yardsToPointLoc.y //pass the cordinate which you want
        frame2.origin.x = yardsToPointLoc.x //pass the cordinate which you want
        yardageLabel2.frame = frame2
        yardageLabel2.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is CustomPointAnnotation) {
            let reuseId = "test"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView!.canShowCallout = true
            }
            else {
                anView!.annotation = annotation
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            let cpa = annotation as! CustomPointAnnotation
            anView!.image = UIImage(named:cpa.imageName)
            
            return anView
        }
        else {
            return nil
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.white
            lineView.lineWidth = 1
            
            return lineView
        }
        else if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            if let title = overlay.title {
                if title == "100y" {
                    circle.strokeColor = UIColor.red
                    //circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
                    circle.lineWidth = 1
                    return circle
                }
                else if title == "150y" {
                    circle.strokeColor = UIColor.white
                    //circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
                    circle.lineWidth = 1
                    return circle
                }
                else if title == "200y" {
                    circle.strokeColor = UIColor.yellow
                    //circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
                    circle.lineWidth = 1
                    return circle
                }
                else {
                    return MKPolylineRenderer()
                }
            }
            else {
                return MKPolylineRenderer()
            }
        }
        else {
            return MKPolylineRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        DispatchQueue.main.async {
            if self.yardagesDisplayed == true {
                self.setYardageLabel1()
                self.setYardageLabel2()
            }
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DispatchQueue.main.async {
            if self.yardagesDisplayed == true {
                self.setYardageLabel1()
                self.setYardageLabel2()
            }
        }
    }
    
    func addRadiusCircle(location: CLLocation){
        if yardCirclesDisplay {
            self.mapView.delegate = self
            let circle100 = MKCircle(center: location.coordinate, radius: 100/1.09361 as CLLocationDistance)
            circle100.title = "100y"
            self.mapView.addOverlay(circle100)
            
            let circle150 = MKCircle(center: location.coordinate, radius: 150/1.09361 as CLLocationDistance)
            circle150.title = "150y"
            self.mapView.addOverlay(circle150)
            
            let circle200 = MKCircle(center: location.coordinate, radius: 200/1.09361 as CLLocationDistance)
            circle200.title = "200y"
            self.mapView.addOverlay(circle200)
        }
    }
    
}

extension HoleMapViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelHoleMap?()
        delegate?.changeViewHoleMap?(menu)
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

