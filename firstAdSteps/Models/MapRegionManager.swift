import MapKit

class MapRegionManager: ObservableObject {
    @Published var region: MKCoordinateRegion
    
    init(initialRegion: MKCoordinateRegion) {
        self.region = initialRegion
    }
    
    func updateRegion(_ newRegion: MKCoordinateRegion) {
        region = newRegion
    }
    
    func centerOnLocation(_ location: CLLocationCoordinate2D) {
        region.center = location
    }
} 
