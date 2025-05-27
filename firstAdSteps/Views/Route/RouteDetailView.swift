import SwiftUI
import MapKit

struct RouteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: RouteViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingCancelAlert = false
    @State private var showingTrackingView = false
    @State private var showingFullScreenMap = false
    @State private var mapSnapshot: UIImage?
    
    let route: Route
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: route.assignedDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AntSpacing.lg) {
                routeMapView
                routeDetailsCard
            }
            .padding(.vertical, AntSpacing.md)
        }
        .background(AntColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditRouteView(route: route)
            }
        }
        .fullScreenCover(isPresented: $showingFullScreenMap) {
                            FullScreenMapView(
                    region: .constant(MKCoordinateRegion(
                        center: route.startLocation.toCLLocationCoordinate2D(),
                        span: MKCoordinateSpan(
                            latitudeDelta: route.areaType == .indoor ? 0.001 : 0.027,
                            longitudeDelta: route.areaType == .indoor ? 0.001 : 0.027
                        )
                    )),
                    annotations: [
                        RouteAnnotation(coordinate: route.startLocation.toCLLocationCoordinate2D(), title: "Başlangıç", type: .start),
                        RouteAnnotation(coordinate: route.endLocation.toCLLocationCoordinate2D(), title: "Bitiş", type: .end)
                    ],
                    route: route.suggestedRoute,
                    isInteractive: false,
                    onLocationSelected: nil
                )
        }
        .fullScreenCover(isPresented: $showingTrackingView) {
            RouteTrackingView(route: route)
        }
        .alert("Rotayı İptal Et", isPresented: $showingCancelAlert) {
            Button("Vazgeç", role: .cancel) { }
            Button("İptal Et", role: .destructive) {
                viewModel.cancelRoute(route)
                dismiss()
            }
        } message: {
            Text("Bu rotayı iptal etmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
        .alert("Rotayı Sil", isPresented: $showingDeleteAlert) {
            Button("Vazgeç", role: .cancel) { }
            Button("Sil", role: .destructive) {
                viewModel.deleteRoute(route)
                dismiss()
            }
        } message: {
            Text("Bu rotayı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
        .onAppear {
            createMapSnapshot()
        }
    }
    
    private var routeMapView: some View {
        Group {
            if let snapshot = mapSnapshot {
                Button {
                    showingFullScreenMap = true
                } label: {
                    Image(uiImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: AntCornerRadius.lg))
                        .padding(.horizontal, AntSpacing.md)
                        .shadow(color: Color.black.opacity(AntShadow.level1), radius: 3, y: 1)
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding([.bottom, .trailing], 12)
                        }
                }
                .buttonStyle(.plain)
            } else {
                ProgressView()
                    .frame(height: 200)
            }
        }
    }
    
    private var routeDetailsCard: some View {
        VStack(spacing: AntSpacing.lg) {
            routeHeader
            routeDescription
            routeProgress
            routeInfoGrid
            trackButton
        }
        .padding(AntSpacing.md)
        .background(Color.white)
        .cornerRadius(AntCornerRadius.lg)
    }
    
    private var routeHeader: some View {
        HStack {
            Text(route.name)
                .font(.system(size: AntTypography.heading3, weight: .medium))
                .foregroundColor(AntColors.text)
            Spacer()
            StatusBadge(status: route.status)
        }
    }
    
    private var routeDescription: some View {
        Text(route.description)
            .font(.system(size: AntTypography.paragraph))
            .foregroundColor(AntColors.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var routeProgress: some View {
        VStack(alignment: .leading, spacing: AntSpacing.xs) {
            Text("İlerleme")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
            ProgressView(value: route.completionProgress)
                .tint(route.status == .completed ? AntColors.success : AntColors.primary)
            Text("\(Int(route.completionProgress * 100))% Tamamlandı")
                .font(.system(size: AntTypography.caption))
                .foregroundColor(AntColors.secondaryText)
        }
        .padding(AntSpacing.md)
        .background(AntColors.background)
        .cornerRadius(AntCornerRadius.md)
    }
    
    private var routeInfoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: AntSpacing.md) {
            InfoCard(title: "Kategori", value: route.category.rawValue, icon: "figure.walk")
            InfoCard(title: "Alan Türü", value: route.areaType.rawValue, icon: route.areaType == .indoor ? "building.2" : "mountain.2")
            InfoCard(title: "Süre", value: "\(Int(route.duration)) dakika", icon: "clock")
            InfoCard(title: "Oluşturulma", value: formattedDate, icon: "calendar")
        }
    }
    
    private var trackButton: some View {
        Group {
            if route.status == .active {
                Button {
                    showingTrackingView = true
                } label: {
                    HStack {
                        Image(systemName: "figure.walk.motion")
                        Text("Başla")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AntColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AntCornerRadius.md)
                }
                .padding(.top, AntSpacing.md)
            }
        }
    }
    
    private func createMapSnapshot() {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: route.startLocation.toCLLocationCoordinate2D(),
            span: MKCoordinateSpan(
                latitudeDelta: route.areaType == .indoor ? 0.001 : 0.027,
                longitudeDelta: route.areaType == .indoor ? 0.001 : 0.027
            )
        )
        options.size = CGSize(width: UIScreen.main.bounds.width - 32, height: 200)
        options.mapType = .standard
        options.showsBuildings = false
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        Task {
            do {
                let snapshot = try await snapshotter.start()
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
            
            // Başlangıç noktasını çiz
            let startPoint = snapshot.point(for: route.startLocation.toCLLocationCoordinate2D())
            let startPin = UIImage(systemName: "mappin.circle.fill")?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            startPin?.draw(at: CGPoint(x: startPoint.x - 12, y: startPoint.y - 24))
            
            // Bitiş noktasını çiz
            let endPoint = snapshot.point(for: route.endLocation.toCLLocationCoordinate2D())
            let endPin = UIImage(systemName: "flag.circle.fill")?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            endPin?.draw(at: CGPoint(x: endPoint.x - 12, y: endPoint.y - 24))
            
            // Eğer önerilen rota varsa, çiz
            if let suggestedRoute = route.suggestedRoute {
                let path = UIBezierPath()
                let polyline = suggestedRoute.polyline
                
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Düzenle", systemImage: "pencil")
                        .foregroundColor(AntColors.text)
                }
                
                if route.status == .active {
                    Button(role: .destructive) {
                        showingCancelAlert = true
                    } label: {
                        Label("İptal Et", systemImage: "xmark.circle")
                    }
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Sil", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(AntColors.primary)
            }
        }
    }
}

// InfoCard yapısı Components/InfoCard.swift dosyasına taşındı 
