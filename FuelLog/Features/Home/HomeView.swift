//
//  HomeView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(NavigationRouter.self) private var router
	
	@State var homeViewModel: HomeViewModel
	
	var body: some View {
		Group {
			if homeViewModel.filteredVehicles.isEmpty {
				VStack(spacing: 8) {
					Text("No vehicle here")
						.font(.title2)
						.bold()
					
					Text("Add some first")
						.opacity(0.7)
				}
			} else {
				CustomListView(groupedItem: homeViewModel.filteredVehicles) { vehicle in
					Button {
						router.navigate(to: .vehicleDetail(vehicle: vehicle))
					} label: {
						VehicleListItemView(vehicle: vehicle, isDefault: false) // TODO: isDefault
					}
					.buttonStyle(.plain)
				}
			}
		}
		.searchable(
			text: $homeViewModel.vehicleSearchTerm,
			placement: .toolbar,
			prompt: "Search Vehicle..."
		)
		.navigationTitle("Vehicles")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Settings", systemImage: "gearshape") {
					// TODO: App setting
				}
			}
			
			ToolbarItem(placement: .bottomBar) {
				Button("Filter Vehicles", systemImage: "line.3.horizontal.decrease") {
					// TODO: Vehicle filter, group by, sort by
				}
			}
			
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button("Add Vehicle", systemImage: "plus") {
					// TODO: Add Vehicle
				}
			}
		}
		.task {
			homeViewModel.fetchData()
		}
		.animation(.easeInOut, value: homeViewModel.filteredVehicles)
	}
}

#Preview {
	NavigationStack	{
		HomeView(homeViewModel: HomeViewModel(modelContext: PreviewContainer.shared.mainContext))
	}
}
