import SwiftUI
import MapKit

struct HoleMapView: View {
    @StateObject private var vm: HoleMapViewModel

    init(match: Match, tournament: Tournament) {
        _vm = StateObject(wrappedValue: HoleMapViewModel(match: match, tournament: tournament))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Satellite map via UIViewRepresentable (iOS 16 compatible)
            SatelliteMapView(vm: vm)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                holeInfoOverlay
                Spacer()
                bottomControls
            }
        }
    }

    // MARK: - Hole info overlay (top)

    private var holeInfoOverlay: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hole \(vm.viewingHoleNumber)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                if let hole = vm.currentHole {
                    Text("Par \(hole.par)  ·  \(hole.length) yds  ·  Hdcp \(hole.handicapIndex)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }

            Spacer()

            if let dist = vm.distanceToGreenYards {
                VStack(spacing: 0) {
                    Text("\(dist)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("yds to pin")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        HStack(spacing: 12) {
            Button { vm.goPrev() } label: {
                Label("Prev", systemImage: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!vm.canGoPrev)
            .foregroundStyle(vm.canGoPrev ? .primary : Color(.tertiaryLabel))

            Button { vm.toggleYardCircles() } label: {
                Image(systemName: vm.showYardCircles ? "circle.grid.3x3.fill" : "circle.grid.3x3")
                    .font(.title3)
                    .frame(width: 48, height: 48)
                    .background(.regularMaterial, in: Circle())
            }
            .foregroundStyle(vm.showYardCircles ? Color.blueTeam : Color(.secondaryLabel))

            Button { vm.goNext() } label: {
                HStack { Text("Next"); Image(systemName: "chevron.right") }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!vm.canGoNext)
            .foregroundStyle(vm.canGoNext ? .primary : Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

// MARK: - Satellite MKMapView wrapper

struct SatelliteMapView: UIViewRepresentable {
    @ObservedObject var vm: HoleMapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.mapType = .satellite
        map.showsUserLocation = true
        map.delegate = context.coordinator
        map.setRegion(vm.mapRegion, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        // Update region if it changed externally (hole navigation)
        let current = map.region
        let target  = vm.mapRegion
        let latDiff = abs(current.center.latitude  - target.center.latitude)
        let lonDiff = abs(current.center.longitude - target.center.longitude)
        if latDiff > 0.0001 || lonDiff > 0.0001 {
            map.setRegion(target, animated: true)
        }

        // Green pin
        map.removeAnnotations(map.annotations.filter { !($0 is MKUserLocation) })
        if let coord = vm.greenCoordinate {
            let pin = GreenPinAnnotation(coordinate: coord)
            map.addAnnotation(pin)
        }

        // Distance circles
        map.removeOverlays(map.overlays.filter { $0 is MKCircle })
        if vm.showYardCircles, let coord = vm.greenCoordinate {
            for radius in HoleMapViewModel.circleRadii {
                map.addOverlay(MKCircle(center: coord, radius: radius))
            }
        }

        // Line from user to green
        map.removeOverlays(map.overlays.filter { $0 is MKPolyline })
        if let userLoc = vm.userLocation?.coordinate, let greenCoord = vm.greenCoordinate {
            var pts = [userLoc, greenCoord]
            map.addOverlay(MKPolyline(coordinates: &pts, count: 2))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is GreenPinAnnotation else { return nil }
            let id = "greenPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.annotation = annotation
            // Draw a green circle as the pin
            let size: CGFloat = 20
            UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
            let ctx = UIGraphicsGetCurrentContext()!
            ctx.setFillColor(UIColor.systemGreen.cgColor)
            ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(2)
            ctx.strokeEllipse(in: CGRect(x: 1, y: 1, width: size - 2, height: size - 2))
            view.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            view.centerOffset = .zero
            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let r = MKCircleRenderer(circle: circle)
                r.strokeColor = UIColor.white.withAlphaComponent(0.7)
                r.lineWidth = 1.5
                return r
            }
            if let poly = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: poly)
                r.strokeColor = UIColor.white.withAlphaComponent(0.6)
                r.lineWidth = 1.5
                r.lineDashPattern = [6, 4]
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - Custom annotation

private class GreenPinAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) { self.coordinate = coordinate }
}
