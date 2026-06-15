//
//  CustomListView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 13/06/26.
//

import SwiftUI
import SwiftData

struct CustomListView<T: Identifiable & Equatable, Content: View>: View {
	var groupedItem: [String: [T]] = [:]
	@ViewBuilder let content: (_ item: T) -> Content
	
	@State private var showDeleteConfirmation = false
	
	var body: some View {
		List {
			ForEach(groupedItem.keys.sorted(), id: \.self) { title in
				Section {
					ForEach(groupedItem[title] ?? []) { item in
						content(item)
					}
				} header: {
					Text(title)
						.font(.title2)
						.bold()
						.padding(.leading, -10)
				}
				.headerProminence(.increased)
			}
		}
	}
}

#Preview {
	let homeViewModel = HomeViewModel(modelContext: PreviewContainer.shared.mainContext)
	
	CustomListView(groupedItem: homeViewModel.filteredVehicles) { vehicle in
		VehicleListItemView(vehicle: vehicle)
	}
}
