import Foundation
import MapKit
import CoreLocation

// Çizim durumu
enum DrawingState {
    case notStarted
    case drawing
    case finished
}

// Çizilen rota noktaları
struct DrawnRoute {
    var points: [CLLocationCoordinate2D]
    var distance: CLLocationDistance
    
    var startPoint: CLLocationCoordinate2D? {
        points.first
    }
    
    var endPoint: CLLocationCoordinate2D? {
        points.last
    }
    
    // İki nokta arasındaki toplam mesafeyi hesapla
    static func calculateDistance(for coordinates: [CLLocationCoordinate2D]) -> CLLocationDistance {
        guard coordinates.count > 1 else { return 0 }
        
        var totalDistance: CLLocationDistance = 0
        for i in 0..<(coordinates.count - 1) {
            let location1 = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
            let location2 = CLLocation(latitude: coordinates[i + 1].latitude, longitude: coordinates[i + 1].longitude)
            totalDistance += location1.distance(from: location2)
        }
        return totalDistance
    }
    
    // Rotayı optimize et (Douglas-Peucker algoritması)
    func optimized(tolerance: Double = 20) -> DrawnRoute {
        let optimizedPoints = douglasPeucker(points: points, epsilon: tolerance)
        return DrawnRoute(
            points: optimizedPoints,
            distance: DrawnRoute.calculateDistance(for: optimizedPoints)
        )
    }
    
    // Douglas-Peucker algoritması ile rota basitleştirme
    private func douglasPeucker(points: [CLLocationCoordinate2D], epsilon: Double) -> [CLLocationCoordinate2D] {
        guard points.count > 2 else { return points }
        
        var dmax = 0.0
        var index = 0
        let end = points.count - 1
        
        // En uzak noktayı bul
        for i in 1..<end {
            let d = perpendicularDistance(from: points[i], lineStart: points[0], lineEnd: points[end])
            if d > dmax {
                index = i
                dmax = d
            }
        }
        
        // Rekürsif olarak basitleştir
        if dmax > epsilon {
            let recResults1 = douglasPeucker(points: Array(points[0...index]), epsilon: epsilon)
            let recResults2 = douglasPeucker(points: Array(points[index...end]), epsilon: epsilon)
            
            var result = Array(recResults1.dropLast())
            result.append(contentsOf: recResults2)
            return result
        }
        
        return [points[0], points[end]]
    }
    
    // Bir noktanın bir çizgiye olan dikey uzaklığını hesapla
    private func perpendicularDistance(from point: CLLocationCoordinate2D, lineStart: CLLocationCoordinate2D, lineEnd: CLLocationCoordinate2D) -> Double {
        let a = point.latitude - lineStart.latitude
        let b = point.longitude - lineStart.longitude
        let c = lineEnd.latitude - lineStart.latitude
        let d = lineEnd.longitude - lineStart.longitude
        
        let dot = a * c + b * d
        let lenSq = c * c + d * d
        var param = dot / lenSq
        
        var xx, yy: Double
        
        if param < 0 {
            xx = lineStart.latitude
            yy = lineStart.longitude
        } else if param > 1 {
            xx = lineEnd.latitude
            yy = lineEnd.longitude
        } else {
            xx = lineStart.latitude + param * c
            yy = lineStart.longitude + param * d
        }
        
        let dx = point.latitude - xx
        let dy = point.longitude - yy
        
        return sqrt(dx * dx + dy * dy) * 111000 // Yaklaşık metre cinsinden
    }
}

// Rota önerisi
struct RouteSuggestion {
    let originalRoute: DrawnRoute
    let suggestedRoute: MKRoute
    let reason: String
    
    var distanceDifference: CLLocationDistance {
        originalRoute.distance - suggestedRoute.distance
    }
    
    var improvementPercentage: Double {
        (originalRoute.distance - suggestedRoute.distance) / originalRoute.distance * 100
    }
} 
