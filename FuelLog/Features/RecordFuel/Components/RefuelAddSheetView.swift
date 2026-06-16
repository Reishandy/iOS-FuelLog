//
//  RefuelAddSheetView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI

struct RefuelAddSheetView: View {
	@Binding var odometer: Double
	@Binding var amount: Double
	@Binding var pricePerUnit: Double
	@Binding var fuelType: String
	@Binding var timestamp: Date
	
	let fuelTypes: [String]
	
	let onDismissClick: () -> Void
	let onSaveClick: () -> Void
	
	private var isFormFilled: Bool {
		odometer != 0.0 && pricePerUnit != 0.0
	}
	
	var body: some View {
		NavigationStack {
			RefuelFormView(
				odometer: $odometer,
				amount: $amount,
				pricePerUnit: $pricePerUnit,
				fuelType: $fuelType,
				timestamp: $timestamp,
				fuelTypes: fuelTypes
			)
			.navigationTitle("Add New Vehicle")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Dismiss", systemImage: "xmark") {
						onDismissClick()
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Button("Save", systemImage: "checkmark") {
						onSaveClick()
					}
					.disabled(!isFormFilled)
				}
			}
		}
		.presentationDetents([.large])
	}
}

#Preview {
	RefuelAddSheetView(
		odometer: .constant(0.0),
		amount: .constant(0.0),
		pricePerUnit: .constant(0.0),
		fuelType: .constant(""),
		timestamp: .constant(.now),
		fuelTypes: [],
		onDismissClick: {},
		onSaveClick: {}
	)
}
