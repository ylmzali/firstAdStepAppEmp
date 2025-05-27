import SwiftUI
import MapKit
// RouteAnnotation is defined in the same module

enum LocationSelectionButton {
    case startPoint
    case endPoint
}

// MARK: - Selection Buttons View
struct LocationSelectionButtonsView: View {
    let selectedButton: LocationSelectionButton?
    let hasStartLocation: Bool
    let hasEndLocation: Bool
    let onButtonTap: (LocationSelectionButton) -> Void
    
    var body: some View {
        HStack(spacing: AntSpacing.md) {
            Button {
                onButtonTap(.startPoint)
            } label: {
                Label("Başlangıç", systemImage: "mappin.circle.fill")
                    .labelStyle(MapButtonLabelStyle())
            }
            .mapButton(isSelected: selectedButton == .startPoint)
            .background(hasStartLocation ? AntColors.success.opacity(0.1) : AntColors.primary.opacity(0.1))
            .foregroundColor(hasStartLocation ? AntColors.success : AntColors.primary)
            
            Button {
                onButtonTap(.endPoint)
            } label: {
                Label("Bitiş", systemImage: "flag.circle.fill")
                    .labelStyle(MapButtonLabelStyle())
            }
            .mapButton(isSelected: selectedButton == .endPoint)
            .background(hasEndLocation ? AntColors.success.opacity(0.1) : AntColors.error.opacity(0.1))
            .foregroundColor(hasEndLocation ? AntColors.success : AntColors.error)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(AntCornerRadius.lg)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
        .padding(.top, AntSpacing.lg)
    }
}

// MARK: - Selection Mode Text View
struct SelectionModeTextView: View {
    let selectedButton: LocationSelectionButton
    
    var body: some View {
        Text(selectionModeText(for: selectedButton))
            .font(.system(size: AntTypography.paragraph))
            .foregroundColor(.white)
            .padding(AntSpacing.sm)
            .background(Color.black.opacity(0.7))
            .cornerRadius(AntCornerRadius.md)
            .padding(.top, AntSpacing.lg)
    }
    
    private func selectionModeText(for button: LocationSelectionButton) -> String {
        switch button {
        case .startPoint:
            return "Başlangıç noktasını seçmek için haritaya dokunun"
        case .endPoint:
            return "Bitiş noktasını seçmek için haritaya dokunun"
        }
    }
}

// MARK: - Main View
struct MapSelectionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var regionManager: MapRegionManager
    let annotations: [RouteAnnotation]
    let startLocation: CLLocationCoordinate2D?
    let endLocation: CLLocationCoordinate2D?
    let onLocationSelected: (CLLocationCoordinate2D, LocationSelectionButton) -> Void
    let areaType: AreaType
    
    @State private var selectedButton: LocationSelectionButton?
    @State private var currentAnnotations: [RouteAnnotation]
    
    init(regionManager: MapRegionManager,
         annotations: [RouteAnnotation],
         startLocation: CLLocationCoordinate2D?,
         endLocation: CLLocationCoordinate2D?,
         areaType: AreaType,
         onLocationSelected: @escaping (CLLocationCoordinate2D, LocationSelectionButton) -> Void) {
        self.regionManager = regionManager
        self.annotations = annotations
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.areaType = areaType
        self.onLocationSelected = onLocationSelected
        self._currentAnnotations = State(initialValue: annotations)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapViewRepresentable(
                    region: $regionManager.region,
                    annotations: currentAnnotations,
                    route: nil,
                    onMapTap: handleMapTap,
                    isDrawingEnabled: false,
                    drawnRoute: nil,
                    routeSuggestion: nil
                )
                .ignoresSafeArea()
                
                VStack {
                    if let selectedButton = selectedButton {
                        SelectionModeTextView(selectedButton: selectedButton)
                    }
                    
                    LocationSelectionButtonsView(
                        selectedButton: selectedButton,
                        hasStartLocation: hasStartLocation,
                        hasEndLocation: hasEndLocation,
                        onButtonTap: handleButtonSelection
                    )
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(AntColors.text)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamamla") {
                        dismiss()
                    }
                    .foregroundColor(AntColors.primary)
                }
            }
            .onAppear {
                adjustMapRegionToFitAnnotations()
            }
        }
    }
    
    private func adjustMapRegionToFitAnnotations() {
        guard !currentAnnotations.isEmpty else { return }
        
        // Tüm pinleri içeren bir MKMapRect oluştur
        let mapRect = currentAnnotations.reduce(MKMapRect.null) { rect, annotation in
            let point = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            return rect.isNull ? pointRect : rect.union(pointRect)
        }
        
        // Kenar boşluğu ekle (%30)
        let padding = 0.3
        let paddedRect = mapRect.insetBy(
            dx: -mapRect.width * padding,
            dy: -mapRect.height * padding
        )
        
        // Minimum zoom seviyesini kontrol et
        let minSpan = areaType == .indoor ? 0.001 : 0.005
        let minRect = MKMapRect(
            x: paddedRect.midX - paddedRect.width/2,
            y: paddedRect.midY - paddedRect.height/2,
            width: max(paddedRect.width, minSpan * 111000), // yaklaşık metre cinsinden
            height: max(paddedRect.height, minSpan * 111000)
        )
        
        // Yeni bölgeyi ayarla
        regionManager.region = MKCoordinateRegion(minRect)
    }
    
    private var hasStartLocation: Bool {
        currentAnnotations.contains { $0.type == .start }
    }
    
    private var hasEndLocation: Bool {
        currentAnnotations.contains { $0.type == .end }
    }
    
    private func handleButtonSelection(_ button: LocationSelectionButton) {
        if selectedButton == button {
            selectedButton = nil
        } else {
            selectedButton = button
        }
    }
    
    private func handleMapTap(_ coordinate: CLLocationCoordinate2D) {
        guard let button = selectedButton else { return }
        
        // Remove existing pin
        currentAnnotations.removeAll { annotation in
            switch button {
            case .startPoint:
                return annotation.type == .start
            case .endPoint:
                return annotation.type == .end
            }
        }
        
        // Add new pin
        let newAnnotation = RouteAnnotation(
            coordinate: coordinate,
            title: button == .startPoint ? "Başlangıç" : "Bitiş",
            type: button == .startPoint ? .start : .end
        )
        currentAnnotations.append(newAnnotation)
        
        // Notify parent view
        onLocationSelected(coordinate, button)
        
        // Reset selection
        selectedButton = nil
        
        // Adjust map region to fit all pins
        adjustMapRegionToFitAnnotations()
    }
} 
