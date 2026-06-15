//
//  VehicleDetailViewModel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import Foundation
import SwiftData

@Observable
class VehicleDetailViewModel {
	private var modelContext: ModelContext
	private var vehicleId: String
	
	var vehicle: Vehicle? = nil
	var filteredRefuels: [String: [Refuel]] = [:]
	
	init(modelContext: ModelContext, vehicleId: String) {
		self.modelContext = modelContext
		self.vehicleId = vehicleId
	}
	
	func fetchData() {
		do {
			var descriptor = FetchDescriptor<Vehicle>(
				predicate: #Predicate { $0.id.uuidString == self.vehicleId }
			)
			descriptor.fetchLimit = 1
			
			self.vehicle = try modelContext.fetch(descriptor).first
			self.filterRefuels()
		} catch {
			print("ERROR > Failed populating VehicleDetailViewModel: \(error)")
		}
	}
	
	private func filterRefuels() {
		
	}
}
