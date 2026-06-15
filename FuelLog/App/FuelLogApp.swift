//
//  FuelLogApp.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI
import SwiftData

@main
struct FuelLogApp: App {
	@State private var preferences = PreferencesService()
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.modelContainer(for: [Vehicle.self, Refuel.self])
        }
    }
}
