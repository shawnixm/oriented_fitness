//
//  ContentView.swift
//  oriented_fitness
//
//  Created by Shawnick Wang on 2/16/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            StatisticsView()
                .tabItem { Text("Statistics") }.tag(1)
            
            ExercisesView()
                .tabItem { Text("Exercises") }.tag(2)
            
            CaloriesView()
                .tabItem { Text("Calories") }.tag(3)
            
            }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

