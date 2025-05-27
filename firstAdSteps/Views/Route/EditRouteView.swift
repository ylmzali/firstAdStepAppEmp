import SwiftUI
import MapKit

// MARK: - Location Selection Type
enum LocationSelectionPoint {
    case start
    case end
}

// MARK: - Location Map View
struct RouteLocationMapView: View {
    @ObservedObject var regionManager: MapRegionManager
    let startLocation: LocationCoordinate?
    let endLocation: LocationCoordinate?
    let areaType: AreaType
    let onLocationSelected: (CLLocationCoordinate2D, LocationSelectionButton) -> Void
    @State private var showingFullScreenMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.sm) {
            Text("Konum")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
                .padding(.horizontal, AntSpacing.md)
            
            Button {
                showingFullScreenMap = true
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
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .padding([.bottom, .leading], 12)
                }
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
                startLocation: startLocation?.toCLLocationCoordinate2D(),
                endLocation: endLocation?.toCLLocationCoordinate2D(),
                areaType: areaType,
                onLocationSelected: onLocationSelected
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
}

// MARK: - Main View
struct EditRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: RouteViewModel
    
    let route: Route
    
    @State private var name: String
    @State private var description: String
    @State private var category: RouteCategory
    @State private var duration: Double
    @State private var areaType: AreaType
    @State private var startLocation: LocationCoordinate?
    @State private var endLocation: LocationCoordinate?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingMapSelection = false
    @State private var mapSnapshot: UIImage?
    
    @StateObject private var regionManager: MapRegionManager
    
    init(route: Route) {
        self.route = route
        
        // Initialize state with route values
        _name = State(initialValue: route.name)
        _description = State(initialValue: route.description)
        _category = State(initialValue: route.category)
        _duration = State(initialValue: route.duration)
        _areaType = State(initialValue: route.areaType)
        _startLocation = State(initialValue: route.startLocation)
        _endLocation = State(initialValue: route.endLocation)
        
        // Initialize region manager with a default region
        let initialRegion = MKCoordinateRegion(
            center: route.startLocation.toCLLocationCoordinate2D(),
            span: MKCoordinateSpan(latitudeDelta: 0.027, longitudeDelta: 0.027)
        )
        _regionManager = StateObject(wrappedValue: MapRegionManager(initialRegion: initialRegion))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AntSpacing.lg) {
                routeInfoSection
                locationSection
            }
            .padding(AntSpacing.md)
        }
        .background(AntColors.background)
        .navigationTitle("Rotayı Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        .onAppear {
            adjustMapRegionToFitAnnotations()
            createMapSnapshot()
        }
    }
    
    private var routeInfoSection: some View {
        VStack(spacing: AntSpacing.md) {
            RouteBasicInfoView(name: $name, description: $description)
            
            RouteCategoryView(
                category: $category,
                areaType: $areaType,
                onAreaTypeChange: adjustMapZoomLevel
            )
            
            RouteDurationView(duration: $duration)
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AntSpacing.sm) {
            Text("Konum")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
                .padding(.horizontal, AntSpacing.md)
            
            locationContent
        }
        .padding(.vertical, AntSpacing.md)
        .background(Color.white)
        .cornerRadius(AntCornerRadius.md)
    }
    
    @ViewBuilder
    private var locationContent: some View {
        if let snapshot = mapSnapshot {
            locationButton(with: snapshot)
        } else {
            ProgressView()
                .frame(height: 300)
        }
    }
    
    private func locationButton(with snapshot: UIImage) -> some View {
        Button {
            showingMapSelection = true
        } label: {
            Image(uiImage: snapshot)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: AntCornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AntCornerRadius.md)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .overlay(alignment: .bottomTrailing) {
                    expandButton
                }
        }
        .buttonStyle(.plain)
    }
    
    private var expandButton: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
            .padding([.bottom, .trailing], 12)
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
        
        // Yeni snapshot oluştur
        createMapSnapshot()
    }
    
    private func handleLocationSelectedForRouteLocation(_ coordinate: CLLocationCoordinate2D, _ button: LocationSelectionButton) {
        handleLocationSelected(coordinate, button)
    }
    
    private func adjustMapZoomLevel() {
        adjustMapRegionToFitAnnotations()
        createMapSnapshot()
    }
    
    private func createMapSnapshot() {
        // Önce harita bölgesini ayarla
        adjustMapRegionToFitAnnotations()
        
        let options = MKMapSnapshotter.Options()
        options.region = regionManager.region
        options.size = CGSize(width: UIScreen.main.bounds.width - 32, height: 300)
        options.mapType = .standard
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        Task {
            do {
                let snapshot = try await snapshotter.start()
                
                // Resim üzerine pin'leri ve rotayı çiz
                let finalImage = await drawOnSnapshot(snapshot)
                
                await MainActor.run {
                    self.mapSnapshot = finalImage
                }
            } catch {
                print("Harita snapshot hatası: \(error)")
            }
        }
    }
    
    private func drawOnSnapshot(_ snapshot: MKMapSnapshotter.Snapshot) async -> UIImage {
        let image = UIGraphicsImageRenderer(size: snapshot.image.size).image { _ in
            // Temel harita görüntüsünü çiz
            snapshot.image.draw(at: .zero)
            
            // Başlangıç ve bitiş noktalarını çiz
            if let start = startLocation {
                let startPoint = snapshot.point(for: start.toCLLocationCoordinate2D())
                let startPin = UIImage(systemName: "mappin.circle.fill")?
                    .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
                startPin?.draw(at: CGPoint(x: startPoint.x - 12, y: startPoint.y - 24))
            }
            
            if let end = endLocation {
                let endPoint = snapshot.point(for: end.toCLLocationCoordinate2D())
                let endPin = UIImage(systemName: "flag.circle.fill")?
                    .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
                endPin?.draw(at: CGPoint(x: endPoint.x - 12, y: endPoint.y - 24))
            }
            
            // Eğer önerilen rota varsa, çiz
            if let suggestedRoute = route.suggestedRoute {
                let path = UIBezierPath()
                let polyline = suggestedRoute.polyline
                
                // Polyline'dan koordinatları al
                let pointCount = polyline.pointCount
                let coords = polyline.points()
                var coordinates = [CLLocationCoordinate2D]()
                
                for i in 0..<pointCount {
                    let mapPoint = coords[i]
                    coordinates.append(mapPoint.coordinate)
                }
                
                let snapshotPoints = coordinates.map { snapshot.point(for: $0) }
                
                if let firstPoint = snapshotPoints.first {
                    path.move(to: firstPoint)
                    snapshotPoints.dropFirst().forEach { path.addLine(to: $0) }
                }
                
                UIColor.systemBlue.setStroke()
                path.lineWidth = 3
                path.stroke()
            }
        }
        
        return image
    }
    
    private func saveRoute() {
        guard let start = startLocation, let end = endLocation else {
            alertMessage = "Başlangıç ve bitiş noktalarını seçmelisiniz."
            showAlert = true
            return
        }
        
        let updatedRoute = Route(
            id: route.id,
            name: name,
            description: description,
            category: category,
            status: route.status,
            startLocation: start,
            endLocation: end,
            assignedDate: route.assignedDate,
            completionProgress: route.completionProgress,
            duration: duration,
            areaType: areaType,
            suggestedRoute: route.suggestedRoute
        )
        
        viewModel.updateRoute(updatedRoute)
        dismiss()
    }
} 
