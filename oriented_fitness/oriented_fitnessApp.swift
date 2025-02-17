import SwiftUI

@main
struct oriented_fitnessApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {  // Use a TabView or NavigationView to manage multiple views
                ContentView()
                    .tabItem {
                        Label("Content", systemImage: "list.dash") // Example tab item
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)

                CaloriesView()
                    .tabItem {
                        Label("Calories", systemImage: "flame") // Example tab item
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                ExercisesView()
                    .tabItem {
                        Label("Exercises", systemImage: "exercises")
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
