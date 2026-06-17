//
//  VehicleDetailVeiw.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI
import SwiftData

struct VehicleDetailVeiw: View {
	@State var vehicleDetailViewModel: VehicleDetailViewModel
	
	@State private var isDetailSheetPresented: Bool = false
	@State private var isDeleteConfirmmationPresented: Bool = false
	
    var body: some View {
		ZStack(alignment: .top) {
			Group {
				if vehicleDetailViewModel.filteredRefuels.isEmpty {
					VStack(spacing: 8) {
						Text("No refuel here")
							.font(.title2)
							.bold()
						
						Text("Record some first")
							.opacity(0.7)
					}
					.frame(maxHeight: .infinity, alignment: .center)
				} else {
					CustomListView(
						groupedItem: vehicleDetailViewModel.filteredRefuels,
						orderedHeader: vehicleDetailViewModel.sortedSectionKeys
					) { refuel in
						RefuelListItemView(refuel: refuel)
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								Button {
									vehicleDetailViewModel.refuelToDelete = refuel
									isDeleteConfirmmationPresented = true
								} label: {
									Label("Delete", systemImage: "trash")
								}
								.tint(.red)
								
								Button {
									vehicleDetailViewModel.selectedRefuel = refuel
									isDetailSheetPresented = true
								} label: {
									Label("Edit", systemImage: "square.and.pencil")
								}
							}
							.contextMenu {
								Button {
									vehicleDetailViewModel.selectedRefuel = refuel
									isDetailSheetPresented = true
								} label: {
									Label("Edit", systemImage: "square.and.pencil")
								}
								
								Button("Delete", systemImage: "trash", role: .destructive) {
									vehicleDetailViewModel.refuelToDelete = refuel
									isDeleteConfirmmationPresented = true
								}
							}
					}
				}
			}
			.safeAreaPadding(.top, 190)
			
			if let vehicle = vehicleDetailViewModel.vehicle {
				VehicleDetailCardView(vehicle: vehicle)
					.padding(20)
			}
		}
		.frame(maxHeight: .infinity, alignment: .top)
		.toolbar {
			if let vehicle = vehicleDetailViewModel.vehicle {
				ToolbarSpacer(placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
					NavigationLink(value: AppRoute.recordFuel(vehicle.id)) {
						Image(systemName: "plus")
							.foregroundStyle(.white)
					}
					.buttonStyle(.glassProminent)
					.tint(.orange)
				}
			}
		}
		.sheet(isPresented: $isDetailSheetPresented) {
			if let selectedRefuel = vehicleDetailViewModel.selectedRefuel {
				RefuelEditSheetView(
					refuel: selectedRefuel,
					fuelTypes: vehicleDetailViewModel.fuelTypes
				) {
					isDetailSheetPresented = false
					vehicleDetailViewModel.selectedRefuel = nil
				}
			}
		}
		.alert(
			"Delete Refuel?",
			isPresented: $isDeleteConfirmmationPresented,
			presenting: vehicleDetailViewModel.refuelToDelete
		) { refuel in
			Button("Delete", role: .destructive) {
				vehicleDetailViewModel.deleteRefuel()
			}
			Button("Cancel", role: .cancel) {
				vehicleDetailViewModel.refuelToDelete = nil
			}
		} message: { refuel in
			Text("This will premanently delete \(refuel.formattedTimestamp) refuel entry.")
		}
		.task {
			vehicleDetailViewModel.fetchData()
		}
		.animation(.default, value: vehicleDetailViewModel.filteredRefuels)
    }
}

#Preview {
	let context = PreviewContainer.shared.mainContext
	
	let descriptor = FetchDescriptor<Vehicle>()
	let vehicles = try? context.fetch(descriptor)
	
	let firstVehicleId = vehicles?.first?.id ?? UUID()
	
	NavigationStack {
		VehicleDetailVeiw(
			vehicleDetailViewModel: VehicleDetailViewModel(
				modelContext: context,
				vehicleId: firstVehicleId
			)
		)
	}
}
