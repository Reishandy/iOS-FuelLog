//
//  ContentView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@State private var router = NavigationRouter()
	@Environment(\.modelContext) private var modelContext
	
	// TODO: Main todo list
	//	- animation
	//	- currency
	//	- haptic and sound
	//	- bunch of filters, group by, sort by, etc
	//	- input with existing options from already inputted form
	//	- Settings and preferences store
	//	- Metrics or Imperial
	
	var body: some View {
		NavigationStack(path: $router.path) {
			HomeView(homeViewModel: HomeViewModel(modelContext: modelContext))
				.environment(router)
				.navigationDestination(for: AppRoute.self) { route in
					switch route {
					case .home:
						HomeView(homeViewModel: HomeViewModel(modelContext: modelContext))
					}
				}
		}
	}
}

#Preview {
	ContentView()
}
