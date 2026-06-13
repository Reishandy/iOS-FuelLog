//
//  VehicleFilter.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 13/06/26.
//

enum VehicleGroupBy: String, CaseIterable {
	case none = "None"
	case vehivleType = "Type"
	case vehicleBrand = "Brand"
}

enum VehicleSortBy: String, CaseIterable {
	case timestampAsc = "Newest"
	case timestampDesc = "Oldest"
	case nameAsc = "Name (A-Z)"
	case nameDesc = "Name (Z-A)"
	case yearAsc = "Year Newest"
	case yearDesc = "Year Oldest"
}
