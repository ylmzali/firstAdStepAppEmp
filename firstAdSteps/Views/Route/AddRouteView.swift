import SwiftUI
import MapKit

// MARK: - Supporting Views and Styles
struct AddRouteMapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var isDrawingMode: Bool
    @Binding var drawnRoute: DrawnRoute?
    @Binding var routeSuggestion: RouteSuggestion?
    let annotations: [RouteAnnotation]
    let onMapTap: (CLLocationCoordinate2D) -> Void
    let onRouteDrawn: (DrawnRoute) -> Void
    let onRouteSuggestionAvailable: (RouteSuggestion) -> Void
    
    @StateObject private var regionManager: MapRegionManager
    @State private var showingFullScreenMap = false
    @State private var selectedButton: LocationSelectionButton?
    
    init(region: Binding<MKCoordinateRegion>,
         isDrawingMode: Binding<Bool>,
         drawnRoute: Binding<DrawnRoute?>,
         routeSuggestion: Binding<RouteSuggestion?>,
         annotations: [RouteAnnotation],
         onMapTap: @escaping (CLLocationCoordinate2D) -> Void,
         onRouteDrawn: @escaping (DrawnRoute) -> Void,
         onRouteSuggestionAvailable: @escaping (RouteSuggestion) -> Void) {
        self._region = region
        self._isDrawingMode = isDrawingMode
        self._drawnRoute = drawnRoute
        self._routeSuggestion = routeSuggestion
        self.annotations = annotations
        self.onMapTap = onMapTap
        self.onRouteDrawn = onRouteDrawn
        self.onRouteSuggestionAvailable = onRouteSuggestionAvailable
        self._regionManager = StateObject(wrappedValue: MapRegionManager(initialRegion: region.wrappedValue))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.sm) {
            Text("Konum")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
                .padding(.horizontal, AntSpacing.md)
            
            // Statik harita görünümü
            Button {
                showingFullScreenMap = true
            } label: {
                MapViewRepresentable(
                    region: $regionManager.region,
                    annotations: annotations,
                    route: routeSuggestion?.suggestedRoute,
                    onMapTap: { _ in },
                    isDrawingEnabled: false,
                    drawnRoute: drawnRoute,
                    routeSuggestion: routeSuggestion
                )
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: AntCornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AntCornerRadius.md)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AntSpacing.md)
        .background(Color.white)
        .cornerRadius(AntCornerRadius.md)
        .fullScreenCover(isPresented: $showingFullScreenMap) {
            MapSelectionsView(
                regionManager: regionManager,
                annotations: annotations,
                startLocation: annotations.first { $0.type == .start }?.coordinate,
                endLocation: annotations.first { $0.type == .end }?.coordinate,
                areaType: .outdoor, // Varsayılan olarak outdoor
                onLocationSelected: { coordinate, _ in
                    onMapTap(coordinate)
                }
            )
        }
    }
}

// InfoCard yapısı Components/InfoCard.swift dosyasına taşındı

// MARK: - Main View
struct AddRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: RouteViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var category: RouteCategory = .walking
    @State private var duration: Double = 60
    @State private var areaType: AreaType = .outdoor
    @State private var startLocation: LocationCoordinate?
    @State private var endLocation: LocationCoordinate?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingMapSelection = false
    
    @StateObject private var regionManager: MapRegionManager
    
    init() {
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            span: MKCoordinateSpan(latitudeDelta: 0.027, longitudeDelta: 0.027)
        )
        _regionManager = StateObject(wrappedValue: MapRegionManager(initialRegion: initialRegion))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AntSpacing.lg) {
                VStack(spacing: AntSpacing.md) {
                    RouteBasicInfoView(name: $name, description: $description)
                    
                    RouteCategoryView(
                        category: $category,
                        areaType: $areaType,
                        onAreaTypeChange: adjustMapZoomLevel
                    )
                    
                    RouteDurationView(duration: $duration)
                }
                
                // Statik harita görünümü
                Button {
                    showingMapSelection = true
                } label: {
                    MapViewRepresentable(
                        region: $regionManager.region,
                        annotations: annotations,
                        route: nil,
                        onMapTap: { _ in },
                        isDrawingEnabled: false,
                        drawnRoute: nil,
                        routeSuggestion: nil
                    )
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: AntCornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AntCornerRadius.md)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(AntSpacing.md)
        }
        .background(AntColors.background)
        /*
        .gesture(
            TapGesture()
                .onEnded { _ in
                    hideKeyboard()
                }
        )
         */
        .navigationTitle("Yeni Rota")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            /*
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Vazgeç") {
                    dismiss()
                }
                .foregroundColor(AntColors.text)
            }
             */
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kaydet") {
                    saveRoute()
                }
                .foregroundColor(AntColors.primary)
            }
        }
        .alert("Hata", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingMapSelection) {
            MapSelectionsView(
                regionManager: regionManager,
                annotations: annotations,
                startLocation: startLocation?.toCLLocationCoordinate2D(),
                endLocation: endLocation?.toCLLocationCoordinate2D(),
                areaType: areaType,
                onLocationSelected: handleLocationSelected
            )
        }
    }
    
    private var annotations: [RouteAnnotation] {
        var annotations: [RouteAnnotation] = []
        
        if let start = startLocation {
            annotations.append(RouteAnnotation(
                coordinate: start.toCLLocationCoordinate2D(),
                title: "Başlangıç",
                type: .start
            ))
        }
        
        if let end = endLocation {
            annotations.append(RouteAnnotation(
                coordinate: end.toCLLocationCoordinate2D(),
                title: "Bitiş",
                type: .end
            ))
        }
        
        return annotations
    }
    
    private func adjustMapRegionToFitAnnotations() {
        guard !annotations.isEmpty else { return }
        
        // Tüm pinleri içeren bir MKMapRect oluştur
        let mapRect = annotations.reduce(MKMapRect.null) { rect, annotation in
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
    
    private func handleLocationSelected(_ coordinate: CLLocationCoordinate2D, _ button: LocationSelectionButton) {
        let location = LocationCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        switch button {
        case .startPoint:
            startLocation = location
        case .endPoint:
            endLocation = location
        }
        
        // Harita bölgesini güncelle
        adjustMapRegionToFitAnnotations()
    }
    
    private func adjustMapZoomLevel() {
        adjustMapRegionToFitAnnotations()
    }
    
    private func saveRoute() {
        guard !name.isEmpty else {
            alertMessage = "Lütfen rota adını girin"
            showAlert = true
            return
        }
        
        guard let start = startLocation else {
            alertMessage = "Lütfen başlangıç noktasını seçin"
            showAlert = true
            return
        }
        
        guard let end = endLocation else {
            alertMessage = "Lütfen bitiş noktasını seçin"
            showAlert = true
            return
        }
        
        let newRoute = Route(
            name: name,
            description: description,
            category: category,
            startLocation: start,
            endLocation: end,
            duration: duration,
            areaType: areaType
        )
        
        viewModel.addRoute(newRoute)
        dismiss()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views
struct RouteSuggestionView: View {
    let suggestion: RouteSuggestion
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AntSpacing.lg) {
                // İkon ve Başlık
                VStack(spacing: AntSpacing.md) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 40))
                        .foregroundColor(AntColors.primary)
                    
                    Text("Rota Önerisi")
                        .font(.system(size: AntTypography.heading4, weight: .medium))
                        .foregroundColor(AntColors.text)
                }
                
                // Bilgi Kartları
                VStack(spacing: AntSpacing.md) {
                    // Mesafe Farkı
                    InfoCard(
                        title: "Mesafe Farkı",
                        value: String(format: "%.0f metre daha kısa", suggestion.distanceDifference),
                        icon: "arrow.left.and.right"
                    )
                    
                    // İyileştirme Oranı
                    InfoCard(
                        title: "İyileştirme",
                        value: String(format: "%%%.1f daha verimli", suggestion.improvementPercentage),
                        icon: "chart.bar.fill"
                    )
                }
                
                // Açıklama
                Text(suggestion.reason)
                    .font(.system(size: AntTypography.paragraph))
                    .foregroundColor(AntColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                // Butonlar
                VStack(spacing: AntSpacing.md) {
                    Button(action: onAccept) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Önerilen Rotayı Kullan")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .antButton(.primary)
                    
                    Button(action: onReject) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                            Text("Çizdiğim Rotayı Kullan")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .antButton(.secondary)
                }
                .padding()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddRouteView()
} 
