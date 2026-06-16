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
	private var preferences: PreferencesService
	private var vehicles: [Vehicle] = []
	
	var filteredVehicles: [String: [Vehicle]] = [:]
	var customBrand: [String] = []
	
	var vehicleGroupBy: VehicleGroupBy = .vehicleType { didSet { filterVehcile() } }
	var vehicleSortBy: VehicleSortBy = .timestampAsc { didSet { filterVehcile() } }
	var vehicleSearchTerm: String = "" { didSet { filterVehcile() } }
	
	var selectedVehicle: Vehicle? = nil
	var vehicleToDelete: Vehicle? = nil
	
	var defaultVehicle: UUID? {
		get {
			preferences.defaultVehicle
		}
		set {
			if preferences.defaultVehicle == newValue {
				preferences.defaultVehicle = nil
			} else {
				preferences.defaultVehicle = newValue
			}
		}
	}
	
	var addName: String = ""
	var addBrand: String = ""
	var addModel: String = ""
	var addYear: Int = Calendar.current.component(.year, from: Date())
	var addCapacity: Double = 0.0
	var addType: VehicleType = .motorcycle
	
	init(modelContext: ModelContext, preferences: PreferencesService) {
		self.modelContext = modelContext
		self.preferences = preferences
		
		self.vehicleGroupBy = self.preferences.defaultVehicleGroup
		self.vehicleSortBy = self.preferences.defaultVehicleSort
	}
	
	func fetchData() {
		do {
			self.vehicles = try modelContext.fetch(FetchDescriptor<Vehicle>())
			self.filterVehcile()
		} catch {
			print("ERROR > Failed populating HomeViewModel: \(error)")
		}
	}
	
	func addVehicle() -> Vehicle {
		let newVehicle = Vehicle(
			name: self.addName,
			brand: self.addBrand,
			model: self.addBrand,
			year: self.addYear,
			tankCapacityLiter: self.addCapacity,
			vehicleType: self.addType
		)
		
		self.modelContext.insert(newVehicle)
		self.fetchData()
		self.clearAddVehicle()
		
		return newVehicle
	}
	
	func deleteVehicle() {
		if let vehicleToDelete = self.vehicleToDelete {
			modelContext.delete(vehicleToDelete)
			
			self.fetchData()
			self.vehicleToDelete = nil
			
			if defaultVehicle == vehicleToDelete.id {
				defaultVehicle = nil
			}
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
			groupedVehicles = sortedVehicles.isEmpty ? [:] : ["": sortedVehicles]
		case .vehicleType:
			groupedVehicles = Dictionary(grouping: sortedVehicles) { $0.vehicleType.rawValue }
		case .vehicleBrand:
			groupedVehicles = Dictionary(grouping: sortedVehicles) { $0.brand }
		}
		
		self.filteredVehicles = groupedVehicles
	}
}
