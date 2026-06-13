//
//  Refuel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import Foundation
import SwiftData

@Model
class Refuel: Identifiable, Equatable {
	var id: UUID
	var timestamp: Date
	
	var odometer: Double
	var amount: Double
	var pricePerLiter: Double
	var fuelType: String?
	
	var vehicle: Vehicle?
	
	init(odometer: Double, amount: Double, pricePerLiter: Double, fuelType: String? = nil, vehicle: Vehicle? = nil) {
		self.id = UUID()
		self.timestamp = .now
		self.odometer = odometer
		self.amount = amount
		self.pricePerLiter = pricePerLiter
		self.fuelType = fuelType
		self.vehicle = vehicle
	}
}
