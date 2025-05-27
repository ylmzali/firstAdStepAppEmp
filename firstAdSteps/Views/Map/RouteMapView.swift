import SwiftUI
import MapKit

struct RouteMapView: View {
    @ObservedObject var regionManager: MapRegionManager
    let annotations: [RouteAnnotation]
    let route: MKRoute?
    
    var body: some View {
        MapViewRepresentable(
            region: $regionManager.region,
            annotations: annotations,
            route: route,
            onMapTap: { _ in },
            isDrawingEnabled: false,
            drawnRoute: nil,
            routeSuggestion: nil
        )
    }
} 
