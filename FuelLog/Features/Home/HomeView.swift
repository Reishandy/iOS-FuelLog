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
	@Environment(NavigationRouter.self) private var router
	
	@State var homeViewModel: HomeViewModel
	
	@State private var isAddSheetPresented: Bool = false
	@State private var isEditSheetPresented: Bool = false
	@State private var isSettingsPresented: Bool = false
	@State private var isDeleteConfirmmationPresented: Bool = false
	
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
					NavigationLink (
						value: AppRoute.vehicleDetail(vehicle.id)
					) {
						VehicleListItemView(vehicle: vehicle, isDefault: vehicle.id == homeViewModel.defaultVehicle)
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: false) {
						Button {
							homeViewModel.vehicleToDelete = vehicle
							isDeleteConfirmmationPresented = true
						} label: {
							Image(systemName: "trash")
							Text("Delete")
						}
						.tint(.red)
						
						Button {
							homeViewModel.selectedVehicle = vehicle
							isEditSheetPresented = true
						} label: {
							Image(systemName: "square.and.pencil")
							Text("Edit")
						}
						
						Button {
							homeViewModel.defaultVehicle = vehicle.id
						} label: {
							Image(systemName: "checkmark.circle.fill")
							Text("Default")
						}
						.tint(vehicle.id == homeViewModel.defaultVehicle ? .blue : .secondary)
					}
					.contextMenu {
						Button {
							homeViewModel.defaultVehicle = vehicle.id
						} label: {
							Label("Default", systemImage: "checkmark.circle.fill")
						}
						.tint(vehicle.id == homeViewModel.defaultVehicle ? .blue : .secondary)
						
						Button {
							homeViewModel.selectedVehicle = vehicle
							isEditSheetPresented = true
						} label: {
							Label("Edit", systemImage: "square.and.pencil")
						}
						
						Button(role: .destructive) {
							homeViewModel.vehicleToDelete = vehicle
							isDeleteConfirmmationPresented = true
						} label: {
							Label("Delete", systemImage: "trash")
						}
					}
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
			
			ToolbarItem(placement: .topBarTrailing) {
				Button("Settings", systemImage: "gearshape") {
					isSettingsPresented.toggle()
				}
				.popover(isPresented: $isSettingsPresented) {
					// TODO: Make the width infinity with padding
					Text("TODO")
						.frame(width: 300, height: 300)
						.presentationCompactAdaptation(.popover)
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
			VehicleAddSheetView(
				name: $homeViewModel.addName,
				brand: $homeViewModel.addBrand,
				model: $homeViewModel.addModel,
				year: $homeViewModel.addYear,
				capacity: $homeViewModel.addCapacity,
				type: $homeViewModel.addType,
				onDismissClick: {
					isAddSheetPresented = false
					homeViewModel.clearAddVehicle()
				},
				onSaveClick: {
					isAddSheetPresented = false
					
					let newVehicle = homeViewModel.addVehicle()
					router.navigate(to: AppRoute.vehicleDetail(newVehicle.id))
				}
			)
			.navigationTransition(.zoom(sourceID: "addSheetSource", in: homeScreenNameSpace))
		}
		.sheet(isPresented: $isEditSheetPresented) {
			if let selectedVehicle = homeViewModel.selectedVehicle {
				VehicleEditSheetView(vehicle: selectedVehicle) {
					isEditSheetPresented = false
					homeViewModel.selectedVehicle = nil
				}
			}
		}
		.alert(
			"Delete Vehicle?",
			isPresented: $isDeleteConfirmmationPresented,
			presenting: homeViewModel.vehicleToDelete
		) { vehicle in
			Button("Delete", role: .destructive) {
				homeViewModel.deleteVehicle()
			}
			Button("Cancel", role: .cancel) {
				homeViewModel.vehicleToDelete = nil
			}
		} message: { vehicle in
			Text("Deleting \(homeViewModel.vehicleToDelete?.name ?? "this vehicle") will also permanently remove its refueling history.")
		}
		.task {
			homeViewModel.fetchData()
		}
		.animation(.default, value: homeViewModel.filteredVehicles)
	}
}

#Preview {
	NavigationStack	{
		HomeView(homeViewModel: HomeViewModel(modelContext: PreviewContainer.shared.mainContext, preferences: PreferencesService()))
	}
}
