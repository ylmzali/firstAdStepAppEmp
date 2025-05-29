import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case none = "Sıralama Yok"
    case mostRented = "En Çok Kiralananlar"
    case priceAscending = "Artan Fiyata Göre"
    case priceDescending = "Azalan Fiyata Göre"
    case newest = "Yeni Eklenenler"
    case mostReviewed = "En Çok Yorumlananlar"
    
    var id: String { self.rawValue }
}

enum AgeRangeOption: String, CaseIterable, Identifiable {
    case all = "Tümü"
    case sixPlus = "6+"
    case twelvePlus = "12+"
    case eighteenPlus = "18+"
    
    var id: String { self.rawValue }
}

enum PieceCountRangeOption: String, CaseIterable, Identifiable {
    case all = "Tümü"
    case zeroToFifty = "0 - 50"
    case fiftyOneToTwoHundred = "51 - 200"
    case twoHundredOneToFiveHundred = "201 - 500"
    case fiveHundredOneToTwoThousand = "501 - 2000"
    // Gerekirse daha fazla aralık eklenebilir
    
    var id: String { self.rawValue }
}

struct AllProductsView: View {
    @State private var allProducts: [Product] = sampleProducts // Orijinal liste
    @State private var displayedProducts: [Product] = sampleProducts // Gösterilecek ürünler (sayfalama için)
    
    // Filtreleme ve Sıralama için @State değişkenleri
    @State private var selectedSortOption: SortOption = .none
    @State private var selectedCategory: String? = nil // String olarak tutacağız, çünkü kategoriler dinamik olabilir
    @State private var selectedAgeRange: AgeRangeOption = .all
    @State private var selectedPieceCountRange: PieceCountRangeOption = .all
    
    @State private var showingFilters = false
    
    // Kategorileri sampleProducts'tan dinamik olarak alalım (tekrarları önleyerek)
    private var availableCategories: [String] {
        Array(Set(sampleProducts.map { $0.category })).sorted()
    }
    
    // Grid layout için sütunlar
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ] // 2 sütunlu olarak güncelledim, 3 çok sıkışık olabilir
    
    // Filtrelenmiş ve sıralanmış ürünler
    var filteredAndSortedProducts: [Product] {
        var productsToDisplay = allProducts
        
        // Kategoriye göre filtrele
        if let category = selectedCategory {
            productsToDisplay = productsToDisplay.filter { $0.category == category }
        }
        
        // Yaş aralığına göre filtrele
        switch selectedAgeRange {
        case .sixPlus:
            productsToDisplay = productsToDisplay.filter { product in
                // Yaş aralığı "X+" formatında veya "X-Y" olabilir. Şimdilik "X+" varsayalım.
                // Product modelindeki ageRange'i parse etmek gerekebilir.
                // Basit bir kontrol: "6+" ise 6 ve üstü tüm yaşları kapsar.
                // Bu mantık ürün verisine göre daha detaylı olmalı.
                guard let ageStr = product.ageRange?.replacingOccurrences(of: "+", with: ""), let age = Int(ageStr) else { return false }
                return age >= 6
            }
        case .twelvePlus:
            productsToDisplay = productsToDisplay.filter { product in
                guard let ageStr = product.ageRange?.replacingOccurrences(of: "+", with: ""), let age = Int(ageStr) else { return false }
                return age >= 12
            }
        case .eighteenPlus:
            productsToDisplay = productsToDisplay.filter { product in
                guard let ageStr = product.ageRange?.replacingOccurrences(of: "+", with: ""), let age = Int(ageStr) else { return false }
                return age >= 18
            }
        case .all:
            break // Filtreleme yok
        }
        
        // Parça sayısına göre filtrele
        switch selectedPieceCountRange {
        case .zeroToFifty:
            productsToDisplay = productsToDisplay.filter { $0.pieceCount ?? 0 <= 50 }
        case .fiftyOneToTwoHundred:
            productsToDisplay = productsToDisplay.filter { ($0.pieceCount ?? 0 >= 51) && ($0.pieceCount ?? 0 <= 200) }
        case .twoHundredOneToFiveHundred:
            productsToDisplay = productsToDisplay.filter { ($0.pieceCount ?? 0 >= 201) && ($0.pieceCount ?? 0 <= 500) }
        case .fiveHundredOneToTwoThousand:
            productsToDisplay = productsToDisplay.filter { ($0.pieceCount ?? 0 >= 501) && ($0.pieceCount ?? 0 <= 2000) }
        case .all:
            break // Filtreleme yok
        }
        
        // Sıralama
        switch selectedSortOption {
        case .mostRented:
            productsToDisplay.sort { $0.rentalCount > $1.rentalCount }
        case .priceAscending:
            productsToDisplay.sort { $0.price < $1.price }
        case .priceDescending:
            productsToDisplay.sort { $0.price > $1.price }
        case .newest:
            productsToDisplay.sort { $0.dateAdded > $1.dateAdded }
        case .mostReviewed:
            productsToDisplay.sort { $0.reviewCount > $1.reviewCount }
        case .none:
            break // Sıralama yok
        }
        
        return productsToDisplay
    }
    
    var body: some View {
        // NavigationView zaten MainView'dan geliyor olmalı, burada tekrar eklemeye gerek yok
        // Eğer bu View bağımsız olarak da kullanılacaksa NavigationView kalabilir.
        // Şimdilik MainView'daki NavigationStack'e güvendiğimizi varsayıyorum.
        //NavigationView {
            VStack(spacing: 0) {
                // Filtre ve Sıralama Butonları
                ScrollView {

                    HStack {
                        Button(action: {
                            showingFilters.toggle()
                        }) {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease")
                                Text("Filtrele")
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        Menu {
                            Picker("Sırala", selection: $selectedSortOption) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text(selectedSortOption == .none ? "Sırala" : selectedSortOption.rawValue.prefix(15) + "...")
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6).opacity(0.9))
                
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredAndSortedProducts) { product in // Filtrelenmiş ve sıralanmış ürünleri kullan
                            ProductCard(product: product)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Tüm Ürünler")
            // .navigationBarTitleDisplayMode(.inline) // .inline daha iyi görünebilir
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    availableCategories: availableCategories,
                    selectedCategory: $selectedCategory,
                    selectedAgeRange: $selectedAgeRange,
                    selectedPieceCountRange: $selectedPieceCountRange,
                    onApply: {
                        // Filtreler uygulandığında listeyi güncellemek için buraya mantık eklenebilir
                        // Şu anda computed property bunu otomatik yapıyor.
                        showingFilters = false
                    }
                )
            }
        //}
    }
}

// Filtreleme seçeneklerinin sunulacağı ayrı bir View
struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    
    let availableCategories: [String]
    @Binding var selectedCategory: String?
    @Binding var selectedAgeRange: AgeRangeOption
    @Binding var selectedPieceCountRange: PieceCountRangeOption
    
    var onApply: () -> Void
    
    // Yaş aralıkları için kolay erişim
    private let ageRanges = AgeRangeOption.allCases
    private let pieceCountRanges = PieceCountRangeOption.allCases

    private var categoriesForPicker: [String] {
        ["Tümü"] + availableCategories
    }
    
    var body: some View {
        NavigationView { // Sheet içinde kendi NavigationView\'ı olması iyi bir pratik
            Form {
                Section(header: Text("Kategori")) {
                    Picker("Kategori Seç", selection: $selectedCategory) {
                        ForEach(0..<categoriesForPicker.count, id: \.self) { index in
                            let categoryValue = categoriesForPicker[index]
                            Text(categoryValue).tag(categoryValue == "Tümü" ? Optional<String>.none : Optional(categoryValue))
                        }
                    }
                }
                
                Section(header: Text("Yaş Aralığı")) {
                    Picker("Yaş Aralığı Seç", selection: $selectedAgeRange) {
                        ForEach(ageRanges) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
                
                Section(header: Text("Parça Sayısı")) {
                    Picker("Parça Sayısı Seç", selection: $selectedPieceCountRange) {
                        ForEach(pieceCountRanges) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
                
                Button("Filtreleri Uygula") {
                    onApply()
                    // dismiss() // onApply içinde showingFilters = false yapıldığı için gerek kalmayabilir
                }
            }
            .navigationTitle("Filtrele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "resetFilters", placement: .navigationBarLeading) {
                    Button("Sıfırla") {
                        selectedCategory = nil
                        selectedAgeRange = .all
                        selectedPieceCountRange = .all
                        // onApply() // İsteğe bağlı olarak sıfırlayınca da hemen uygulanabilir
                        // dismiss()
                    }
                }
                ToolbarItem(id: "closeFilters", placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    // Preview için NavigationView sarmalayıcısı önemli
    NavigationView {
        AllProductsView()
    }
} 
