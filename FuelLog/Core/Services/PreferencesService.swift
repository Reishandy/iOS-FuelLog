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
		static let currency = "currency"
		static let measurementUnit = "measurementUnit"
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
	
	var currency: Currency {
		didSet {
			UserDefaults.standard.set(currency.rawValue, forKey: Keys.currency)
		}
	}
	
	var measurementUnit: MeasurmentUnit {
		didSet {
			UserDefaults.standard.set(measurementUnit.rawValue, forKey: Keys.measurementUnit)
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
		
		if let savedCurrencyString = UserDefaults.standard.string(forKey: Keys.currency),
		   let savedCurrency = Currency(rawValue: savedCurrencyString) {
			self.currency = savedCurrency
		} else {
			if let deviceCode = Locale.current.currency?.identifier,
			   let matchedEnum = Currency(rawValue: deviceCode) {
				self.currency = matchedEnum
			} else {
				self.currency = .usd
			}
		}
		
		if let savedUnitString = UserDefaults.standard.string(forKey: Keys.measurementUnit),
		   let savedUnit = MeasurmentUnit(rawValue: savedUnitString) {
			self.measurementUnit = savedUnit
		} else {
			let system = Locale.current.measurementSystem
			self.measurementUnit = system == .metric ? .metric : .imperial
		}
	}
}
