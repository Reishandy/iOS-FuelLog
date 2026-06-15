//
//  HomeViewModel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 13/06/26.
//

import Foundation
import SwiftData

@Observable
class HomeViewModel {
	private var modelContext: ModelContext
	private var vehicles: [Vehicle] = []
	
	var filteredVehicles: [String: [Vehicle]] = [:]
	
	var vehicleGroupBy: VehicleGroupBy = .vehivleType { didSet { filterVehcile() } }
	var vehicleSortBy: VehicleSortBy = .timestampAsc { didSet { filterVehcile() } }
	var vehicleSearchTerm: String = "" { didSet { filterVehcile() } }
	var vehicleToDelete: Vehicle? = nil
	
	var addName: String = ""
	var addBrand: String = ""
	var addModel: String = ""
	var addYear: Int = Calendar.current.component(.year, from: Date())
	var addCapacity: Double = 0.0
	var addType: VehicleType = .motorcycle
	
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		
		// TODO: Saved filter preference
		// TODO: Default vehicle
	}
	
	func fetchData() {
		do {
			self.vehicles = try modelContext.fetch(FetchDescriptor<Vehicle>())
			self.filterVehcile()
		} catch {
			print("ERROR > Failed populating HomeViewModel: \(error)")
		}
	}
	
	func addVehicle() {
		self.modelContext.insert(
			Vehicle(
				name: self.addName,
				brand: self.addBrand,
				model: self.addBrand,
				year: self.addYear,
				tankCapacityLiter: self.addCapacity,
				vehivleType: self.addType
			)
		)
		self.fetchData()
		self.clearAddVehicle()
	}
	
	func deleteVehicle() {
		if let vehicleToDelete = self.vehicleToDelete {
			modelContext.delete(vehicleToDelete)
			
			self.fetchData()
			self.vehicleToDelete = nil
		}
	}
	
	func clearAddVehicle() {
		self.addName = ""
		self.addBrand = ""
		self.addModel = ""
		self.addYear = Calendar.current.component(.year, from: Date())
		self.addCapacity = 0.0
		self.addType = .motorcycle
	}
	
	private func filterVehcile() {
		let searchedVehicles = self.vehicles.filter { vehicle in
			let combined = "\(vehicle.name) \(vehicle.brand) \(vehicle.model) \(String(vehicle.year))"
			
			return self.vehicleSearchTerm.isEmpty ||
			combined.localizedCaseInsensitiveContains(self.vehicleSearchTerm)
		}
		
		let sortedVehicles: [Vehicle]
		switch self.vehicleSortBy {
		case .timestampAsc:
			sortedVehicles = searchedVehicles.sorted(by: { $0.timestamp < $1.timestamp })
		case .timestampDesc:
			sortedVehicles = searchedVehicles.sorted(by: { $0.timestamp > $1.timestamp })
		case .nameAsc:
			sortedVehicles = searchedVehicles.sorted(by: { $0.name < $1.name })
		case .nameDesc:
			sortedVehicles = searchedVehicles.sorted(by: { $0.name > $1.name })
		case .yearAsc:
			sortedVehicles = searchedVehicles.sorted(by: { $0.year < $1.year })
		case .yearDesc:
			sortedVehicles = searchedVehicles.sorted(by: { $0.year > $1.year })
		}
		
		let groupedVehicles: [String: [Vehicle]]
		switch self.vehicleGroupBy {
		case .none:
			groupedVehicles = ["": sortedVehicles]
		case .vehivleType:
			groupedVehicles = Dictionary(grouping: sortedVehicles) { $0.vehivleType.rawValue }
		case .vehicleBrand:
			groupedVehicles = Dictionary(grouping: sortedVehicles) { $0.brand }
		}
		
		self.filteredVehicles = groupedVehicles
	}
}
