//
//  HomeView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
	@Namespace private var homeScreenNameSpace
	
	@Environment(\.modelContext) private var modelContext
	@Environment(NavigationRouter.self) private var router
	
	@State var homeViewModel: HomeViewModel
	@State var isAddSheetPresented: Bool = false
	@State var isSettingsPresented: Bool = false
	
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
					isSettingsPresented.toggle()
				}
				.popover(isPresented: $isSettingsPresented) {
					Text("TODO")
						.frame(width: 400, height: 400)
						.presentationCompactAdaptation(.popover)
				}
			}
			
			ToolbarItem(placement: .bottomBar) {
				Menu {
					Menu("Sort By") {
						Picker("Sort By", selection: $homeViewModel.vehicleSortBy) {
							ForEach(VehicleSortBy.allCases, id: \.self) { option in
								Text(option.rawValue).tag(option)
							}
						}
					}
					
					Menu("Group By") {
						Picker("Group By", selection: $homeViewModel.vehicleGroupBy) {
							ForEach(VehicleGroupBy.allCases, id: \.self) { option in
								Text(option.rawValue).tag(option)
							}
						}
					}
				} label: {
					Label("Filter Vehicles", systemImage: "line.3.horizontal.decrease")
				}
			}
			
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button("Add Vehicle", systemImage: "plus") {
					isAddSheetPresented.toggle()
				}
				.matchedTransitionSource(id: "addSheetSource", in: homeScreenNameSpace)
			}
		}
		.sheet(isPresented: $isAddSheetPresented) {
			Text("TODO")
				.presentationDetents([.medium])
				.navigationTransition(.zoom(sourceID: "addSheetSource", in: homeScreenNameSpace))
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
