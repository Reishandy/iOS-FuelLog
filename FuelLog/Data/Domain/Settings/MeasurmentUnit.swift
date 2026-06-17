//
//  MeasurmentUnit.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

enum MeasurmentUnit: String, CaseIterable {
	case metric = "Metric"
	case imperial = "Imperial"
	
	/// Returns the short distance unit: "km" or "mi"
	var distanceShort: String {
		switch self {
		case .metric: return "km"
		case .imperial: return "mi"
		}
	}
	
	/// Returns the short volume unit: "L" or "gal"
	var volumeShort: String {
		switch self {
		case .metric: return "L"
		case .imperial: return "gal"
		}
	}
	
	/// Returns the singular long volume unit: "Liter" or "Gallon"
	var volumeSingular: String {
		switch self {
		case .metric: return "Liter"
		case .imperial: return "Gallon"
		}
	}
	
	/// Returns the plural long volume unit: "Liters" or "Gallons"
	var volumePlural: String {
		switch self {
		case .metric: return "Liters"
		case .imperial: return "Gallons"
		}
	}
	
	/// Returns the standard fuel efficiency format: "km/L" or "mpg"
	var efficiency: String {
		switch self {
		case .metric: return "km/L"
		case .imperial: return "mpg"
		}
	}
}
