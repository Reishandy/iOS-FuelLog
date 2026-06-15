//
//  VehicleFormView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 14/06/26.
//

import SwiftUI

struct VehicleFormView: View {
	@Binding var name: String
	@Binding var brand: String
	@Binding var model: String
	@Binding var year: Int
	@Binding var capacity: Double
	@Binding var type: VehicleType
	
	@State private var wholeCapacity: Int = 0
	@State private var decimalCapacity: Int = 0
	
	// Range from first ever car to next year's model
	private let yearRange: [Int] = Array((1884...(Calendar.current.component(.year, from: Date()) + 1)).reversed())
	
	private var brandList: [String] {
		switch type {
		case .motorcycle:
			return VehicleBrand.motorcycles
		case .car:
			return VehicleBrand.cars
		}
	}
	
	var body: some View {
		Form {
			Section {
				VStack(spacing: 20) {
					TextField("Name", text: $name)
					
					Picker("Type", selection: $type	) {
						ForEach(VehicleType.allCases, id: \.self) { option in
							Text(option.rawValue).tag(option)
						}
					}
				}
			}
			
			Section {
				VStack(spacing: 20) {
					HStack {
						TextField("Brand", text: $brand)
						
						Picker("Select Brand", selection: $brand) {
							Text("Select Brand").tag("")
							
							ForEach(brandList, id: \.self) { option in
								Text(option).tag(option)
							}
						}
						.labelsHidden()
					}
					
					TextField("Model", text: $model)
					
					VStack(alignment: .leading) {
						Text("Year")
						
						Picker("Year", selection: $year) {
							ForEach(yearRange, id: \.self) { y in
								Text(String(y)).tag(y)
							}
						}
						.pickerStyle(.wheel)
						.frame(height: 120)
						.clipped()
					}
				}
			}
			
			Section {
				VStack(spacing: 18) {
					HStack {
						Text("Fuel Capacity")
						
						Spacer()
						
						Text("Liters")
							.font(.subheadline)
							.opacity(0.6)
					}
					
					HStack(spacing: 0) {
						Spacer()
						
						Picker("", selection: $wholeCapacity) {
							ForEach(0...999, id: \.self) { value in
								Text("\(value)").tag(value)
							}
						}
						.pickerStyle(.wheel)
						.clipped()
						
						Text(".")
							.font(.title)
							.bold()
							.padding(.horizontal, 4)
						
						Picker("", selection: $decimalCapacity) {
							ForEach(0...9, id: \.self) { value in
								Text("\(value)").tag(value)
							}
						}
						.pickerStyle(.wheel)
						.clipped()
						
						Spacer()
					}
					.frame(height: 120)
					.onChange(of: wholeCapacity) { _, _ in updateCapacityBinding() }
					.onChange(of: decimalCapacity) { _, _ in updateCapacityBinding() }
					.onAppear {
						parseInitialCapacity()
					}
				}
			}
		}	
	}
	
	private func updateCapacityBinding() {
		capacity = Double(wholeCapacity) + (Double(decimalCapacity) / 10.0)
	}
	
	private func parseInitialCapacity() {
		wholeCapacity = Int(capacity)
		
		let remainder = capacity.truncatingRemainder(dividingBy: 1)
		let roundedDecimal = Int((remainder * 10).rounded())
		
		decimalCapacity = max(0, min(9, roundedDecimal))
	}
}

#Preview {
	VehicleFormView(
		name: .constant(""),
		brand: .constant(""),
		model: .constant(""),
		year: .constant(Calendar.current.component(.year, from: Date())),
		capacity: .constant(0.0),
		type: .constant(.car)
	)
}
