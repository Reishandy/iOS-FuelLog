//
//  Vehicle.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import Foundation
import SwiftData

@Model
class Vehicle: Identifiable, Equatable {
	var id: UUID
	var timestamp: Date
	
	var name: String
	var brand: String
	var model: String
	var year: Int
	var tankCapacity: Double
	var vehicleType: VehicleType
	
	@Relationship(deleteRule: .cascade, inverse: \Refuel.vehicle)
	var refuels: [Refuel] = []
	
	init(name: String, brand: String, model: String, year: Int, tankCapacity: Double, vehicleType: VehicleType, refuels: [Refuel] = []) {
		self.id = UUID()
		self.timestamp = .now
		self.name = name
		self.brand = brand
		self.model = model
		self.year = year
		self.tankCapacity = tankCapacity
		self.vehicleType = vehicleType
		self.refuels = refuels
	}
	
	var brandModelYear: String {
		"\(self.brand) \(self.model) \(String(self.year))"
	}
	
	private var sortedRefuels: [Refuel] {
		refuels.sorted { $0.odometer < $1.odometer }
	}
	
	var mostRecentOdometer: Double {
		sortedRefuels.last?.odometer ?? 0.0
	}
	
	var totalDistanceTracked: Double {
		guard let firstOdo = sortedRefuels.first?.odometer,
			  let lastOdo = sortedRefuels.last?.odometer else { return 0.0 }
		
		return lastOdo - firstOdo
	}
	
	var totalFuelCost: Double {
		refuels.reduce(0) { $0 + $1.totalPrice }
	}
	
	var averageEfficiency: Double {
		let distance = totalDistanceTracked
		let consumedFuel = sortedRefuels.dropFirst().reduce(0) { $0 + $1.amount }
		
		guard consumedFuel > 0, distance > 0 else { return 0.0 }
		return distance / consumedFuel
	}
	
	var estimatedMaxRange: Double {
		let efficiency = averageEfficiency
		return efficiency * tankCapacity
	}
	
	var costPerDistance: Double {
		let distance = totalDistanceTracked
		guard distance > 0 else { return 0.0 }
		return totalFuelCost / distance
	}
}
