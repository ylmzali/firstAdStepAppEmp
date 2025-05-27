import SwiftUI
import MapKit
// RouteAnnotation is defined in the same module

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let annotations: [RouteAnnotation]
    let route: MKRoute?
    let onMapTap: (CLLocationCoordinate2D) -> Void
    let isDrawingEnabled: Bool
    let drawnRoute: DrawnRoute?
    let routeSuggestion: RouteSuggestion?
    var onRouteDrawn: ((DrawnRoute) -> Void)?
    var onRouteSuggestionAvailable: ((RouteSuggestion) -> Void)?
    
    private func areRegionsEqual(_ region1: MKCoordinateRegion, _ region2: MKCoordinateRegion) -> Bool {
        let latitudeDelta = abs(region1.center.latitude - region2.center.latitude)
        let longitudeDelta = abs(region1.center.longitude - region2.center.longitude)
        let spanLatDelta = abs(region1.span.latitudeDelta - region2.span.latitudeDelta)
        let spanLonDelta = abs(region1.span.longitudeDelta - region2.span.longitudeDelta)
        
        let tolerance: Double = 0.000001
        return latitudeDelta < tolerance &&
               longitudeDelta < tolerance &&
               spanLatDelta < tolerance &&
               spanLonDelta < tolerance
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        if isDrawingEnabled {
            let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
            mapView.addGestureRecognizer(panGesture)
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Bölge güncellemesi
        if !areRegionsEqual(mapView.region, region) {
            mapView.setRegion(region, animated: true)
        }
        
        // Pin'leri güncelle
        mapView.removeAnnotations(mapView.annotations)
        let newAnnotations = annotations.map { annotation -> MKPointAnnotation in
            let point = MKPointAnnotation()
            point.coordinate = annotation.coordinate
            point.title = annotation.title
            return point
        }
        mapView.addAnnotations(newAnnotations)
        
        // Rotaları güncelle
        mapView.removeOverlays(mapView.overlays)
        
        if let route = route {
            mapView.addOverlay(route.polyline)
        }
        
        if let drawnRoute = drawnRoute {
            let coordinates = drawnRoute.points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }
        
        if let suggestion = routeSuggestion {
            mapView.addOverlay(suggestion.suggestedRoute.polyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var drawingPoints: [CLLocationCoordinate2D] = []
        private var isDrawing = false
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard !parent.isDrawingEnabled else { return }
            
            let mapView = gesture.view as! MKMapView
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            parent.onMapTap(coordinate)
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard parent.isDrawingEnabled else { return }
            
            let mapView = gesture.view as! MKMapView
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            switch gesture.state {
            case .began:
                isDrawing = true
                drawingPoints = [coordinate]
                
            case .changed:
                guard isDrawing else { return }
                drawingPoints.append(coordinate)
                
                // Çizilen rotayı göster
                mapView.removeOverlays(mapView.overlays)
                let polyline = MKPolyline(coordinates: drawingPoints, count: drawingPoints.count)
                mapView.addOverlay(polyline)
                
            case .ended:
                guard isDrawing, drawingPoints.count >= 2 else { return }
                isDrawing = false
                
                // Çizilen rotayı kaydet
                let distance = calculateDistance(for: drawingPoints)
                let route = DrawnRoute(points: drawingPoints, distance: distance)
                parent.onRouteDrawn?(route)
                
                // Rota önerisi iste
                requestRouteSuggestion(for: drawingPoints)
                
            default:
                break
            }
        }
        
        private func requestRouteSuggestion(for points: [CLLocationCoordinate2D]) {
            guard points.count >= 2 else { return }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: points.first!))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: points.last!))
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let response = response,
                      let route = response.routes.first,
                      let drawnDistance = self?.calculateDistance(for: points) else { return }
                
                let suggestion = RouteSuggestion(
                    originalRoute: DrawnRoute(points: points, distance: drawnDistance),
                    suggestedRoute: route,
                    reason: "Önerilen rota daha kısa ve verimli bir güzergah sunuyor."
                )
                
                self?.parent.onRouteSuggestionAvailable?(suggestion)
            }
        }
        
        private func calculateDistance(for points: [CLLocationCoordinate2D]) -> CLLocationDistance {
            guard points.count >= 2 else { return 0 }
            
            var distance: CLLocationDistance = 0
            for i in 0..<points.count-1 {
                let location1 = CLLocation(latitude: points[i].latitude, longitude: points[i].longitude)
                let location2 = CLLocation(latitude: points[i+1].latitude, longitude: points[i+1].longitude)
                distance += location1.distance(from: location2)
            }
            
            return distance
        }
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            if let route = parent.route, overlay === route.polyline {
                // Önerilen rota
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
            } else if parent.routeSuggestion?.suggestedRoute.polyline === overlay {
                // Önerilen alternatif rota
                renderer.strokeColor = .systemGreen
                renderer.lineWidth = 4
            } else {
                // Çizilen rota
                renderer.strokeColor = .systemRed
                renderer.lineWidth = 3
                renderer.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 5)]
            }
            
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "RoutePoint"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            if let title = annotation.title {
                switch title {
                case "Başlangıç":
                    (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemBlue
                case "Bitiş":
                    (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemRed
                default:
                    break
                }
            }
            
            return annotationView
        }
    }
} 
