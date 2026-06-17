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
		switch vehicle.vehicleType {
		case .car:
			return "car.side\(isDefault ? ".fill" : "")"
		case .motorcycle:
			return "motorcycle\(isDefault ? ".fill" : "")"
		}
	}
	
	var body: some View {
		HStack(alignment: .center) {
			Image(systemName: icon)
				.foregroundStyle(isDefault ? .orange : .primary)
			
			VStack(alignment: .leading) {
				Text(vehicle.name)
					.lineLimit(1)
				
				Text(vehicle.brandModelYear)
					.lineLimit(1)
					.font(.subheadline)
					.opacity(0.7)
			}
			
			Spacer()
			
			Text(String(vehicle.refuels.count))
				.font(.callout)
				.opacity(0.7)
				.padding(.leading, 20)
		}
	}
}

#Preview {
	let mockRefuels = (0..<10).map { _ in Refuel(odometer: 1000, amount: 10, pricePerUnit: 10000) }
	
	let car = Vehicle(name: "Main Car", brand: "Toyota", model: "Avanza", year: 2007, tankCapacity: 45.0, vehicleType: .car, refuels: mockRefuels)
	let moto = Vehicle(name: "Old Motorcycle", brand: "Honda", model: "Cub", year: 1998, tankCapacity: 4.0, vehicleType: .motorcycle, refuels: mockRefuels)
	let longMoto = Vehicle(name: "Very long name that shouldn't exist man but some people", brand: "Might still input those long number that is totatally not cool", model: "at all", year: 2024, tankCapacity: 10.0, vehicleType: .motorcycle)
	
	List {
		VehicleListItemView(vehicle: car)
		VehicleListItemView(vehicle: moto)
		VehicleListItemView(vehicle: longMoto, isDefault: true)
	}
}
