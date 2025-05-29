import SwiftUI

struct RouteListView: View {
    @EnvironmentObject private var viewModel: RouteViewModel
    @State private var showingAddRoute = false
    
    var body: some View {
        List {
            ForEach(viewModel.filteredRoutes) { route in
                NavigationLink(destination: RouteDetailView(route: route)) {
                    RouteListItem(route: route)
                }
            }
            .onDelete { indexSet in
                viewModel.deleteRoutes(at: indexSet)
            }
        }
        .listStyle(.plain)
        // .navigationTitle("Rotalar")
        .toolbar {
            Button {
                showingAddRoute = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddRoute) {
            NavigationStack {
                AddRouteView()
            }
        }
    }
}

struct RouteListItem: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: AntSpacing.xs) {
            Text(route.name)
                .font(.system(size: AntTypography.paragraph))
                .foregroundColor(AntColors.text)
            
            Text(route.description)
                .font(.system(size: AntTypography.caption))
                .foregroundColor(AntColors.secondaryText)
                .lineLimit(2)
            
            HStack(spacing: AntSpacing.sm) {
                Label("\(Int(route.duration)) dk", systemImage: "clock")
                Label(route.category.rawValue, systemImage: "figure.walk")
                Label(route.areaType.rawValue, systemImage: "map")
            }
            .font(.system(size: AntTypography.caption))
            .foregroundColor(AntColors.secondaryText)
        }
        .padding(.vertical, AntSpacing.xs)
    }
}

#Preview {
    NavigationStack {
        RouteListView()
            .environmentObject(RouteViewModel())
    }
} 
