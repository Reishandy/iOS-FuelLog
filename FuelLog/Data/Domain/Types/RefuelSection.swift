//
//  RefuelSection.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import Foundation

struct RefuelSection: Identifiable {
	let id = UUID()
	
	let title: String
	var refuels: [Refuel]
}
