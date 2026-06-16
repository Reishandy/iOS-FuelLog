//
//  VehicleEditSheetView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI
import SwiftData

struct VehicleEditSheetView: View {
	let vehicle: Vehicle
	let onDismissClick: () -> Void
	
	@State private var name: String
	@State private var brand: String
	@State private var model: String
	@State private var year: Int
	@State private var capacity: Double
	@State private var type: VehicleType
	
	@State private var isDismissConfirmationShown: Bool = false
	
	init(
		vehicle: Vehicle,
		onDismissClick: @escaping () -> Void
	) {
		self.vehicle = vehicle
		self.onDismissClick = onDismissClick
		
		self.name = vehicle.name
		self.brand = vehicle.brand
		self.model = vehicle.model
		self.year = vehicle.year
		self.capacity = vehicle.tankCapacityLiter
		self.type = vehicle.vehicleType
	}
	
	var isFormDirty: Bool {
		self.vehicle.name != self.name ||
		self.vehicle.brand != self.brand ||
		self.vehicle.model != self.model ||
		self.vehicle.year != self.year ||
		self.vehicle.tankCapacityLiter != self.capacity ||
		self.vehicle.vehicleType != self.type
	}
	
	var body: some View {
		NavigationStack {
			VehicleFormView(
				name: $name,
				brand: $brand,
				model: $model,
				year: $year,
				capacity: $capacity,
				type: $type,
				onFieldUnfocus: { field in
					switch field {
					case .name:
						if name.trimmingCharacters(in: .whitespaces).isEmpty {
							name = vehicle.name
						}
					case .brand:
						if brand.trimmingCharacters(in: .whitespaces).isEmpty {
							brand = vehicle.brand
						}
					case .model:
						if model.trimmingCharacters(in: .whitespaces).isEmpty {
							model = vehicle.model
						}
					}
				}
			)
			.navigationTitle("Edit Vehicle")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Dismiss", systemImage: "xmark") {
						if isFormDirty {
							isDismissConfirmationShown = true
						} else {
							onDismissClick()
						}
					}
					.confirmationDialog(
						"Discard Change",
						isPresented: $isDismissConfirmationShown
					) {
						Button("Discard Change", role: .destructive) {
							onDismissClick()
						}
						.buttonStyle(.bordered)
					} message: {
						Text("Are you sure you want to discard this edit?")
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Button("Save", systemImage: "checkmark") {
						vehicle.name = name
						vehicle.brand = brand
						vehicle.model = model
						vehicle.year = year
						vehicle.tankCapacityLiter = capacity
						vehicle.vehicleType = type
						
						onDismissClick()
					}
				}
			}
		}
		.interactiveDismissDisabled()
		.presentationDetents([.large])
	}
}

#Preview {
	let context = PreviewContainer.shared.mainContext
	
	let descriptor = FetchDescriptor<Vehicle>()
	let vehicles = try? context.fetch(descriptor)
	
	if let vehicle = vehicles?.first {
		VehicleEditSheetView(vehicle: vehicle) {}
	}
}
