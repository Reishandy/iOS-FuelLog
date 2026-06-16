//
//  ContentView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(PreferencesService.self) private var preferences
	
	// TODO: Main todo list
	//	- animation
	//	- currency
	//	- haptic and sound
	//	- bunch of filters, group by, sort by, etc
	//	- input with existing options from already inputted form
	//	- Settings and preferences store
	//	- Metrics or Imperial setting (if already have data offer to convert)
	//	- Are you sure you want to discard in a filled fuel from
	// TODO: Fix list
	//	- Not navigating on the spacer place only on content for the list
	
	var body: some View {
		AppNavigationView(initialVehicleId: preferences.defaultVehicle)
	}
}

private struct AppNavigationView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(PreferencesService.self) private var preferences
	
	@State private var router: NavigationRouter
	
	init(initialVehicleId: UUID?) {
		let initialPath = initialVehicleId
			.map { NavigationPath([AppRoute.vehicleDetail($0)]) }
		?? NavigationPath()
		_router = State(wrappedValue: NavigationRouter(path: initialPath))
	}
	
	var body: some View {
		NavigationStack(path: $router.path) {
			HomeView(homeViewModel: HomeViewModel(
				modelContext: modelContext,
				preferences: preferences
			))
			.environment(router)
			.navigationDestination(for: AppRoute.self) { route in
				switch route {
				case .home:
					HomeView(homeViewModel: HomeViewModel(
						modelContext: modelContext,
						preferences: preferences
					))
				case .vehicleDetail(let vehicleId):
					VehicleDetailVeiw(vehicleDetailViewModel: VehicleDetailViewModel(
						modelContext: modelContext,
						vehicleId: vehicleId
					))
				case .recordFuel(let vehicleId):
					// TODO: ViewModel
					RecordFuelView()
				}
			}
		}
	}
}

#Preview {
	ContentView()
		.modelContext(PreviewContainer.shared.mainContext)
		.environment(PreferencesService())
}
