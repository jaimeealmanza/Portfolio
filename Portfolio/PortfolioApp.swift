// 
// PortfolioApp.swift of Portfolio.
// Created by JaimeAlmanza on 27/10/20.
//
// 


import SwiftUI

@main
struct PortfolioApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
