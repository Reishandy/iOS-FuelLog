//
//  RefuelEditSheetView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI
import SwiftData

struct RefuelEditSheetView: View {
	let refuel: Refuel
	let onDismissClick: () -> Void
	let fuelTypes: [String]
	
	@State private var odometer: Double
	@State private var amount: Double
	@State private var pricePerLiter: Double
	@State private var fuelType: String
	@State private var timestamp: Date
	
	@State private var isDismissConfirmationShown: Bool = false
	
	init(
		refuel: Refuel,
		fuelTypes: [String],
		onDismissClick: @escaping () -> Void
	) {
		self.refuel = refuel
		self.onDismissClick = onDismissClick
		self.fuelTypes = fuelTypes
		
		self.odometer = refuel.odometer
		self.amount = refuel.amount
		self.pricePerLiter = refuel.pricePerLiter
		self.fuelType = refuel.fuelType ?? ""
		self.timestamp = refuel.timestamp
	}
	
	var isFormDirty: Bool {
		self.refuel.odometer != self.odometer ||
		self.refuel.amount != self.amount ||
		self.refuel.pricePerLiter != self.pricePerLiter ||
		(self.refuel.fuelType ?? "") != self.fuelType ||
		self.refuel.timestamp != self.timestamp
	}
	
	var body: some View {
		NavigationStack {
			RefuelFormView(
				odometer: $odometer,
				amount: $amount,
				pricePerLiter: $pricePerLiter,
				fuelType: $fuelType,
				timestamp: $timestamp,
				fuelTypes: fuelTypes,
				onFieldUnfocus: { field in
					switch field {
					case .odometer:
						if odometer == 0.0 {
							odometer = refuel.odometer
						}
					case .pricePerLiter:
						if pricePerLiter == 0.0 {
							pricePerLiter = refuel.pricePerLiter
						}
					}
				}
			)
			.navigationTitle("Edit Refuel")
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
						refuel.odometer = odometer
						refuel.amount = amount
						refuel.pricePerLiter = pricePerLiter
						refuel.fuelType = fuelType.isEmpty ? nil : fuelType
						refuel.timestamp = timestamp
						
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
	
	let descriptor = FetchDescriptor<Refuel>()
	let refuels = try? context.fetch(descriptor)
	
	if let refuel = refuels?.first {
		RefuelEditSheetView(refuel: refuel, fuelTypes: ["Pertamax", "Pertalite"]) {}
	} else {
		RefuelEditSheetView(
			refuel: Refuel(odometer: 15000, amount: 25.5, pricePerLiter: 10000),
			fuelTypes: ["Pertamax", "Pertalite"]
		) {}
	}
}
