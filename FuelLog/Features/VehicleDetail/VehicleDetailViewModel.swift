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
	private var vehicleId: UUID
	
	var vehicle: Vehicle? = nil
	var filteredRefuels: [String: [Refuel]] = [:]
	var fuelTypes: [String] = []
	
	var selectedRefuel: Refuel? = nil
	var refuelToDelete: Refuel? = nil
	
	var sortedSectionKeys: [String] {
		let predefinedOrder = ["Today", "Yesterday", "Past 7 Days", "Past 30 Days"]
		
		let monthYearFormatter = DateFormatter()
		monthYearFormatter.dateFormat = "MMMM yyyy"
		
		return filteredRefuels.keys.sorted { key1, key2 in
			let index1 = predefinedOrder.firstIndex(of: key1)
			let index2 = predefinedOrder.firstIndex(of: key2)
			
			if let idx1 = index1, let idx2 = index2 {
				return idx1 < idx2
			}
			
			if index1 != nil { return true }
			if index2 != nil { return false }
			
			if let date1 = monthYearFormatter.date(from: key1),
			   let date2 = monthYearFormatter.date(from: key2) {
				
				return date1 > date2
			}
			
			return key1 > key2
		}
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
			self.filterRefuels()
			
			let refuels = try modelContext.fetch(FetchDescriptor<Refuel>())
			self.fuelTypes = Array(Set(refuels.compactMap { $0.fuelType }))
		} catch {
			print("ERROR > Failed populating VehicleDetailViewModel: \(error)")
		}
	}
	
	func deleteRefuel() {
		if let refuelToDelete = self.refuelToDelete {
			modelContext.delete(refuelToDelete)
			try? modelContext.save()
			
			self.fetchData()
			self.refuelToDelete = nil
		}
	}
	
	private func filterRefuels() {
		guard let vehicle = self.vehicle else { return }
		
		var grouped: [String: [Refuel]] = [:]
		let calendar = Calendar.current
		
		let monthYearFormatter = DateFormatter()
		monthYearFormatter.dateFormat = "MMMM yyyy"
		
		for refuel in vehicle.refuels {
			let date = refuel.timestamp
			
			if calendar.isDateInToday(date) {
				grouped["Today", default: []].append(refuel)
			}
			else if calendar.isDateInYesterday(date) {
				grouped["Yesterday", default: []].append(refuel)
			}
			else if let daysAgo = calendar.dateComponents([.day], from: date, to: .now).day {
				if daysAgo <= 7 {
					grouped["Past 7 Days", default: []].append(refuel)
				} else if daysAgo <= 30 {
					grouped["Past 30 Days", default: []].append(refuel)
				} else {
					let monthYearString = monthYearFormatter.string(from: date)
					grouped[monthYearString, default: []].append(refuel)
				}
			}
			else {
				let monthYearString = monthYearFormatter.string(from: date)
				grouped[monthYearString, default: []].append(refuel)
			}
		}
		
		for (key, refuels) in grouped {
			grouped[key] = refuels.sorted(by: { $0.timestamp > $1.timestamp })
		}
		
		self.filteredRefuels = grouped
	}
}
