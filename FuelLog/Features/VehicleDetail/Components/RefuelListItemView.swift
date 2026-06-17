//
//  RefuelListItemView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI

struct RefuelListItemView: View {
	@Environment(PreferencesService.self) private var preferences
	
	let refuel: Refuel
	
    var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading) {
				Text(refuel.totalPrice.formatted(.currency(code: preferences.currency.rawValue)))
					.lineLimit(1)
				
				Text(refuel.formattedTimestamp)
					.lineLimit(1)
					.font(.subheadline)
					.opacity(0.7)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text("\(refuel.amount.formatted(.number.precision(.fractionLength(1)))) \(preferences.measurementUnit.volumeShort)")
					.lineLimit(1)
				
				Text(refuel.fuelType ?? "")
					.lineLimit(1)
					.font(.subheadline)
					.opacity(0.7)
			}
		}
    }
}

#Preview {
	RefuelListItemView(refuel: Refuel(odometer: 1000.0, amount: 4.5, pricePerUnit: 12300, fuelType: "Pertamax"))
		.environment(PreferencesService())
}
