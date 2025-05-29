import SwiftUI

enum OrderStatusCardType {
    case preparing
    case shipped
    case last5Days
}

struct OrderStatusCardModel {
    let type: OrderStatusCardType
    let packageInfo: String
    let action: (() -> Void)?
} 