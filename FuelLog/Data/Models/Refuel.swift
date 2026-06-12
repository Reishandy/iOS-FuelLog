//
//  Refuel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import Foundation
import SwiftData

@Model
class Refuel {
	var id: UUID
	var timestamp: Date
	
	var odometer: Double
	var amounfLiters: Double
	var pricePerLiter: Double
	var fuelType: String?
	
	var vehicle: Vehicle?
	
	init(odometer: Double, amounfLiters: Double, pricePerLiter: Double, fuelType: String? = nil, vehicle: Vehicle? = nil) {
		self.id = UUID()
		self.timestamp = .now
		self.odometer = odometer
		self.amounfLiters = amounfLiters
		self.pricePerLiter = pricePerLiter
		self.fuelType = fuelType
		self.vehicle = vehicle
	}
}
