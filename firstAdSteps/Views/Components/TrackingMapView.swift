import SwiftUI
import MapKit

struct TrackingMapView: View {
    @ObservedObject var regionManager: MapRegionManager
    let route: Route
    let userLocation: CLLocation?
    let userHeading: Double
    let trackedLocations: [CLLocation]
    
    var body: some View {
        Map(
            coordinateRegion: $regionManager.region,
            showsUserLocation: true,
            userTrackingMode: .constant(.follow)
        )
        .overlay(
            GeometryReader { geometry in
                ZStack {
                    // Rota çizgisi
                    if !trackedLocations.isEmpty {
                        Path { path in
                            let points = trackedLocations.map { location in
                                let coordinate = location.coordinate
                                let point = geometry.convert(coordinate, from: regionManager.region)
                                return point
                            }
                            
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(Color.blue, lineWidth: 3)
                    }
                    
                    // Başlangıç ve bitiş noktaları
                    let startPoint = geometry.convert(route.startLocation.toCLLocationCoordinate2D(), from: regionManager.region)
                    let endPoint = geometry.convert(route.endLocation.toCLLocationCoordinate2D(), from: regionManager.region)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .position(startPoint)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .position(endPoint)
                }
            }
        )
    }
}

extension GeometryProxy {
    func convert(_ coordinate: CLLocationCoordinate2D, from region: MKCoordinateRegion) -> CGPoint {
        let longitude = coordinate.longitude
        let latitude = coordinate.latitude
        
        let regionLongitude = region.center.longitude
        let regionLatitude = region.center.latitude
        
        let longitudeDelta = region.span.longitudeDelta
        let latitudeDelta = region.span.latitudeDelta
        
        let longitudeRatio = (longitude - regionLongitude) / longitudeDelta
        let latitudeRatio = (latitude - regionLatitude) / latitudeDelta
        
        let x = size.width * (0.5 + longitudeRatio)
        let y = size.height * (0.5 - latitudeRatio)
        
        return CGPoint(x: x, y: y)
    }
} 
