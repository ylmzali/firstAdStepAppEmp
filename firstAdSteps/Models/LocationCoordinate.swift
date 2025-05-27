import CoreLocation

struct LocationCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
} 
