import Foundation
import CoreLocation
import SwiftUI
import MapKit

// MARK: - Supporting Types
enum AreaType: String, Codable, CaseIterable {
    case outdoor = "Açık Alan"
    case indoor = "Kapalı Alan"
}

enum RouteCategory: String, Codable, CaseIterable {
    case walking = "Yürüyüş"
    case running = "Koşu"
    case delivery = "Teslimat"
}

enum RouteStatus: String, Codable, CaseIterable {
    case active = "Aktif"
    case completed = "Tamamlandı"
    case cancelled = "İptal Edildi"
}

struct LocationCoordinate: Codable {
    var latitude: Double
    var longitude: Double
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Main Route Type
struct Route: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var category: RouteCategory
    var status: RouteStatus
    var startLocation: LocationCoordinate
    var endLocation: LocationCoordinate
    var assignedDate: Date
    var completionProgress: Double
    var duration: TimeInterval // dakika cinsinden süre
    var areaType: AreaType
    var suggestedRoute: MKRoute?
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         category: RouteCategory = .walking,
         status: RouteStatus = .active,
         startLocation: LocationCoordinate,
         endLocation: LocationCoordinate,
         assignedDate: Date = Date(),
         completionProgress: Double = 0.0,
         duration: TimeInterval = 60,
         areaType: AreaType = .outdoor,
         suggestedRoute: MKRoute? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.status = status
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.assignedDate = assignedDate
        self.completionProgress = completionProgress
        self.duration = duration
        self.areaType = areaType
        self.suggestedRoute = suggestedRoute
    }
}

// MARK: - Codable Conformance
extension Route: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, description, category, status
        case startLocation, endLocation, assignedDate
        case completionProgress, duration, areaType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(status, forKey: .status)
        try container.encode(startLocation, forKey: .startLocation)
        try container.encode(endLocation, forKey: .endLocation)
        try container.encode(assignedDate, forKey: .assignedDate)
        try container.encode(completionProgress, forKey: .completionProgress)
        try container.encode(duration, forKey: .duration)
        try container.encode(areaType, forKey: .areaType)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(RouteCategory.self, forKey: .category)
        status = try container.decode(RouteStatus.self, forKey: .status)
        startLocation = try container.decode(LocationCoordinate.self, forKey: .startLocation)
        endLocation = try container.decode(LocationCoordinate.self, forKey: .endLocation)
        assignedDate = try container.decode(Date.self, forKey: .assignedDate)
        completionProgress = try container.decode(Double.self, forKey: .completionProgress)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        areaType = try container.decode(AreaType.self, forKey: .areaType)
        suggestedRoute = nil
    }
} 
