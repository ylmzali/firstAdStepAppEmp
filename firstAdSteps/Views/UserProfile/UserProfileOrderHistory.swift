//
//  UserProfileOrderHistory.swift
//  re-brick-app-1
//
//  Created by Ali YILMAZ on 25.05.2025.
//

import SwiftUI


struct Order: Identifiable, Equatable {
    let id: UUID
    var title: String
    var status: String
    var date: String
    var detail: String
}

struct UserProfileOrderHistory: View {
    @State private var orders: [Order] = [
        Order(id: UUID(), title: "#12345 - 2 Lego Seti", status: "Teslim edildi", date: "12.06.2024", detail: "2x Marvel Lego Seti, Kargo: Yurtiçi, Takip: 123456"),
        Order(id: UUID(), title: "#12344 - 1 Hediye Kartı", status: "Kargoda", date: "05.06.2024", detail: "1x Hediye Kartı, Kargo: MNG, Takip: 654321")
    ]
    @State private var selectedOrder: Order? = nil
    @State private var showDetail: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(orders) { order in
                        Button(action: {
                            selectedOrder = order
                            showDetail = true
                        }) {
                            OrderCardView(order: order)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Sipariş Geçmişim")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDetail) {
            // if let order = selectedOrder {
                // OrderDetailView(order: order)
                OrderTrackingPage()
                
            // }
        }
    }
}

struct OrderCardView: View {
    let order: Order
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(order.title)
                .font(.headline)
                .foregroundColor(.purple)
            Text(order.status)
                .font(.subheadline)
                .foregroundColor(order.status == "Teslim edildi" ? .green : .orange)
            Text(order.date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(order.title)
                    .font(.title3).bold()
                Text(order.status)
                    .font(.headline)
                    .foregroundColor(order.status == "Teslim edildi" ? .green : .orange)
                Text("Tarih: \(order.date)")
                    .font(.subheadline)
                Divider()
                Text(order.detail)
                    .font(.body)
                Spacer()
            }
            .padding()
            .navigationTitle("Sipariş Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfileOrderHistory()
}
