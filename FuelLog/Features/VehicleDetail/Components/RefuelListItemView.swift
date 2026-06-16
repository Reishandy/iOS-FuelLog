//
//  RefuelListItemView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 15/06/26.
//

import SwiftUI

struct RefuelListItemView: View {
	let refuel: Refuel
	
    var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading) {
				// TODO: Use locale for currency
				Text(refuel.totalPrice.formatted(.currency(code: "IDR")))
					.lineLimit(1)
				
				Text(refuel.formattedTimestamp)
					.lineLimit(1)
					.font(.subheadline)
					.opacity(0.7)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				// TODO: Use locale for unit
				Text("\(refuel.amount.formatted(.number.precision(.fractionLength(1)))) L")
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
	RefuelListItemView(refuel: Refuel(odometer: 1000.0, amount: 4.5, pricePerLiter: 12300, fuelType: "Pertamax"))
}
