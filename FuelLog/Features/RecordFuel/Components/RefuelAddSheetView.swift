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
	
	let maxAmount: Double
	let fuelTypes: [String]
	let onDismissClick: () -> Void
	let onSaveClick: () -> Void
	
	@State private var isFormValid: Bool = false
	
	var body: some View {
		NavigationStack {
			RefuelFormView(
				odometer: $odometer,
				amount: $amount,
				pricePerUnit: $pricePerUnit,
				fuelType: $fuelType,
				timestamp: $timestamp,
				isFormValid: $isFormValid,
				maxAmount: maxAmount,
				fuelTypes: fuelTypes
			)
			.navigationTitle("Record Refuel")
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
					.disabled(!isFormValid)
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
		maxAmount: 10.0,
		fuelTypes: [],
		onDismissClick: {},
		onSaveClick: {}
	)
}
