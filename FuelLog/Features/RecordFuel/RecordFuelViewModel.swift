//
//  RecordFuelViewModel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import Foundation
import SwiftData

@Observable
class RecordFuelViewModel {
	private var modelContext: ModelContext
	private var vehicleId: UUID
	private var vehicle: Vehicle? = nil
	
	var fuelTypes: [String] = []
	
	var addOdometer: Double = 0.0
	var addAmount: Double = 0.0
	var addPricePerUnit: Double = 0.0
	var addFuelType: String = ""
	var addTimestamp: Date = .now
	
	var isAddFormDirty: Bool {
		self.addOdometer != 0.0 ||
		self.addAmount != 0.0 ||
		self.addPricePerUnit != 0.0
	}
	
	init(modelContext: ModelContext, vehicleId: UUID) {
		self.modelContext = modelContext
		self.vehicleId = vehicleId
	}
	
	func fetchData() {
		do {
			let targetId = self.vehicleId
			var descriptor = FetchDescriptor<Vehicle>(
				predicate: #Predicate { $0.id == targetId }
			)
			descriptor.fetchLimit = 1
			
			self.vehicle = try modelContext.fetch(descriptor).first
			
			let refuels = try modelContext.fetch(FetchDescriptor<Refuel>())
			self.fuelTypes = Array(Set(refuels.compactMap { $0.fuelType }))
			
			self.addTimestamp = .now
		} catch {
			print("ERROR > Failed populating RecordFuelViewModel: \(error)")
		}
	}
	
	func addRefuel() {
		let newRefeul = Refuel(
			odometer: self.addOdometer,
			amount: self.addAmount,
			pricePerUnit: self.addPricePerUnit,
			fuelType: self.addFuelType.isEmpty ? nil : self.addFuelType,
			timestamp: self.addTimestamp
		)
		
		self.vehicle?.refuels.append(newRefeul)
		self.fetchData()
		self.clearAddRefuel()
	}
	
	func clearAddRefuel() {
		self.addOdometer = 0.0
		self.addAmount = 0.0
		self.addPricePerUnit = 0.0
		self.addFuelType = ""
		self.addTimestamp = .now
	}
}
