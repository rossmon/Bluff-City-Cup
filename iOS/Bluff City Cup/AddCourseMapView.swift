//
//  AddCourseMapView.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 1/25/17.
//  Copyright © 2017 Jumpstop Creations. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class AddCourseMapView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    private static let bccBlue = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
    private static let bccRed = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1.0)
    private static let textColor = UIColor(red: 0.071, green: 0.082, blue: 0.102, alpha: 1.0)
    private static let secondarySurfaceColor = UIColor(red: 0.957, green: 0.965, blue: 0.976, alpha: 1.0)
    
    var delegate: HoleMapViewControllerDelegate?
    
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearch.Request!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearch.Response!
    var error:NSError!
    
    var location: CLLocation!
    var locationManager: CLLocationManager!
    
    var dropPin = MKPointAnnotation()
    
    var holes = [(number: Int, handicap: Int, length: Int, par: Int, location: CLLocation)]()
    
    @IBOutlet weak var holeInfoView: UIView!
    @IBOutlet weak var holeInfoLabel: UILabel!
    
    @IBOutlet weak var holeHandicapField: UITextField!
    @IBOutlet weak var holeParSegmentedControl: UISegmentedControl!
    @IBOutlet weak var holeLengthField: UITextField!
    
    @IBOutlet weak var courseNameView: UIView!
    @IBOutlet weak var courseNameField: UITextField!
    @IBOutlet weak var teesField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var courseSlopeField: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    var mapSet: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holes = [(number: Int, handicap: Int, length: Int, par: Int, location: CLLocation)]()
        
        self.holeHandicapField.delegate = self
        self.courseNameField.delegate = self
        self.holeLengthField.delegate = self
        self.teesField.delegate = self
        self.courseSlopeField.delegate = self
                
        blurView.isHidden = true
        holeInfoView.isHidden = true
        courseNameView.isHidden = true
        
        navigationItem.title = "Add Course"
        configureNavigationAppearance()
        applyDesignPass()
        
        let newBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AddCourseMapView.showSearchBar))
        self.navigationItem.setRightBarButton(newBarButton, animated: true)
        //    UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Selector("btnOpenCamera"))
        
        self.mapView.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        mapView.mapType = MKMapType.hybrid
        
        self.location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let latitude:CLLocationDegrees = mapView.centerCoordinate.latitude
        let longitude:CLLocationDegrees = mapView.centerCoordinate.longitude
        let latDelta:CLLocationDegrees = 0.005
        let lonDelta:CLLocationDegrees = 0.005
        let span:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion.init(center: location, span: span)
        
        mapView.setRegion(region, animated: false)
        
        dropPin.coordinate = location
        dropPin.title = "Set Hole 1 Green"
        
        mapView.addAnnotation(dropPin)
        mapView.selectAnnotation(dropPin, animated: false)
        
        // Do any additional setup after loading the view.        
        mapSet = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyDesignPass()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func holeInfoCancelPressed(_ sender: Any) {
        holeInfoView.isHidden = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        holeHandicapField.text = nil
        holeLengthField.text = nil
        
        blurView.isHidden = true
        
    }
    @IBAction func holeInfoSavePressed(_ sender: Any) {
        print("Hole Info Pressed")
        
        let holeLength = Int(holeLengthField.text!)
        let holeHandicap = Int(holeHandicapField.text!)
        let holePar = Int(holeParSegmentedControl.titleForSegment(at: holeParSegmentedControl.selectedSegmentIndex)!)
        
        if holeLength == nil || holeHandicap == nil {

            let alert = UIAlertController(title: "Oops!", message: "Enter a valid handicap and and hole length.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
        }
        else {
            if holeHandicap! > 18 || holeHandicap! == 0 {
                let alert = UIAlertController(title: "Oops!", message: "Enter a handicap between 1 and 18.", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                }))
                
                present(alert, animated: true, completion: nil)
            }
            else {
                
                holes.append((number: holes.count + 1, handicap: holeHandicap!, length: holeLength!, par: holePar!,  location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)))
                
                dropPin.title = "Set Hole \(holes.count + 1) Green"
                
                holeInfoView.isHidden = true
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                
                holeHandicapField.text = nil
                holeLengthField.text = nil
                
                if holes.count == 18 {
                    courseNameView.isHidden = false
                }
                else {
                    blurView.isHidden = true
                }
            }
        }
    }
    
    func addPressed() {
        print("Add Pressed")
        
        blurView.isHidden = false
        
        if holes.count == 18 {
            courseNameView.isHidden = false
        }
        else {
            holeInfoView.isHidden = false
            holeInfoLabel.text = "Enter Hole \(holes.count + 1) info:"
        }
    }
    
    @objc func showSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        /*
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }*/
        //2
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            /*
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
             */
            let center = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            
            self.mapView.setRegion(region, animated: true)
            
            self.dropPin.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            /*
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            */
        }
    }
    
    @IBAction func saveCoursePressed(_ sender: Any) {
        if let courseName = courseNameField.text,
                let courseTees = teesField.text,
                let slope = Int(courseSlopeField.text!) {
            
            Model.sharedInstance.addCourse(holes: self.holes, courseName: courseName, tees: courseTees, slope: slope)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            
            courseNameView.isHidden = true
            blurView.isHidden = true
            
            self.viewDidLoad()
        }
        else {
            let alert = UIAlertController(title: "Oops!", message: "Enter a correct course name, tee, and slope.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
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
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: restorationIdentifier)
        view.canShowCallout = true
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            addPressed()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        dropPin.coordinate = mapView.centerCoordinate;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()  //if desired
        
        self.view.endEditing(true)
        
        return false
    }
    
    /*
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
        
    }
    
    private func textFieldDidBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

private extension AddCourseMapView {
    
    func configureNavigationAppearance() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AddCourseMapView.bccBlue
        appearance.titleTextAttributes = titleAttributes
        appearance.shadowColor = UIColor.clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    func applyDesignPass() {
        styleModal(holeInfoView)
        styleModal(courseNameView)
        
        [holeInfoLabel].forEach { styleTitleLabel($0) }
        labels(in: holeInfoView).filter { $0 !== holeInfoLabel }.forEach { styleFieldLabel($0) }
        labels(in: courseNameView).forEach { styleTitleLabel($0) }
        
        [holeHandicapField, holeLengthField, courseNameField, teesField, courseSlopeField].forEach { styleTextField($0) }
        holeHandicapField.keyboardType = .numberPad
        holeLengthField.keyboardType = .numberPad
        courseSlopeField.keyboardType = .numberPad
        
        styleSegmentedControl(holeParSegmentedControl)
        buttons(in: holeInfoView).forEach { styleButton($0) }
        buttons(in: courseNameView).forEach { styleButton($0) }
    }
    
    func styleModal(_ modal: UIView) {
        modal.backgroundColor = UIColor.white
        modal.layer.cornerRadius = 12
        modal.layer.masksToBounds = false
        modal.layer.shadowColor = UIColor.black.cgColor
        modal.layer.shadowOpacity = 0.22
        modal.layer.shadowOffset = CGSize(width: 0, height: 8)
        modal.layer.shadowRadius = 18
    }
    
    func styleTitleLabel(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = AddCourseMapView.textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
    }
    
    func styleFieldLabel(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = AddCourseMapView.textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
    }
    
    func styleTextField(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = AddCourseMapView.secondarySurfaceColor
        textField.textColor = AddCourseMapView.textColor
        textField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.871, green: 0.890, blue: 0.922, alpha: 1.0).cgColor
        textField.clearButtonMode = .whileEditing
    }
    
    func styleSegmentedControl(_ segmentedControl: UISegmentedControl) {
        segmentedControl.tintColor = AddCourseMapView.bccBlue
        segmentedControl.layer.cornerRadius = 8
        
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = AddCourseMapView.bccBlue
        }
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            NSAttributedString.Key.foregroundColor: AddCourseMapView.textColor
        ], for: .normal)
    }
    
    func styleButton(_ button: UIButton) {
        let title = button.title(for: .normal) ?? ""
        let isSave = title == "Save"
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(isSave ? UIColor.white : AddCourseMapView.bccBlue, for: .normal)
        button.backgroundColor = isSave ? AddCourseMapView.bccBlue : AddCourseMapView.bccBlue.withAlphaComponent(0.10)
        button.layer.cornerRadius = 8
    }
    
    func labels(in view: UIView) -> [UILabel] {
        return view.subviews.flatMap { subview -> [UILabel] in
            var result = labels(in: subview)
            if let label = subview as? UILabel {
                result.append(label)
            }
            return result
        }
    }
    
    func buttons(in view: UIView) -> [UIButton] {
        return view.subviews.flatMap { subview -> [UIButton] in
            var result = buttons(in: subview)
            if let button = subview as? UIButton {
                result.append(button)
            }
            return result
        }
    }
}
