//
//  VehicleDetailCardView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI
import SwiftData

struct VehicleDetailCardView: View {
	let vehicle: Vehicle
	
	@State private var isExpanded: Bool = false
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(vehicle.name)
				.font(.title)
				.bold()
				.lineLimit(1)
			
			Text(vehicle.brandModelYear)
				.opacity(0.7)
			
			if isExpanded {
				List {
					DetailListItemView(title: "Est. max range", value: vehicle.estimatedMaxRange)
					
					DetailListItemView(title: "Average efficiency", value: vehicle.averageKmL)
					
					DetailListItemView(title: "Cost / Km", value: vehicle.costPerKm)
					
					DetailListItemView(title: "Total fuel cost", value: vehicle.totalFuelCost)
					
					DetailListItemView(title: "Most recent odometer", value: vehicle.mostRecentOdometer)
					
					DetailListItemView(title: "Distance tracked", value: vehicle.totalDistanceTracked)
				}
				.padding(-20)
			} else {
				Spacer()
			}
			
			HStack(alignment: .bottom) {
				if !isExpanded {
					Text(vehicle.mostRecentOdometer)
						.font(.subheadline)
						.opacity(0.7)
				}
				
				Spacer()
				
				Image(systemName: "chevron.down")
					.font(.subheadline)
					.opacity(0.7)
					.rotationEffect(isExpanded ? .degrees(180) : .zero)
				
				if isExpanded {
					Spacer()
				}
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.frame(height: isExpanded ? 460 : 150)
		.glassEffect(
			isExpanded ? .regular.tint(Color(.secondarySystemBackground).opacity(1.0)) : .regular,
			in: RoundedRectangle(cornerRadius: 25)
		)
		.contentShape(Rectangle())
		.onTapGesture {
			withAnimation(.snappy) {
				isExpanded.toggle()
			}
		}
	}
}

struct DetailListItemView: View {
	let title: String
	let value: String
	
	var body: some View {
		HStack(alignment: .center) {
			Text(title)
				.font(.subheadline)
			
			Spacer()
			
			Text(value)
				.font(.subheadline)
				.bold()
				.opacity(0.7)
		}
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	let context = PreviewContainer.shared.mainContext
	
	let descriptor = FetchDescriptor<Vehicle>()
	let vehicles = try? context.fetch(descriptor)
	
	if let vehicle = vehicles?.first {
		VehicleDetailCardView(vehicle: vehicle)
			.padding(20)
		
		Spacer()
	}
}
