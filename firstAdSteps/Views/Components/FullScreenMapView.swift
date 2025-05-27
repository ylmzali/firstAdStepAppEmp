import SwiftUI
import MapKit

struct FullScreenMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var region: MKCoordinateRegion
    @Binding var drawnRoute: DrawnRoute?
    @Binding var routeSuggestion: RouteSuggestion?
    let isDrawingMode: Bool
    let annotations: [RouteAnnotation]
    let onMapTap: (CLLocationCoordinate2D) -> Void
    let onRouteDrawn: ((DrawnRoute) -> Void)?
    let onRouteSuggestionAvailable: ((RouteSuggestion) -> Void)?
    
    @State private var currentRegion: MKCoordinateRegion
    
    init(region: Binding<MKCoordinateRegion>,
         drawnRoute: Binding<DrawnRoute?>,
         routeSuggestion: Binding<RouteSuggestion?>,
         isDrawingMode: Bool,
         annotations: [RouteAnnotation],
         onMapTap: @escaping (CLLocationCoordinate2D) -> Void,
         onRouteDrawn: ((DrawnRoute) -> Void)?,
         onRouteSuggestionAvailable: ((RouteSuggestion) -> Void)?) {
        self._region = region
        self._drawnRoute = drawnRoute
        self._routeSuggestion = routeSuggestion
        self.isDrawingMode = isDrawingMode
        self.annotations = annotations
        self.onMapTap = onMapTap
        self.onRouteDrawn = onRouteDrawn
        self.onRouteSuggestionAvailable = onRouteSuggestionAvailable
        self._currentRegion = State(initialValue: region.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapViewRepresentable(
                    region: $currentRegion,
                    annotations: isDrawingMode ? [] : annotations,
                    route: routeSuggestion?.suggestedRoute,
                    onMapTap: onMapTap,
                    isDrawingEnabled: isDrawingMode,
                    drawnRoute: drawnRoute,
                    routeSuggestion: routeSuggestion,
                    onRouteDrawn: { route in
                        drawnRoute = route
                        onRouteDrawn?(route)
                    },
                    onRouteSuggestionAvailable: { suggestion in
                        routeSuggestion = suggestion
                        onRouteSuggestionAvailable?(suggestion)
                    }
                )
                .ignoresSafeArea()
                
                // Çizim modu göstergesi
                if isDrawingMode {
                    VStack {
                        Text("Rotayı çizmek için parmağınızı sürükleyin")
                            .font(.system(size: AntTypography.paragraph))
                            .foregroundColor(.white)
                            .padding(AntSpacing.sm)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(AntCornerRadius.md)
                            .padding(.top, AntSpacing.lg)
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        region = currentRegion
                        dismiss()
                    }
                    .foregroundColor(AntColors.text)
                }
                
                if isDrawingMode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            drawnRoute = nil
                            routeSuggestion = nil
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(AntColors.warning)
                        }
                    }
                }
            }
        }
    }
} 
