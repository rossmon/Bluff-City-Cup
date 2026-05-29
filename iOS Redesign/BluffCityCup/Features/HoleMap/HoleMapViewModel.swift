import Foundation
import CoreLocation
import MapKit

/// Drives HoleMapView. Manages CLLocationManager and computes distance to green.
@MainActor
final class HoleMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Published

    @Published var userLocation: CLLocation?
    @Published var distanceToGreenYards: Int?
    @Published var showYardCircles: Bool = false
    @Published var mapRegion: MKCoordinateRegion
    @Published var viewingHoleNumber: Int
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Match / Tournament

    let match: Match
    let tournament: Tournament

    // MARK: - Private

    private var locationManager: CLLocationManager?
    private var mapInitialized = false

    // MARK: - Init

    init(match: Match, tournament: Tournament) {
        self.match      = match
        self.tournament = tournament

        // Start on current hole (or final if completed)
        let startHole = match.isCompleted ? match.finalHole : match.currentHole
        self.viewingHoleNumber = max(1, startHole)

        // Default region centred on green
        let holeNum = max(1, startHole)
        let greenCoord = tournament.course(named: match.courseName)?
            .hole(holeNum).greenCenter
            ?? CLLocationCoordinate2D(latitude: 35.15, longitude: -90.05)

        self.mapRegion = MKCoordinateRegion(
            center: greenCoord,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )

        super.init()
        startLocationUpdates()
    }

    // MARK: - Computed

    var currentHole: Hole? {
        tournament.course(named: match.courseName)?.hole(viewingHoleNumber)
    }

    var greenCoordinate: CLLocationCoordinate2D? {
        currentHole?.greenCenter
    }

    var canGoPrev: Bool { viewingHoleNumber > 1 }
    var canGoNext: Bool { viewingHoleNumber < 18 }

    // MARK: - Hole navigation

    func goPrev() {
        guard canGoPrev else { return }
        viewingHoleNumber -= 1
        centreOnGreen()
        updateDistance()
    }

    func goNext() {
        guard canGoNext else { return }
        viewingHoleNumber += 1
        centreOnGreen()
        updateDistance()
    }

    // MARK: - Circles toggle

    func toggleYardCircles() {
        showYardCircles.toggle()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.userLocation = loc
            if !self.mapInitialized {
                self.mapRegion = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                )
                self.mapInitialized = true
            }
            self.updateDistance()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }

    // MARK: - Private

    private func startLocationUpdates() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation()
        }
    }

    private func centreOnGreen() {
        guard let green = greenCoordinate else { return }
        mapRegion = MKCoordinateRegion(
            center: green,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
    }

    private func updateDistance() {
        guard let userLoc = userLocation, let green = greenCoordinate else {
            distanceToGreenYards = nil
            return
        }
        let greenLocation = CLLocation(latitude: green.latitude, longitude: green.longitude)
        let metres = userLoc.distance(from: greenLocation)
        distanceToGreenYards = Int((metres * 1.09361).rounded())
    }

    /// Yard radii for the distance circles overlay (100, 150, 200 yds in metres).
    static let circleRadii: [Double] = [91.44, 137.16, 182.88]
}
