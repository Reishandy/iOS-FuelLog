//
//  VehicleDetailVeiw.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI
import SwiftData

struct VehicleDetailVeiw: View {
	@State var vehicleDetailViewModel: VehicleDetailViewModel
	
    var body: some View {
		VStack {
			// TODO: Vehicle detail
			
			if vehicleDetailViewModel.filteredRefuels.isEmpty {
				VStack(spacing: 8) {
					Text("No refuel here")
						.font(.title2)
						.bold()
					
					Text("Record some first")
						.opacity(0.7)
				}
			} else {
				CustomListView(groupedItem: vehicleDetailViewModel.filteredRefuels) { refuel in
					Text(String(refuel.amount))
					// TODO: DO something with thiss
				}
			}
		}
		.task {
			vehicleDetailViewModel.fetchData()
		}
    }
}

#Preview {
	let context = PreviewContainer.shared.mainContext
	
	let descriptor = FetchDescriptor<Vehicle>()
	let vehicles = try? context.fetch(descriptor)
	
	let firstVehicleId = vehicles?.first?.id ?? UUID()
	
	return NavigationStack {
		VehicleDetailVeiw(
			vehicleDetailViewModel: VehicleDetailViewModel(
				modelContext: context,
				vehicleId: firstVehicleId
			)
		)
	}
}
