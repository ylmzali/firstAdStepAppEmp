import SwiftUI

struct DeliveryAddressView: View {
    var onContinue: (Address) -> Void // Updated callback to pass selected Address
    @State private var selectedAddressId: String?
    @State private var showingAddNewAddressSheet = false
    
    // Load addresses from UserDefaults, default to sample if none found
    @State private var addresses: [Address] = UserDefaults.standard.codableArray(forKey: "userAddresses", defaultValue: [
        Address(id: UUID().uuidString, street: "123 Örnek Sokak", city: "Ankara", zipCode: "06500", country: "Türkiye", isDefault: true),
        Address(id: UUID().uuidString, street: "456 Başka Bir Cadde", city: "İstanbul", zipCode: "34700", country: "Türkiye")
    ])

    var body: some View {
        VStack(alignment: .leading) {
            Text("Teslimat Adresi")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom)

            if addresses.isEmpty {
                Text("Kayıtlı adresiniz bulunmamaktadır. Lütfen yeni bir adres ekleyin.")
                    .foregroundColor(.gray)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(addresses) { address in
                        AddressRow(address: address, isSelected: selectedAddressId == address.id)
                            .contentShape(Rectangle()) // Make the whole row tappable
                            .onTapGesture {
                                selectedAddressId = address.id
                            }
                    }
                    .onDelete(perform: deleteAddress) // Add delete functionality
                }
                .listStyle(PlainListStyle())
                .toolbar { EditButton() } // Add EditButton for deleting
            }

            Button(action: {
                showingAddNewAddressSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Yeni Adres Ekle")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Spacer()
            
            Button(action: {
                if let addressId = selectedAddressId,
                   let address = addresses.first(where: { $0.id == addressId }) {
                    onContinue(address) // Pass the selected address object
                }
            }) {
                Text("Devam Et")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAddressId != nil ? Color.blue : Color.gray) 
                    .cornerRadius(10)
            }
            .disabled(selectedAddressId == nil) 
            .padding(.bottom)
        }
        .padding()
        .sheet(isPresented: $showingAddNewAddressSheet) {
            AddNewAddressView { newAddress in
                addAddress(newAddress)
            }
        }
        .onAppear {
            loadAddresses()
            if selectedAddressId == nil, let defaultAddress = addresses.first(where: { $0.isDefault }) {
                selectedAddressId = defaultAddress.id
            } else if selectedAddressId == nil && !addresses.isEmpty {
                 selectedAddressId = addresses.first?.id // Select the first one if no default
            }
        }
    }
    
    func loadAddresses() {
        self.addresses = UserDefaults.standard.codableArray(forKey: "userAddresses", defaultValue: self.addresses)
    }

    func saveAddresses() {
        UserDefaults.standard.setCodableArray(self.addresses, forKey: "userAddresses")
    }

    func addAddress(_ address: Address) {
        if address.isDefault {
            for i in addresses.indices {
                addresses[i].isDefault = false
            }
        }
        addresses.append(address)
        selectedAddressId = address.id // Optionally select the new address
        saveAddresses()
    }

    func deleteAddress(at offsets: IndexSet) {
        addresses.remove(atOffsets: offsets)
        if selectedAddressId != nil && !addresses.contains(where: { $0.id == selectedAddressId }) {
            selectedAddressId = addresses.first?.id // Select first if selected was deleted
        }
        saveAddresses()
    }
}

struct AddressRow: View {
    let address: Address
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(address.street).font(.headline)
                Text("\(address.city), \(address.zipCode)")
                Text(address.country)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddNewAddressView: View {
    @Environment(\.dismiss) var dismiss
    var onAdd: (Address) -> Void // This onAdd will now call DeliveryAddressView's addAddress

    @State private var street: String = ""
    @State private var city: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = "Türkiye"
    @State private var isDefaultAddress: Bool = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Sokak / Cadde", text: $street)
                TextField("Şehir", text: $city)
                TextField("Posta Kodu", text: $zipCode)
                TextField("Ülke", text: $country) // Could be a Picker for more control
                Toggle("Varsayılan adres yap", isOn: $isDefaultAddress)
                
                Button("Adresi Kaydet") {
                    let newAddress = Address(id: UUID().uuidString, 
                                           street: street, 
                                           city: city, 
                                           zipCode: zipCode, 
                                           country: country, 
                                           isDefault: isDefaultAddress)
                    onAdd(newAddress) // This now calls the method in DeliveryAddressView
                    dismiss()
                }
                .disabled(street.isEmpty || city.isEmpty || zipCode.isEmpty || country.isEmpty)
            }
            .navigationTitle("Yeni Adres Ekle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
}

// Helper extension for UserDefaults to handle Codable arrays
extension UserDefaults {
    func setCodableArray<T: Codable>(_ data: [T], forKey defaultName: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            self.set(encoded, forKey: defaultName)
        }
    }

    func codableArray<T: Codable>(forKey defaultName: String, defaultValue: [T] = []) -> [T] {
        guard let data = self.data(forKey: defaultName) else { return defaultValue }
        let decoder = JSONDecoder()
        return (try? decoder.decode([T].self, from: data)) ?? defaultValue
    }
}

#Preview {
    NavigationView {
        DeliveryAddressView(onContinue: { address in print("Continue to payment with address: \(address.street)") })
    }
} 