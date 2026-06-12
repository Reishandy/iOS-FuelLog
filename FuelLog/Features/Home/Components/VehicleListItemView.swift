//
//  VehicleListItemView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI

struct VehicleListItemView: View {
	let title: String
	let subTitle: String
	let amount: Int
	var icon: String
	var isDefault: Bool = false
	
    var body: some View {
		HStack(alignment: .center) {
				Image(systemName: icon)
					.foregroundStyle(isDefault ? .blue : .primary)
			
			VStack(alignment: .leading) {
				Text(title)
					.lineLimit(1)
				
				Text(subTitle)
					.lineLimit(1)
					.font(.caption)
					.opacity(0.7)
			}
			
			
			Spacer()
			
			Text(String(amount))
				.font(.callout)
				.opacity(0.7)
				.padding(.leading, 20)
			
			Image(systemName: "chevron.right")
				.font(.caption)
				.opacity(0.5)
				.padding(.leading, 6)
		}
		.padding(.vertical, 8)
    }
}

#Preview {
    VehicleListItemView(title: "Main Car", subTitle: "Toyota Avanza 2007", amount: 10, icon: "car.side")
    VehicleListItemView(title: "Old Motorcycle", subTitle: "Honda Cub 1998", amount: 10, icon: "motorcycle")
	VehicleListItemView(
		title: "Very long name that shouldn't exist man but some people",
		subTitle: "Might still input those long number that is totatally not cool at all",
		amount: 20033,
		icon: "motorcycle",
		isDefault: true
	)
}
