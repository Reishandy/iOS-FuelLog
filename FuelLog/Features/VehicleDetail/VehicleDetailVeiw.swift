//
//  VehicleDetailVeiw.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI
import SwiftData

struct VehicleDetailVeiw: View {
	@Environment(\.editMode) private var editMode
	
	@State var vehicleDetailViewModel: VehicleDetailViewModel
	
	@State private var isRefuelDetailPresented: Bool = false
	@State private var isDeleteConfirmmationPresented: Bool = false
	
	private var isEdit: Bool {
		editMode?.wrappedValue == .active
	}
	
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
									Image(systemName: "trash")
									Text("Delete")
								}
								.tint(.red)
								
								
								Button {
									vehicleDetailViewModel.selectedRefuel = refuel
									isRefuelDetailPresented = true
								} label: {
									Image(systemName: "info")
									Text("Detail")
								}
								.tint(.blue)
							}
					}
				}
			}
			.safeAreaPadding(.top, 190)
			
			// TODO: Vehicle detail
			// TODO: Vehicle edit
			Text(vehicleDetailViewModel.vehicle?.name ?? "TODO")
				.frame(maxWidth: .infinity)
				.frame(height: 150)
				.glassEffect(in: RoundedRectangle(cornerRadius: 25))
				.padding(.top, 20)
				.padding(.horizontal, 20)
		}
		.frame(maxHeight: .infinity, alignment: .top)
		.navigationTitle("Refuel")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				EditButton()
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button("Record Refuel", systemImage: "plus") {
					// TODO: Move with zoom transition?
				}
			}
		}
		.sheet(isPresented: $isRefuelDetailPresented) {
			// TODO: Refuel form, dismiss set selected to nil
			Text("TODO")
				.presentationDetents([.large])
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
	
	return NavigationStack {
		VehicleDetailVeiw(
			vehicleDetailViewModel: VehicleDetailViewModel(
				modelContext: context,
				vehicleId: firstVehicleId
			)
		)
	}
}
