import Foundation
import SwiftUI

@MainActor
class RouteViewModel: ObservableObject {
    @Published var routes: [Route] = []
    @Published var filteredRoutes: [Route] = []
    @Published var selectedFilter: RouteStatus?
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Mock veriler
        let mockRoutes = [
            Route(name: "Kadıköy Turu",
                  description: "Kadıköy merkez bölgesinde reklam turu",
                  startLocation: LocationCoordinate(latitude: 40.9909, longitude: 29.0233),
                  endLocation: LocationCoordinate(latitude: 40.9909, longitude: 29.0333),
                  duration: 120,
                  areaType: .outdoor),
            Route(name: "Üsküdar Sahil",
                  description: "Üsküdar sahil şeridi boyunca reklam turu",
                  category: .running,
                  startLocation: LocationCoordinate(latitude: 41.0234, longitude: 29.0152),
                  endLocation: LocationCoordinate(latitude: 41.0334, longitude: 29.0152),
                  duration: 90,
                  areaType: .outdoor),
            Route(name: "TÜYAP Fuar Merkezi",
                  description: "Fuar merkezi içi reklam rotası",
                  category: .walking,
                  startLocation: LocationCoordinate(latitude: 41.0016, longitude: 28.8093),
                  endLocation: LocationCoordinate(latitude: 41.0020, longitude: 28.8100),
                  duration: 45,
                  areaType: .indoor)
        ]
        
        self.routes = mockRoutes
        self.filteredRoutes = mockRoutes
    }
    
    func filterRoutes(by status: RouteStatus?) {
        selectedFilter = status
        if let status = status {
            filteredRoutes = routes.filter { $0.status == status }
        } else {
            filteredRoutes = routes
        }
    }
    
    func updateRouteProgress(_ route: Route, progress: Double) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            var updatedRoute = route
            updatedRoute.completionProgress = progress
            if progress >= 1.0 {
                updatedRoute.status = .completed
            }
            routes[index] = updatedRoute
            filterRoutes(by: selectedFilter)
        }
    }
    
    func addRoute(_ route: Route) {
        routes.append(route)
        filterRoutes(by: selectedFilter)
    }
    
    func deleteRoute(_ route: Route) {
        routes.removeAll { $0.id == route.id }
        filterRoutes(by: selectedFilter)
    }
    
    func deleteRoutes(at indexSet: IndexSet) {
        routes.remove(atOffsets: indexSet)
        filterRoutes(by: selectedFilter)
    }
    
    func updateRoute(_ route: Route) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            routes[index] = route
            filterRoutes(by: selectedFilter)
        }
    }
    
    func cancelRoute(_ route: Route) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            var updatedRoute = route
            updatedRoute.status = .cancelled
            updatedRoute.completionProgress = 0.0
            routes[index] = updatedRoute
            filterRoutes(by: selectedFilter)
        }
    }
} 
