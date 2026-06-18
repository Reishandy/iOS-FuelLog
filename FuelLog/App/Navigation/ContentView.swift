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
					RecordFuelView(recordFuelViewModel: RecordFuelViewModel(
						modelContext: modelContext,
						vehicleId: vehicleId
					))
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
