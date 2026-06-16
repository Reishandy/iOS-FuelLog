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
	var tankCapacityLiter: Double
	var vehicleType: VehicleType
	
	@Relationship(deleteRule: .cascade, inverse: \Refuel.vehicle)
	var refuels: [Refuel] = []
	
	init(name: String, brand: String, model: String, year: Int, tankCapacityLiter: Double, vehicleType: VehicleType, refuels: [Refuel] = []) {
		self.id = UUID()
		self.timestamp = .now
		self.name = name
		self.brand = brand
		self.model = model
		self.year = year
		self.tankCapacityLiter = tankCapacityLiter
		self.vehicleType = vehicleType
		self.refuels = refuels
	}
	
	var brandModelYear: String {
		"\(self.brand) \(self.model) \(String(self.year))"
	}
	
	private var sortedRefuels: [Refuel] {
		refuels.sorted { $0.odometer < $1.odometer }
	}
	
	var mostRecentOdometer: String {
		// TODO: Imperial
		let odometer = sortedRefuels.last?.odometer ?? 0.0
		return "\(String(odometer.formatted(.number.precision(.fractionLength(1))))) Km"
	}
	
	var totalDistanceTracked: String {
		guard let firstOdo = sortedRefuels.first?.odometer,
			  let lastOdo = sortedRefuels.last?.odometer else { return "0 Km" }
		
		let distance = lastOdo - firstOdo
		return "\(distance.formatted(.number.precision(.fractionLength(1)))) Km"
	}
	
	var totalFuelCost: String {
		let cost = refuels.reduce(0) { $0 + $1.totalPrice }
		return cost.formatted(.currency(code: "IDR"))
	}
	
	var averageKmL: String {
		guard sortedRefuels.count > 1 else { return "0.0 Km/L" }
		
		guard let firstOdo = sortedRefuels.first?.odometer,
			  let lastOdo = sortedRefuels.last?.odometer else { return "0.0 Km/L" }
		
		let distance = lastOdo - firstOdo
		let consumedFuel = sortedRefuels.dropFirst().reduce(0) { $0 + $1.amount }
		
		guard consumedFuel > 0, distance > 0 else { return "0.0 Km/L" }
		
		let efficiency = distance / consumedFuel
		return "\(efficiency.formatted(.number.precision(.fractionLength(1)))) Km/L"
	}
	
	var estimatedMaxRange: String {
		guard sortedRefuels.count > 1 else { return "0 Km" }
		
		guard let firstOdo = sortedRefuels.first?.odometer,
			  let lastOdo = sortedRefuels.last?.odometer else { return "0 Km" }
		
		let distance = lastOdo - firstOdo
		let consumedFuel = sortedRefuels.dropFirst().reduce(0) { $0 + $1.amount }
		
		guard consumedFuel > 0, distance > 0 else { return "0 Km" }
		
		let efficiency = distance / consumedFuel
		let range = efficiency * tankCapacityLiter
		
		return "\(range.formatted(.number.precision(.fractionLength(0)))) Km"
	}
	
	var costPerKm: String {
		guard let firstOdo = sortedRefuels.first?.odometer,
			  let lastOdo = sortedRefuels.last?.odometer else { return "Rp 0 / Km" }
		
		let distance = lastOdo - firstOdo
		guard distance > 0 else { return "Rp 0 / Km" }
		
		let cost = refuels.reduce(0) { $0 + $1.totalPrice }
		let cpkm = cost / distance
		
		return "\(cpkm.formatted(.currency(code: "IDR"))) / Km"
	}
}
