//
//  OrderTrackingView.swift
//  re-brick-app-1
//
//  Created by Ali YILMAZ on 25.05.2025.
//

import SwiftUI

struct OrderTrackingPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                HStack {
                    OrderStatusView(steps: [
                        OrderStatusStep(title: "Siparişin hazırlanıyor", subtitle: nil, isCompleted: true, isCurrent: false, actionTitle: nil, action: nil),
                        OrderStatusStep(title: "Siparişin kargoya verildi", subtitle: nil, isCompleted: true, isCurrent: false, actionTitle: "SİPARİŞİ TAKİP ET", action: { print("Takip et") }),
                        OrderStatusStep(title: "Siparişin teslim edildi", subtitle: nil, isCompleted: false, isCurrent: false, actionTitle: nil, action: nil),
                        OrderStatusStep(title: "Siparişinin son 5 günü", subtitle: "KURYE AYARLA", isCompleted: false, isCurrent: false, actionTitle: nil, action: nil),
                        OrderStatusStep(title: "Lego bize ulaştı. Teşekkürler!", subtitle: nil, isCompleted: false, isCurrent: false, actionTitle: nil, action: nil)
                    ])
                    .frame(width: .infinity)
                }
                .frame(width: .infinity)
                
                HStack {
                    OrderSummaryView(
                        products: [
                            OrderProduct(imageName: "lego-1", title: "Tren İstasyonu", pieceCount: 2925, age: "12+ yaş", duration: "1 ay kiralandı"),
                            OrderProduct(imageName: "lego-2", title: "Tren İstasyonu", pieceCount: 2925, age: "12+ yaş", duration: "1 ay kiralandı"),
                            OrderProduct(imageName: "lego-3", title: "Tren İstasyonu", pieceCount: 2925, age: "12+ yaş", duration: "1 ay kiralandı")
                        ],
                        orderTotal: 300,
                        shipping: 15
                    )
                    
                }
                .frame(width: .infinity)
            }
            .padding(.vertical)
        }
        .navigationTitle("Sipariş Takibi")
    }
}

struct OrderStatusStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let isCompleted: Bool
    let isCurrent: Bool
    let actionTitle: String?
    let action: (() -> Void)?
}

struct OrderStatusView: View {
    let steps: [OrderStatusStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Sipariş durumu")
                .font(.title2).bold()
                .padding(.bottom, 24)
            
            ForEach(Array(steps.enumerated()), id: \.element.id) { idx, step in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(step.isCompleted ? Color.green : Color.gray.opacity(0.4))
                            .frame(width: 28, height: 28)
                            .overlay(
                                step.isCompleted
                                ? Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                : nil
                            )
                        if idx < steps.count - 1 {
                            Rectangle()
                                .fill(step.isCompleted ? Color.green : Color.gray.opacity(0.4))
                                .frame(width: 4, height: 40)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title)
                            .font(.headline)
                            .foregroundColor(step.isCompleted ? .black : .gray)
                        if let subtitle = step.subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if let actionTitle = step.actionTitle, let action = step.action {
                            Button(action: action) {
                                Text(actionTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                            .padding(.top, 2)
                        }
                    }
                }
                .padding(.bottom, -2)
            }
        }
        .padding()
    }
}

struct OrderProduct: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let pieceCount: Int
    let age: String
    let duration: String
}

struct OrderSummaryView: View {
    let products: [OrderProduct]
    let orderTotal: Int
    let shipping: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sipariş özeti")
                .font(.title2).bold()
                .padding(.bottom, 8)
            
            ForEach(products) { product in
                HStack(alignment: .top, spacing: 12) {
                    Image(product.imageName)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.title)
                            .font(.headline)
                        HStack(spacing: 12) {
                            Label("\(product.pieceCount)", systemImage: "square.grid.2x2")
                                .font(.subheadline)
                            Label(product.age, systemImage: "person")
                                .font(.subheadline)
                        }
                        Text(product.duration)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            
            Divider()
            
            HStack {
                Text("Sipariş:")
                Spacer()
                Text("\(orderTotal) ₺")
            }
            HStack {
                Text("Kargo:")
                Spacer()
                Text("\(shipping) ₺")
            }
            HStack {
                Text("Toplam:")
                    .fontWeight(.bold)
                Spacer()
                Text("\(orderTotal + shipping) ₺")
                    .fontWeight(.bold)
            }
        }
        .padding()
    }
}

struct MainPageOrderStatusSections: View {
    @State private var showTracking = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Siparişin hazırlanıyor.")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 8, topTrailing: 8))
                    .fill(Theme.blue400))
                .frame(width: .infinity)

                VStack(alignment: .leading) {
                    Text("4 lego paketi, 1 hediye kartı")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.9))
                    Button(action: {
                        showTracking = true
                    }) {
                        Text("DETAYLARI GÖR")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                }
                .padding()
            }
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.blue400.opacity(0.2), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 6)
            .padding()
        }
        .frame(width: .infinity)
        .sheet(isPresented: $showTracking) {
            OrderTrackingPage()
        }
    }
}

#Preview {
    OrderTrackingPage()
}
