//
//  Vehicle.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import Foundation
import SwiftData

@Model
class Vehicle {
	var id: UUID
	var timestamp: Date
	
	var name: String
	var brand: String
	var model: String
	var year: Int
	var tankCapacityLiter: Double
	var vehivleType: VehicleType
	
	@Relationship(deleteRule: .cascade, inverse: \Refuel.vehicle)
	var refuels: [Refuel] = []
	
	init(name: String, brand: String, model: String, year: Int, tankCapacityLiter: Double, vehivleType: VehicleType, refuels: [Refuel] = []) {
		self.id = UUID()
		self.timestamp = .now
		self.name = name
		self.brand = brand
		self.model = model
		self.year = year
		self.tankCapacityLiter = tankCapacityLiter
		self.vehivleType = vehivleType
		self.refuels = refuels
	}
}
