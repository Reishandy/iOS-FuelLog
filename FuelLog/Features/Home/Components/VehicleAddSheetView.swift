//
//  VehicleAddSheetView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 14/06/26.
//

import SwiftUI

struct VehicleAddSheetView: View {
	@Binding var name: String
	@Binding var brand: String
	@Binding var model: String
	@Binding var year: String
	@Binding var capacity: String
	@Binding var type: VehicleType
	
	var body: some View {
		VStack(spacing: 18) {
			CustomTextFieldView(
				label: "Name",
				placeholder: "E.g. My Family Car",
				value: $name
			)
			
			CustomTextFieldView(
				label: "Brand",
				placeholder: "E.g. Honda",
				value: $brand
			)
			
			CustomTextFieldView(
				label: "Model",
				placeholder: "E.g. Avanza",
				value: $model
			)
			
			CustomTextFieldView(
				label: "Year",
				placeholder: "E.g. 2021",
				value: $year
			)
			.keyboardType(.numberPad)
			
			CustomTextFieldView(
				label: "Capacity",
				placeholder: "E.g. 45.5",
				value: $capacity
			)
			.keyboardType(.decimalPad)
			
			// TODO: PICKER
		}
	}
}

#Preview {
	VehicleAddSheetView(
		name: .constant(""),
		brand: .constant(""),
		model: .constant(""),
		year: .constant(""),
		capacity: .constant(""),
		type: .constant(.car)
	)
	.padding()
}
