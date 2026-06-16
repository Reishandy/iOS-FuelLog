//
//  RefuelFormView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI

struct RefuelFormView: View {
	@Environment(PreferencesService.self) private var preferences
	
	@Binding var odometer: Double
	@Binding var amount: Double
	@Binding var pricePerUnit: Double
	@Binding var fuelType: String
	@Binding var timestamp: Date
	
	var fuelTypes: [String]
	var onFieldUnfocus: ((RefuelFormField) -> Void)? = nil
	
	@State private var wholeCapacity: Int = 0
	@State private var decimalCapacity: Int = 0
	@State private var odometerText: String = ""
	@State private var pricePerUnitText: String = ""
	
	@FocusState private var focusedField: RefuelFormField?
	
	// TODO: Switch for total price
    var body: some View {
		Form {
			Section {
				VStack(spacing: 20) {
					HStack {
						TextField("Odometer", text: $odometerText)
							.keyboardType(.decimalPad)
							.focused($focusedField, equals: .odometer)
					
						Text(preferences.measurementUnit == .metric ? "Km" : "mi")
							.font(.subheadline)
							.opacity(0.6)
					}
					
					HStack {
						Text("Amount")
						
						Spacer()
						
						Text(preferences.measurementUnit == .metric ? "Liters" : "Gallons")
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
					.onChange(of: wholeCapacity) { _, _ in updateAmountBinding() }
					.onChange(of: decimalCapacity) { _, _ in updateAmountBinding() }
					.onAppear {
						parseInitialAmount()
					}
				}
			}
			
			Section {
				VStack(spacing: 20) {
					HStack {
						Text(preferences.currency.symbol)
							.font(.subheadline)
							.opacity(0.6)
						
						TextField("Price", text: $pricePerUnitText)
							.keyboardType(.decimalPad)
							.focused($focusedField, equals: .pricePerUnit)
						
						Text("/ \(preferences.measurementUnit == .metric ? "Liter" : "Gallon")")
							.font(.subheadline)
							.opacity(0.6)
					}
					
					HStack {
						TextField("Fuel Type", text: $fuelType)
						
						Picker("Select Type", selection: $fuelType) {
							Text("Select Type").tag("")
							
							if !fuelType.isEmpty {
								Text(fuelType).tag(fuelType)
							}
							
							ForEach(fuelTypes, id: \.self) { option in
								Text(option).tag(option)
							}
						}
						.labelsHidden()
					}
				}
			}
			
			Section {
				DatePicker(
					"Date & Time",
					selection: $timestamp,
					displayedComponents: [.date, .hourAndMinute]
				)
			}
		}
		.listSectionSpacing(.custom(20))
		.onAppear {
			if odometer != 0.0 {
				// %g removes trailing zero
				odometerText = String(format: "%g", odometer)
			}
			
			if pricePerUnit != 0.0 {
				pricePerUnitText = String(format: "%g", pricePerUnit)
			}
		}
		.onChange(of: focusedField) { oldValue, newValue in
			if let unfocusedField = oldValue {
				
				switch unfocusedField {
				case .odometer:
					commitDecimalField(text: $odometerText, to: $odometer)
				case .pricePerUnit:
					commitDecimalField(text: $pricePerUnitText, to: $pricePerUnit)
				}
				
				DispatchQueue.main.async {
					onFieldUnfocus?(unfocusedField)
				}
			}
		}
		.onChange(of: odometer) { _, newValue in
			syncDecimalText(for: newValue, textBinding: $odometerText)
		}
		.onChange(of: pricePerUnit) { _, newValue in
			syncDecimalText(for: newValue, textBinding: $pricePerUnitText)
		}
    }
	
	private func updateAmountBinding() {
		amount = Double(wholeCapacity) + (Double(decimalCapacity) / 10.0)
	}
	
	private func parseInitialAmount() {
		wholeCapacity = Int(amount)
		
		let remainder = amount.truncatingRemainder(dividingBy: 1)
		let roundedDecimal = Int((remainder * 10).rounded())
		
		decimalCapacity = max(0, min(9, roundedDecimal))
	}
	
	private func commitDecimalField(text: Binding<String>, to value: Binding<Double>) {
		let parsedValue = Double(text.wrappedValue.replacingOccurrences(of: ",", with: ".")) ?? 0.0
		
		value.wrappedValue = parsedValue
		
		if parsedValue == 0.0 {
			text.wrappedValue = ""
		} else {
			text.wrappedValue = String(format: "%g", parsedValue)
		}
	}
	
	private func syncDecimalText(for newValue: Double, textBinding: Binding<String>) {
		let currentParsed = Double(textBinding.wrappedValue.replacingOccurrences(of: ",", with: ".")) ?? 0.0
		
		if newValue != currentParsed {
			textBinding.wrappedValue = newValue == 0.0 ? "" : String(format: "%g", newValue)
		}
	}
}

#Preview {
    RefuelFormView(
		odometer: .constant(0.0),
		amount: .constant(0.0),
		pricePerUnit: .constant(0.0),
		fuelType: .constant(""),
		timestamp: .constant(.now),
		fuelTypes: ["Pertamax", "Pertalite"]
	)
	.environment(PreferencesService())
}
