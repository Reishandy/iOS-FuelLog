//
//  VehicleFormSheetView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI

struct VehicleFormSheetView: View {
	@Binding var name: String
	@Binding var brand: String
	@Binding var model: String
	@Binding var year: Int
	@Binding var capacity: Double
	@Binding var type: VehicleType
	
	let onDismissClick: () -> Void
	let onSaveClick: () -> Void
	
	@State private var isDismissConfirmationShown: Bool = false
	
	private var isFormFilled: Bool {
		!name.isEmpty && !brand.isEmpty && !model.isEmpty
	}
	
	private var isFormDirty: Bool {
		!name.isEmpty || !brand.isEmpty || !model.isEmpty
	}
	
	var body: some View {
		NavigationStack {
			VehicleFormView(
				name: $name,
				brand: $brand,
				model: $model,
				year: $year,
				capacity: $capacity,
				type: $type
			)
			.navigationTitle("Add New Vehicle")
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
						Text("Are you sure you want to discard this new vehicle?")
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
		.interactiveDismissDisabled()
		.presentationDetents([.large])
	}
}

#Preview {
	VehicleFormSheetView(
		name: .constant(""),
		brand: .constant(""),
		model: .constant(""),
		year: .constant(Calendar.current.component(.year, from: Date())),
		capacity: .constant(0.0),
		type: .constant(.car),
		onDismissClick: {},
		onSaveClick: {}
	)
}
