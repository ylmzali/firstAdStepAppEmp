import SwiftUI
import MapKit

struct FullScreenMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var region: MKCoordinateRegion
    let annotations: [RouteAnnotation]
    let route: MKRoute?
    let isInteractive: Bool
    let onLocationSelected: ((CLLocationCoordinate2D) -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapViewRepresentable(
                    region: $region,
                    annotations: annotations,
                    route: route,
                    onMapTap: { coordinate in
                        if let onLocationSelected = onLocationSelected {
                            onLocationSelected(coordinate)
                            dismiss()
                        }
                    },
                    isDrawingEnabled: false,
                    drawnRoute: nil,
                    routeSuggestion: nil
                )
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button("Kapat") {
                            dismiss()
                        }
                        .foregroundColor(AntColors.text)
                        .padding(.horizontal, AntSpacing.md)
                        .padding(.vertical, AntSpacing.xs)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(AntCornerRadius.md)
                        
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
} 
