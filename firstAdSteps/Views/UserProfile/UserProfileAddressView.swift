//
//  UserProfileAddressView.swift
//  re-brick-app-1
//
//  Created by Ali YILMAZ on 25.05.2025.
//

import SwiftUI


struct UserProfileAddressView: View {
    @State private var addresses: [Address] = [
        Address(id: UUID().uuidString, street: "Moda Sk. No:5", city: "İstanbul", zipCode: "34710", country: "Türkiye", isDefault: true),
        Address(id: UUID().uuidString, street: "Büyükdere Cd. No:10", city: "İstanbul", zipCode: "34394", country: "Türkiye", isDefault: false)
    ]
    @State private var selectedAddress: Address? = nil
    @State private var showEdit: Bool = false
    @State private var showAdd: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(addresses) { address in
                        Button(action: {
                            selectedAddress = address
                            showEdit = true
                        }) {
                            AddressCardView(address: address)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Adreslerim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAdd = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            if let address = selectedAddress, let idx = addresses.firstIndex(where: { $0.id == address.id }) {
                AddressEditView(address: $addresses[idx], isNewAddress: false, onDelete: {
                    addresses.remove(at: idx)
                    selectedAddress = nil
                })
            }
        }
        .sheet(isPresented: $showAdd) {
            AddressEditView(
                address: .constant(Address(id: UUID().uuidString, street: "", city: "", zipCode: "", country: "Türkiye", isDefault: false)),
                isNewAddress: true,
                onSave: { newAddress in
                    var addressToAdd = newAddress
                    if addressToAdd.isDefault {
                        for i in addresses.indices {
                            addresses[i].isDefault = false
                        }
                    }
                    addresses.append(addressToAdd)
                }
            )
        }
        .onAppear(perform: loadAddresses)
    }
    
    func loadAddresses() {
        // Example: Load from UserDefaults if available, otherwise use sample
        // self.addresses = UserDefaults.standard.codableArray(forKey: "userProfileAddresses", defaultValue: self.addresses)
        // For now, we'll just use the sample data or what's in the @State
    }

    func saveAddresses() {
        // Example: Save to UserDefaults
        // UserDefaults.standard.setCodableArray(self.addresses, forKey: "userProfileAddresses")
    }
}

struct AddressCardView: View {
    let address: Address
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(address.street)
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                if address.isDefault {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            Text("\(address.city), \(address.zipCode)")
                .font(.subheadline)
                .foregroundColor(.primary)
            Text(address.country)
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

struct AddressEditView: View {
    @Binding var address: Address
    var isNewAddress: Bool
    var onSave: ((Address) -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    @State private var isDefault: Bool = false
    
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Adres Detayları")) {
                    TextField("Sokak / Cadde", text: $street)
                    TextField("Şehir", text: $city)
                    TextField("Posta Kodu", text: $zipCode)
                    TextField("Ülke", text: $country)
                    Toggle("Varsayılan adres yap", isOn: $isDefault)
                }
                
                if !isNewAddress {
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Adresi Sil")
                            }
                        }
                        .alert("Adresi silmek istediğinize emin misiniz?", isPresented: $showDeleteAlert) {
                            Button("Sil", role: .destructive) {
                                onDelete?()
                                dismiss()
                            }
                            Button("İptal", role: .cancel) {}
                        }
                    }
                }
            }
            .navigationTitle(isNewAddress ? "Yeni Adres Ekle" : "Adresi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        var updatedAddress = address
                        updatedAddress.street = street
                        updatedAddress.city = city
                        updatedAddress.zipCode = zipCode
                        updatedAddress.country = country
                        updatedAddress.isDefault = isDefault
                        
                        if isNewAddress {
                            onSave?(updatedAddress)
                        } else {
                            address = updatedAddress
                        }
                        dismiss()
                    }
                    .disabled(street.isEmpty || city.isEmpty || zipCode.isEmpty || country.isEmpty)
                }
            }
            .onAppear {
                street = address.street
                city = address.city
                zipCode = address.zipCode
                country = address.country
                isDefault = address.isDefault
            }
        }
    }
}
