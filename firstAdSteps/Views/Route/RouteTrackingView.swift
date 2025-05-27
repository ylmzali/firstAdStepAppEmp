import SwiftUI
import MapKit
import CoreLocation

struct RouteTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: RouteViewModel
    @StateObject private var trackingManager = LocationTrackingManager()
    @StateObject private var regionManager: MapRegionManager
    
    @State private var isPaused = false
    @State private var showingPauseAlert = false
    @State private var showingEndAlert = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    let route: Route
    
    init(route: Route) {
        self.route = route
        
        // Initialize regionManager with the route's start location
        let initialRegion = MKCoordinateRegion(
            center: route.startLocation.toCLLocationCoordinate2D(),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        _regionManager = StateObject(wrappedValue: MapRegionManager(initialRegion: initialRegion))
    }
    
    var body: some View {
        ZStack {
            // Harita Görünümü
            TrackingMapView(
                regionManager: regionManager,
                route: route,
                userLocation: trackingManager.currentLocation,
                userHeading: trackingManager.heading,
                trackedLocations: trackingManager.trackedLocations
            )
            .ignoresSafeArea()
            
            // Üst Bilgi Paneli
            VStack {
                if let error = trackingManager.locationError {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                }
                
                TrackingInfoPanel(
                    routeName: route.name,
                    elapsedTime: elapsedTime,
                    distance: trackingManager.totalDistance,
                    isPaused: isPaused
                )
                .padding()
                
                Spacer()
                
                // Alt Kontrol Paneli
                TrackingControlPanel(
                    isPaused: $isPaused,
                    onPauseTap: handlePause,
                    onEndTap: handleEnd
                )
                .padding(.bottom)
            }
        }
        .alert("Molaya Al", isPresented: $showingPauseAlert) {
            Button("Devam Et", role: .cancel) {}
            Button(isPaused ? "Yürüyüşe Devam Et" : "Molaya Al") {
                togglePause()
            }
        } message: {
            Text(isPaused ? "Yürüyüşe devam etmek istiyor musunuz?" : "Molaya almak istiyor musunuz?")
        }
        .alert("Yürüyüşü Bitir", isPresented: $showingEndAlert) {
            Button("Vazgeç", role: .cancel) {}
            Button("Bitir", role: .destructive) {
                endTracking()
            }
        } message: {
            Text("Yürüyüşü bitirmek istediğinizden emin misiniz?")
        }
        .onAppear {
            startTracking()
        }
        .onDisappear {
            stopTracking()
        }
    }
    
    private func startTracking() {
        trackingManager.startTracking()
        startTimer()
    }
    
    private func stopTracking() {
        trackingManager.stopTracking()
        timer?.invalidate()
        timer = nil
    }
    
    private func handlePause() {
        showingPauseAlert = true
    }
    
    private func handleEnd() {
        showingEndAlert = true
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
            timer = nil
            trackingManager.pauseTracking()
        } else {
            startTimer()
            trackingManager.resumeTracking()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isPaused {
                elapsedTime += 1
            }
        }
    }
    
    private func endTracking() {
        stopTracking()
        
        // Rota ilerleme durumunu hesapla
        let progress = calculateProgress()
        viewModel.updateRouteProgress(route, progress: progress)
        
        dismiss()
    }
    
    private func calculateProgress() -> Double {
        // Toplam mesafeyi kilometre cinsinden al
        let totalDistanceKm = trackingManager.totalDistance / 1000.0
        
        // Hedef mesafeyi hesapla (başlangıç ve bitiş noktaları arası)
        let startLocation = CLLocation(latitude: route.startLocation.latitude, longitude: route.startLocation.longitude)
        let endLocation = CLLocation(latitude: route.endLocation.latitude, longitude: route.endLocation.longitude)
        let targetDistanceKm = startLocation.distance(from: endLocation) / 1000.0
        
        // İlerlemeyi hesapla (0.0 - 1.0 arası)
        let progress = min(totalDistanceKm / targetDistanceKm, 1.0)
        return progress
    }
}

// MARK: - Alt Bileşenler
struct TrackingInfoPanel: View {
    let routeName: String
    let elapsedTime: TimeInterval
    let distance: Double
    let isPaused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(routeName)
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                    Text("Süre")
                        .font(.caption)
                }
                
                VStack {
                    Text(String(format: "%.2f km", distance / 1000))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                    Text("Mesafe")
                        .font(.caption)
                }
            }
            
            if isPaused {
                Text("MOLA")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct TrackingControlPanel: View {
    @Binding var isPaused: Bool
    let onPauseTap: () -> Void
    let onEndTap: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: onPauseTap) {
                VStack {
                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 44))
                    Text(isPaused ? "Devam Et" : "Mola")
                        .font(.caption)
                }
            }
            .foregroundColor(isPaused ? .green : .orange)
            
            Button(action: onEndTap) {
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44))
                    Text("Bitir")
                        .font(.caption)
                }
            }
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
} 
