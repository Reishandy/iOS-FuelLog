//
//  HomeViewModel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 13/06/26.
//

import SwiftData

@Observable
class HomeViewModel {
	private var modelContext: ModelContext
	
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
	}
}
