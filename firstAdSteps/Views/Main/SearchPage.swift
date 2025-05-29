import SwiftUI

struct SearchCategory: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let color: Color
}

let searchCategories: [SearchCategory] = [
    .init(emoji: "🧤", title: "Yeni Yıl", color: Color(red: 0.29, green: 0.60, blue: 1.0)),
    .init(emoji: "✍️", title: "Hayal gucu icin", color: Color(red: 1.0, green: 0.44, blue: 0.38)),
    .init(emoji: "📚", title: "Unlu kitaplar", color: Color(red: 1.0, green: 0.89, blue: 0.38)),
    .init(emoji: "🌍", title: "Cevreye saygi", color: Color(red: 0.47, green: 0.82, blue: 0.62)),
    .init(emoji: "🚀", title: "Uzayi kesfet", color: Color(red: 1.0, green: 0.44, blue: 0.38)),
    .init(emoji: "🎵", title: "Dunya muzigi", color: Color(red: 0.29, green: 0.60, blue: 1.0)),
    .init(emoji: "🧬", title: "Bilim dunyasi", color: Color(red: 0.33, green: 0.40, blue: 0.97)),
    .init(emoji: "🐶", title: "Dostlarimiz ve biz", color: Color(red: 0.67, green: 0.89, blue: 0.53))
]

struct SearchPage: View {
    @State private var searchText = ""
    @State private var searchHistory: [String] = []
    @State private var isSearchFocused: Bool = false
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredProducts: [Product] {
        guard !searchText.isEmpty else { return [] }
        return sampleProducts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .prefix(3)
            .map { $0 }
    }
    
    var autocompleteSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        let names = sampleProducts.map { $0.name }
        return names.filter { $0.localizedCaseInsensitiveContains(searchText) && $0.localizedCaseInsensitiveCompare(searchText) != .orderedSame }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            if !filteredProducts.isEmpty {
                                Text("Sonuçlar")
                                    .font(.headline)
                                    .padding(.top, 8)
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(filteredProducts) { product in
                                        ProductCard(product: product)
                                    }
                                }
                            } else {
                                Text("Sonuç bulunamadı.")
                                    .foregroundColor(.gray)
                                    .padding(.top, 16)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(searchCategories) { category in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(category.emoji)
                                        .font(.system(size: 40))
                                    Spacer()
                                    Text(category.title)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                                .background(category.color)
                                .cornerRadius(18)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Ara")
            .background(Color.white.ignoresSafeArea())
            .onAppear(perform: loadHistory)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Lego ara") {
            if searchText.isEmpty && !searchHistory.isEmpty {
                ForEach(searchHistory, id: \.self) { item in
                    Text(item).searchCompletion(item)
                }
            } else if !autocompleteSuggestions.isEmpty {
                ForEach(autocompleteSuggestions, id: \.self) { suggestion in
                    Text(suggestion).searchCompletion(suggestion)
                }
            }
        }
    }
    
    // MARK: - Search History Helpers
    func loadHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    func addToHistory(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var history = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        if let idx = history.firstIndex(of: text) { history.remove(at: idx) }
        history.insert(text, at: 0)
        if history.count > 10 { history = Array(history.prefix(10)) }
        UserDefaults.standard.set(history, forKey: "searchHistory")
        searchHistory = history
    }
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: "searchHistory")
        searchHistory = []
    }
}

#Preview {
    SearchPage()
} 
