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
	var filteredRefuels: [RefuelSection] = []
	
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
		} catch {
			print("ERROR > Failed populating VehicleDetailViewModel: \(error)")
		}
	}
	
	private func filterRefuels() {
		guard let vehicle = self.vehicle else { return }
		
		let calendar = Calendar.current
		let now = Date.now
		
		var today: [Refuel] = []
		var yesterday: [Refuel] = []
		var past30: [Refuel] = []
		var monthBuckets: [Date: [Refuel]] = [:]
		
		for refuel in vehicle.refuels {
			let date = refuel.timestamp
			
			if calendar.isDateInToday(date) {
				today.append(refuel)
			} else if calendar.isDateInYesterday(date) {
				yesterday.append(refuel)
			} else if let daysAgo = calendar.dateComponents([.day], from: date, to: now).day, daysAgo <= 30 {
				past30.append(refuel)
			} else {
				let components = calendar.dateComponents([.year, .month], from: date)
				if let startOfMonth = calendar.date(from: components) {
					monthBuckets[startOfMonth, default: []].append(refuel)
				}
			}
		}
		
		var finalSections: [RefuelSection] = []
		
		if !today.isEmpty {
			finalSections.append(RefuelSection(title: "Today", refuels: today.sorted(by: { $0.timestamp > $1.timestamp })))
		}
		if !yesterday.isEmpty {
			finalSections.append(RefuelSection(title: "Yesterday", refuels: yesterday.sorted(by: { $0.timestamp > $1.timestamp })))
		}
		if !past30.isEmpty {
			finalSections.append(RefuelSection(title: "Past 30 Days", refuels: past30.sorted(by: { $0.timestamp > $1.timestamp })))
		}
		
		let monthYearFormatter = DateFormatter()
		monthYearFormatter.dateFormat = "MMMM yyyy"
		
		let sortedMonthDates = monthBuckets.keys.sorted(by: >)
		
		for monthDate in sortedMonthDates {
			let formattedTitle = monthYearFormatter.string(from: monthDate)
			let sortedRefuels = monthBuckets[monthDate]!.sorted(by: { $0.timestamp > $1.timestamp })
			
			finalSections.append(RefuelSection(title: formattedTitle, refuels: sortedRefuels))
		}
		
		self.filteredRefuels = finalSections
	}
}
