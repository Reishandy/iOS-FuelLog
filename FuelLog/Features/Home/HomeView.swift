//
//  HomeView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
	@Environment(\.modelContext) private var modelContext
	
	@State var homeViewModel: HomeViewModel
	
	var body: some View {
		ScrollView {
			ForEach(1...5, id: \.self) { num in
				VehicleListSubHeaderView(title: "Motorcycle \(num)", isExpanded: true) {
					// TODO: Collapse
				}
			
				ForEach(1...(num + 3), id: \.self) { lowNum in
					VehicleListItemView(
						title: "Motorcycle \(lowNum)",
						subTitle: "Honda PCX 160 2024",
						amount: lowNum * (num + 3),
						icon: "motorcycle",
						isDefault: lowNum == 1 && num == 1
					)
					
					if lowNum != num + 3 {
						Divider()
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding(.horizontal, 20)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.searchable(
			text: .constant(""), // TODO: Vehicle search
			placement: .toolbar,
			prompt: "Search Vehicle..."
		)
		.navigationTitle("Vehicles")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Settings", systemImage: "gearshape") {
					// TODO: App setting
				}
			}
			
			ToolbarItem(placement: .bottomBar) {
				Button("Filter Vehicles", systemImage: "line.3.horizontal.decrease") {
					// TODO: Vehicle filter, group by, sort by
				}
			}
			
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button("Add Vehicle", systemImage: "plus") {
					// TODO: Add Vehicle
				}
				.buttonStyle(.glassProminent)
			}
		}
	}
}

#Preview {
	NavigationStack	{
		HomeView(homeViewModel: HomeViewModel(modelContext: PreviewContainer.shared.mainContext))
	}
}
