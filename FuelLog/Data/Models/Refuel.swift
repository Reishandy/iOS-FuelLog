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
	var pricePerUnit: Double
	var fuelType: String?
	
	var vehicle: Vehicle?
	
	init(odometer: Double, amount: Double, pricePerUnit: Double, fuelType: String? = nil, vehicle: Vehicle? = nil, timestamp: Date = .now) {
		self.id = UUID()
		self.timestamp = timestamp
		self.odometer = odometer
		self.amount = amount
		self.pricePerUnit = pricePerUnit
		self.fuelType = fuelType
		self.vehicle = vehicle
	}
	
	var formattedTimestamp: String {
		self.timestamp.formatted(.verbatim("\(day: .twoDigits)/\(month: .twoDigits)/\(year: .extended())", timeZone: .current, calendar: .current))
	}
	
	var totalPrice: Double {
		amount * pricePerUnit
	}
}
