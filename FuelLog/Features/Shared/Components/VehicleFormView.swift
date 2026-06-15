//
//  VehicleFormView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 14/06/26.
//

import SwiftUI

struct VehicleFormView: View {
	@Binding var name: String
	@Binding var brand: String
	@Binding var model: String
	@Binding var year: String
	@Binding var capacity: String
	@Binding var type: VehicleType
	
	var body: some View {
		VStack(spacing: 18) {
			// TODO: Input
			
			// TODO: PICKER
		}
	}
}

#Preview {
	VehicleFormView(
		name: .constant(""),
		brand: .constant(""),
		model: .constant(""),
		year: .constant(""),
		capacity: .constant(""),
		type: .constant(.car)
	)
	.padding()
}
