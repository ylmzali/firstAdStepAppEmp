//
//  firstAdStepsApp.swift
//  firstAdSteps
//
//  Created by Ali YILMAZ on 17.05.2025.
//
import SwiftUI

@main
struct firstAdStepsApp: App {
    @StateObject private var routeViewModel = RouteViewModel()
    
    var body: some Scene {
        WindowGroup {
            RouteListView()
                .environmentObject(routeViewModel)
        }
    }
}
