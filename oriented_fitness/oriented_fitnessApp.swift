//
//  oriented_fitnessApp.swift
//  oriented_fitness
//
//  Created by Shawnick Wang on 2/16/25.
//

import SwiftUI

@main
struct oriented_fitnessApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
