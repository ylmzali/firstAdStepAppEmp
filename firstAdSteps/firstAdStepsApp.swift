//
//  firstAdStepsApp.swift
//  firstAdSteps
//
//  Created by Ali YILMAZ on 17.05.2025.
//
import SwiftUI

@main
struct firstAdStepsApp: App {
    @StateObject var routeViewModel = RouteViewModel()
    @StateObject var userViewModel = UserProfileViewViewModel()

    var body: some Scene {
        WindowGroup {
            AppFlowView()
                .environmentObject(routeViewModel)
                .environmentObject(userViewModel)

        }
    }
}
