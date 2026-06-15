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
	
	var defaultVehicle: String {
		didSet {
			UserDefaults.standard.set(defaultVehicle, forKey: Keys.defaultVehicle)
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
		self.defaultVehicle = UserDefaults.standard.string(forKey: Keys.defaultVehicle) ?? ""
		
		let savedGroupString = UserDefaults.standard.string(forKey: Keys.defaultVehicleGroup) ?? ""
		self.defaultVehicleGroup = VehicleGroupBy(rawValue: savedGroupString) ?? .vehicleType
		
		let savedSortString = UserDefaults.standard.string(forKey: Keys.defaultVehicleSort) ?? ""
		self.defaultVehicleSort = VehicleSortBy(rawValue: savedSortString) ?? .timestampAsc
	}
}
