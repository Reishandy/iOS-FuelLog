//
//  VehicleListItemView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI

struct VehicleListItemView: View {
	let vehicle: Vehicle
	var isDefault: Bool = false
	
	var icon: String {
		switch vehicle.vehivleType {
		case .car:
			return "car.side"
		case .motorcycle:
			return "motorcycle"
		}
	}
	
	var subTitle: String {
		"\(vehicle.brand) \(vehicle.model) \(String(vehicle.year))"
	}
	
	var body: some View {
		HStack(alignment: .center) {
			Image(systemName: icon)
				.foregroundStyle(isDefault ? .blue : .primary)
			
			VStack(alignment: .leading) {
				Text(vehicle.name)
					.lineLimit(1)
				
				Text(subTitle)
					.lineLimit(1)
					.font(.caption)
					.opacity(0.7)
			}
			
			Spacer()
			
			Text(String(vehicle.refuels.count))
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
	let mockRefuels = (0..<10).map { _ in Refuel(odometer: 1000, amount: 10, pricePerLiter: 10000) }
	
	let car = Vehicle(name: "Main Car", brand: "Toyota", model: "Avanza", year: 2007, tankCapacityLiter: 45.0, vehivleType: .car, refuels: mockRefuels)
	
	let moto = Vehicle(name: "Old Motorcycle", brand: "Honda", model: "Cub", year: 1998, tankCapacityLiter: 4.0, vehivleType: .motorcycle, refuels: mockRefuels)
	
	let longMoto = Vehicle(name: "Very long name that shouldn't exist man but some people", brand: "Might still input those long number that is totatally not cool", model: "at all", year: 2024, tankCapacityLiter: 10.0, vehivleType: .motorcycle)
	
	return VStack {
		VehicleListItemView(vehicle: car)
		VehicleListItemView(vehicle: moto)
		VehicleListItemView(vehicle: longMoto, isDefault: true)
	}
	.padding()
}
