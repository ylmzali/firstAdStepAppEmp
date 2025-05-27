import Foundation
import CoreLocation
import MapKit

@MainActor
class LocationTrackingManager: NSObject, ObservableObject {
    private var locationManager: CLLocationManager?
    
    @Published var currentLocation: CLLocation?
    @Published var heading: Double = 0
    @Published var trackedLocations: [CLLocation] = []
    @Published var totalDistance: Double = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    private var isPaused = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = true
        locationManager?.activityType = .fitness
        locationManager?.distanceFilter = 10 // 10 metre
    }
    
    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            completion(false)
        case .restricted, .denied:
            locationError = "Konum izni reddedildi. Ayarlardan izin vermeniz gerekiyor."
            completion(false)
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        requestLocationPermission { granted in
            if granted {
                self.locationManager?.requestLocation()
                
                // Add a timeout to avoid waiting indefinitely
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if let location = self.currentLocation {
                        completion(.success(location.coordinate))
                    } else {
                        completion(.failure(LocationError.locationNotAvailable))
                    }
                }
            } else {
                completion(.failure(LocationError.permissionDenied))
            }
        }
    }
    
    enum LocationError: Error {
        case permissionDenied
        case locationNotAvailable
    }
    
    func startTracking() {
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
        isPaused = false
    }
    
    func stopTracking() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
    }
    
    func pauseTracking() {
        isPaused = true
    }
    
    func resumeTracking() {
        isPaused = false
    }
    
    private func updateTotalDistance() {
        guard trackedLocations.count >= 2 else { return }
        
        let lastLocation = trackedLocations[trackedLocations.count - 1]
        let previousLocation = trackedLocations[trackedLocations.count - 2]
        let distance = lastLocation.distance(from: previousLocation)
        
        totalDistance += distance
    }
    
    // Kullanıcının belirli bir konuma olan uzaklığını kontrol eden fonksiyon
    func checkDistanceToLocation(_ targetLocation: CLLocationCoordinate2D, maximumDistance: Double = 50) async -> Result<Bool, LocationError> {
        return await withCheckedContinuation { continuation in
            requestLocation { result in
                switch result {
                case .success(let userLocation):
                    let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    let targetCLLocation = CLLocation(latitude: targetLocation.latitude, longitude: targetLocation.longitude)
                    
                    let distance = userCLLocation.distance(from: targetCLLocation)
                    continuation.resume(returning: .success(distance <= maximumDistance))
                    
                case .failure:
                    // Herhangi bir hata durumunda konum kullanılamıyor olarak değerlendir
                    continuation.resume(returning: .failure(.locationNotAvailable))
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationTrackingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isPaused else { return }
        
        currentLocation = location
        trackedLocations.append(location)
        updateTotalDistance()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        locationError = "Konum alınamadı: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            // Always izni henüz alınmamışsa iste
            manager.requestAlwaysAuthorization()
            startTracking()
            locationError = nil
        case .authorizedAlways:
            startTracking()
            locationError = nil
        case .denied, .restricted:
            locationError = "Konum izni reddedildi. Lütfen ayarlardan konum iznini etkinleştirin."
            stopTracking()
        case .notDetermined:
            locationError = "Konum izni henüz verilmedi."
        @unknown default:
            break
        }
    }
} 
