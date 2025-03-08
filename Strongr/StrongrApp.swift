//
//  StrongrApp.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

@main
struct StrongrApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var dataManager: DataManager
    @StateObject private var unitManager = UnitManager()
    
    init() {
        // Make sure CoreDataExtensions is loaded at app startup
        _ = CoreDataExtensions.self
        
        let manager = DataManager(context: persistenceController.container.viewContext)
        _dataManager = StateObject(wrappedValue: manager)
        
        // Seed default exercises on first launch
        manager.seedDefaultData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataManager)
                .environmentObject(unitManager)
        }
    }
}

// Dummy struct to ensure CoreDataExtensions is loaded
private struct CoreDataExtensions {}
