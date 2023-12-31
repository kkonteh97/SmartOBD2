//
//  SmartOBD2App.swift
//  SmartOBD2
//
//  Created by kemo konteh on 8/3/23.
//

import SwiftUI
import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like a view that appeared.
    static let elmCom = Logger(subsystem: subsystem, category: "ELM327")

    /// All logs related to tracking and analytics.
    static let bleCom = Logger(subsystem: subsystem, category: "BLEComms")
}

class GlobalSettings: ObservableObject {
    @Published var displayType: BottomSheetType = .quarterScreen
    @Published var statusMessage = ""
    @Published var showAltText = false
    @Published var userDevice: OBDDevice = .carlyOBD
}

@main
struct SmartOBD2App: App {
    var globalSettings = GlobalSettings()

    var body: some Scene {
        WindowGroup {
            MainView(garage: Garage())
                .environmentObject(globalSettings)
        }
    }
}
