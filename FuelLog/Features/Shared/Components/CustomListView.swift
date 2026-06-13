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
	
	var body: some View {
		ScrollView {
			ForEach(groupedItem.keys.sorted(), id: \.self) { title in
				let items = groupedItem[title] ?? []
				
				Text(title)
					.font(.title2)
					.bold()
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.top, 24)
					.transition(.scale(0.8).combined(with: .opacity))
				
				ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
					content(item)
						.transition(.scale(0.8).combined(with: .opacity))
					
					if index < items.count - 1 {
						Divider()
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.animation(.spring, value: items)
			}
			.padding(.horizontal, 20)
			.frame(maxWidth: .infinity, alignment: .leading)
			.animation(.spring, value: groupedItem)
		}
	}
}

#Preview {
	let homeViewModel = HomeViewModel(modelContext: PreviewContainer.shared.mainContext)
	
	CustomListView(groupedItem: homeViewModel.filteredVehicles) { vehicle in
		VehicleListItemView(vehicle: vehicle)
	}
}
