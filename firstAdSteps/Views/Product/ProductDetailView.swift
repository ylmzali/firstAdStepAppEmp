import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    // Removed sampleImageNames as we'll use product.imageUrls
    @State private var selectedImageIndex = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // spacing 0 for seamless sections
                // 1. Image Carousel - Updated to use product.imageUrls
                if !product.imageUrls.isEmpty {
                    TabView(selection: $selectedImageIndex) {
                        ForEach(product.imageUrls.indices, id: \.self) { index in
                            Image(product.imageUrls[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 300) // Adjust height as needed
                } else {
                    // Placeholder for when there are no images
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .foregroundColor(.gray)
                }

                // 2. Product Information Section (Blue Background)
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name) // "Çöp Kamyonu ve Geri Dönüşüm"
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("19 parça") // Example detail
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("2+ yaş") // Example detail
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer() // Pushes button to the right if not using full width
                    
                    Button(action: {
                        cartManager.addToCart(product: product)
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("EKLE")
                        }
                        .font(.headline)
                        .foregroundColor(.blue) // Text color for button
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white) // Button background
                        .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure VStack takes full width
                .background(Color.blue) // Blue background for this section

                // 3. Description Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Faaliyetle dolu geri dönüşüm oyun seti") // Title from image
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom, 4)
                    
                    Text(product.description) // Actual product description
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.secondary)
                }
                .padding()

                // Divider
                Divider().padding(.horizontal)

                // 4. Reviews Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Yorumlar")
                        .font(.title3)
                        .fontWeight(.bold)

                    // Sample Review Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image("asli_yildiz_avatar") // Placeholder - replace with actual reviewer avatar
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text("Aslı Yıldız")
                                    .font(.headline)
                                HStack {
                                    Text("Bursa")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                    Text("4.9")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        Text("Bu oyun paketiyle kızım geri dönüşüm ile ilgili sorular sormaya başladı ve çok güzel bilgiler öğrendi. Mutfakta plastik ve kağıtları ayırmada bana çok yardımcı oluyor.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 10) {
                            Image("review_image_1") // Placeholder
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                                .clipped()
                            Image("review_image_2") // Placeholder
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                                .clipped()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6)) // Light gray background for the card
                    .cornerRadius(12)

                    Button(action: {
                        // TODO: Navigate to all reviews screen
                        print("Navigate to all reviews")
                    }) {
                        HStack {
                            Text("Bütün Yorumları Oku")
                                .fontWeight(.medium)
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationTitle(product.name) // Title from product name, as in image "Cop kamyonu"
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.primary) // Use primary color for icon
                }
            }
        }
    }
}

// Make sure your Product struct can accommodate these fields, or adjust accordingly.
// Example:
/*
struct Product: Identifiable {
    var id = UUID()
    var name: String
    var imageUrl: String // Consider an array: var imageUrls: [String]
    var price: Double
    var description: String
    // Add other fields like:
    // var pieceCount: Int?
    // var ageRange: String?
}
*/

// Sample data for Preview (ensure it matches your Product struct)
// You might need to update sampleProducts if your Product struct has changed.
/*
let sampleProducts: [Product] = [
    Product(name: "Çöp Kamyonu ve Geri Dönüşüm", imageUrl: "lego_duplo_cop_kamyonu", price: 299.99, description: "Renkli poşetleri uygun çöp kutularına koyarak renk ayırma alıştırması yapın; aç-kapat kapaklar ve sürülebilen çöp kamyonuyla ince motor becerilerini geliştirin; sınırsız rol oyunu hikayeleriyle hayal güçlerini genişletin; büyük süpürgeyle dökülen çöpleri süpürün ve yaşam boyu sürecek çevre dostu alışkanlıklar geliştirin.", pieceCount: 19, ageRange: "2+ yaş")
]
*/

#Preview {
    NavigationView {
        ProductDetailView(product: sampleProducts[0])
    }
} 