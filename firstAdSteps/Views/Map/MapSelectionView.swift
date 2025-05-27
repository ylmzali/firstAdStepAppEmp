import SwiftUI
import MapKit

struct MapSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var regionManager: MapRegionManager
    let annotations: [RouteAnnotation]
    let startLocation: CLLocationCoordinate2D?
    let endLocation: CLLocationCoordinate2D?
    let onLocationSelected: (CLLocationCoordinate2D, LocationSelectionButton) -> Void
    
    @StateObject private var locationManager = LocationTrackingManager()
    @State private var selectedButton: LocationSelectionButton?
    @State private var tempCoordinate: CLLocationCoordinate2D?
    @State private var showingLocationError = false
    @State private var currentAnnotations: [RouteAnnotation]
    
    init(regionManager: MapRegionManager,
         annotations: [RouteAnnotation],
         startLocation: CLLocationCoordinate2D?,
         endLocation: CLLocationCoordinate2D?,
         onLocationSelected: @escaping (CLLocationCoordinate2D, LocationSelectionButton) -> Void) {
        self.regionManager = regionManager
        self.annotations = annotations
        self.startLocation = startLocation
        self.endLocation = endLocation
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
                
                if let selectedButton = selectedButton {
                    VStack {
                        Text(selectionModeText(for: selectedButton))
                            .font(.system(size: AntTypography.paragraph))
                            .foregroundColor(.white)
                            .padding(AntSpacing.sm)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(AntCornerRadius.md)
                            .padding(.top, AntSpacing.lg)
                        Spacer()
                    }
                }
                
                VStack {
                    HStack(spacing: AntSpacing.md) {
                        Button {
                            goToUserLocation()
                        } label: {
                            Label("Konumum", systemImage: "location.fill")
                                .labelStyle(MapButtonLabelStyle())
                        }
                        .mapButton(isSelected: false)
                        
                        Button {
                            handleButtonSelection(.startPoint)
                        } label: {
                            Label("Başlangıç", systemImage: "mappin.circle.fill")
                                .labelStyle(MapButtonLabelStyle())
                        }
                        .mapButton(isSelected: selectedButton == .startPoint)
                        .background(hasStartLocation ? AntColors.success.opacity(0.1) : AntColors.primary.opacity(0.1))
                        .foregroundColor(hasStartLocation ? AntColors.success : AntColors.primary)
                        
                        Button {
                            handleButtonSelection(.endPoint)
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
            .alert("Konum Hatası", isPresented: $showingLocationError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                if let error = locationManager.locationError {
                    Text(error)
                }
            }
        }
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
        
        // Mevcut pin'i kaldır
        currentAnnotations.removeAll { annotation in
            switch button {
            case .startPoint:
                return annotation.type == .start
            case .endPoint:
                return annotation.type == .end
            case .myLocation:
                return false
            }
        }
        
        // Yeni pin ekle
        let newAnnotation = RouteAnnotation(
            coordinate: coordinate,
            title: button == .startPoint ? "Başlangıç" : "Bitiş",
            type: button == .startPoint ? .start : .end
        )
        currentAnnotations.append(newAnnotation)
        
        // Seçilen konumu kaydet
        onLocationSelected(coordinate, button)
        
        // Seçim modunu kapat
        selectedButton = nil
    }
    
    private func goToUserLocation() {
        locationManager.getCurrentLocation { result in
            switch result {
            case .success(let coordinate):
                regionManager.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.005,
                        longitudeDelta: 0.005
                    )
                )
            case .failure:
                showingLocationError = true
            }
        }
    }
    
    private func selectionModeText(for button: LocationSelectionButton) -> String {
        switch button {
        case .startPoint:
            return "Başlangıç noktasını seçmek için haritaya dokunun"
        case .endPoint:
            return "Bitiş noktasını seçmek için haritaya dokunun"
        case .myLocation:
            return ""
        }
    }
} 
