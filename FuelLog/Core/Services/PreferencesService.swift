//
//  PreferencesService.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI

@Observable
final class PreferencesService {
	private enum Keys {
		static let defaultVehicle = "defaultVehicle"
		static let defaultVehicleGroup = "defaultVehicleGroup"
		static let defaultVehicleSort = "defaultVehicleSort"
	}
	
	var defaultVehicle: UUID? {
		didSet {
			if let defaultVehicle {
				UserDefaults.standard.set(defaultVehicle.uuidString, forKey: Keys.defaultVehicle)
			} else {
				UserDefaults.standard.removeObject(forKey: Keys.defaultVehicle)
			}
		}
	}
	
	var defaultVehicleGroup: VehicleGroupBy {
		didSet {
			UserDefaults.standard.set(defaultVehicleGroup.rawValue, forKey: Keys.defaultVehicleGroup)
		}
	}
	
	var defaultVehicleSort: VehicleSortBy {
		didSet {
			UserDefaults.standard.set(defaultVehicleSort.rawValue, forKey: Keys.defaultVehicleSort)
		}
	}
	
	init() {
		if let uuidString = UserDefaults.standard.string(forKey: Keys.defaultVehicle),
		   let savedUUID = UUID(uuidString: uuidString) {
			self.defaultVehicle = savedUUID
		} else {
			self.defaultVehicle = nil
		}
		
		let savedGroupString = UserDefaults.standard.string(forKey: Keys.defaultVehicleGroup) ?? ""
		self.defaultVehicleGroup = VehicleGroupBy(rawValue: savedGroupString) ?? .vehicleType
		
		let savedSortString = UserDefaults.standard.string(forKey: Keys.defaultVehicleSort) ?? ""
		self.defaultVehicleSort = VehicleSortBy(rawValue: savedSortString) ?? .timestampAsc
	}
}
