import SwiftUI
import MapKit

// MARK: - Form Components
struct RouteBasicInfoView: View {
    @Binding var name: String
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.sm) {
            Text("Temel Bilgiler")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
            
            TextField("Rota Adı", text: $name)
                .textFieldStyle(AntTextFieldStyle())
            
            TextField("Açıklama", text: $description, axis: .vertical)
                .textFieldStyle(AntTextFieldStyle())
                .lineLimit(3, reservesSpace: true)
        }
        .padding(AntSpacing.md)
        .background(Color.white)
        .cornerRadius(AntCornerRadius.md)
    }
}

struct RouteCategoryView: View {
    @Binding var category: RouteCategory
    @Binding var areaType: AreaType
    let onAreaTypeChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.sm) {
            Text("Kategori ve Alan")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
            
            Picker("Kategori", selection: $category) {
                ForEach(RouteCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Alan Türü", selection: $areaType) {
                ForEach(AreaType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: areaType) { _ in
                onAreaTypeChange()
            }
        }
        .padding(AntSpacing.md)
        .background(Color.white)
        .cornerRadius(AntCornerRadius.md)
    }
}

struct RouteDurationView: View {
    @Binding var duration: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.sm) {
            Text("Süre")
                .font(.system(size: AntTypography.heading5))
                .foregroundColor(AntColors.text)
            
            HStack {
                Stepper("", value: $duration, in: 5...480, step: 5)
                Text("\(Int(duration)) dakika")
                    .font(.system(size: AntTypography.paragraph))
                    .foregroundColor(AntColors.text)
            }
        }
        .padding(AntSpacing.md)
        .background(Color.white)
        .cornerRadius(AntCornerRadius.md)
    }
} 
