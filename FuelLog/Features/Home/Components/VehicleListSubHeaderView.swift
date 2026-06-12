//
//  VehicleListSubHeaderView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI

struct VehicleListSubHeaderView: View {
	let title: String
	let isExpanded: Bool
	let onTap: () -> Void
	
    var body: some View {
		HStack {
			Text(title)
				.font(.title2)
				.bold()
			
			Spacer()
			
			Image(systemName: "chevron.down.circle.fill")
				.foregroundStyle(.blue)
				.rotationEffect(isExpanded ? .zero : .degrees(-90))
		}
		.padding(.top, 24)
		.onTapGesture {
			onTap()
		}
    }
}

#Preview {
	VehicleListSubHeaderView(title: "Motorcycle", isExpanded: true) {}
	VehicleListSubHeaderView(title: "Car", isExpanded: false) {}
}
