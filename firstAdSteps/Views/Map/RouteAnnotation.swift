import MapKit

enum RouteAnnotationType {
    case start
    case end
    case waypoint
}

struct RouteAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String
    let type: RouteAnnotationType
} 
