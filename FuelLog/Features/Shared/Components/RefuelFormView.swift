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
	
	@Binding var isFormValid: Bool
	
	var fuelTypes: [String]
	var onFieldUnfocus: ((RefuelFormField) -> Void)? = nil
	
	@State private var wholeCapacity: Int = 0
	@State private var decimalCapacity: Int = 0
	@State private var odometerText: String = ""
	@State private var pricePerUnitText: String = ""
	@State private var priceTotalText: String = ""
	@State private var priceInputMethod: PriceInputMethod = .perUnit
	
	@FocusState private var focusedField: RefuelFormField?
	
	var body: some View {
		Form {
			Section {
				VStack(spacing: 20) {
					HStack {
						TextField("Odometer", text: $odometerText)
							.keyboardType(.decimalPad)
							.focused($focusedField, equals: .odometer)
						
						Text(preferences.measurementUnit.distanceShort)
							.font(.subheadline)
							.opacity(0.6)
					}
					
					HStack {
						Text("Amount")
						
						Spacer()
						
						Text(preferences.measurementUnit.volumePlural)
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
					Picker("Price Input Method", selection: $priceInputMethod) {
						Text("Price per \(preferences.measurementUnit.volumeSingular)").tag(PriceInputMethod.perUnit)
						
						Text("Price total").tag(PriceInputMethod.total)
					}
					.pickerStyle(.segmented)
					.disabled(amount == 0.0)
					
					switch priceInputMethod {
					case .perUnit:
						HStack {
							Text(preferences.currency.symbol)
								.font(.subheadline)
								.opacity(0.6)
							
							TextField("Price", text: $pricePerUnitText)
								.keyboardType(.decimalPad)
								.focused($focusedField, equals: .pricePerUnit)
							
							Text(" / \(preferences.measurementUnit.volumeSingular)")
								.font(.subheadline)
								.opacity(0.6)
						}
					case .total:
						HStack {
							Text(preferences.currency.symbol)
								.font(.subheadline)
								.opacity(0.6)
							
							TextField("Price Total", text: $priceTotalText)
								.keyboardType(.decimalPad)
								.focused($focusedField, equals: .priceTotal)
						}
					}
					
					HStack {
						TextField("Fuel Type", text: $fuelType)
						
						Picker("Select Type", selection: $fuelType) {
							Text("Select Type").tag("")
							
							if !fuelType.isEmpty && !fuelTypes.contains(fuelType) {
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
			priceInputMethod = preferences.priceInputMethod
			
			if odometer != 0.0 {
				odometerText = format(value: odometer)
			}
			
			if pricePerUnit != 0.0 {
				pricePerUnitText = format(value: pricePerUnit)
				if amount != 0.0 {
					priceTotalText = format(value: (pricePerUnit * amount))
				}
			}
			
			updateValidationAndSync()
		}
		.onChange(of: focusedField) { oldValue, newValue in
			if let unfocusedField = oldValue {
				switch unfocusedField {
				case .odometer:
					commitDecimalField(text: $odometerText, to: $odometer)
				case .pricePerUnit:
					commitDecimalField(text: $pricePerUnitText, to: $pricePerUnit)
				case .priceTotal:
					priceTotalText = format(value: parseDouble(from: priceTotalText))
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
		.onChange(of: odometerText) { _, _ in updateValidationAndSync() }
		.onChange(of: pricePerUnitText) { _, _ in updateValidationAndSync() }
		.onChange(of: priceTotalText) { _, _ in updateValidationAndSync() }
		.onChange(of: priceInputMethod) { _, _ in updateValidationAndSync() }
	}
	
	private func updateAmountBinding() {
		amount = Double(wholeCapacity) + (Double(decimalCapacity) / 10.0)
		
		if amount == 0.0 && priceInputMethod == .total {
			priceInputMethod = .perUnit
		}
		
		if amount > 0.0 {
			if priceInputMethod == .perUnit {
				let newTotal = pricePerUnit * amount
				let formattedTotal = format(value: newTotal)
				if priceTotalText != formattedTotal {
					priceTotalText = formattedTotal
				}
			} else if priceInputMethod == .total {
				let currentTotal = parseDouble(from: priceTotalText)
				let newUnit = currentTotal / amount
				
				if pricePerUnit != newUnit {
					pricePerUnit = newUnit
				}
				
				let formattedUnit = format(value: newUnit)
				if pricePerUnitText != formattedUnit {
					pricePerUnitText = formattedUnit
				}
			}
		}
		
		updateValidationAndSync()
	}
	
	private func parseInitialAmount() {
		wholeCapacity = Int(amount)
		decimalCapacity = Int((amount.truncatingRemainder(dividingBy: 1) * 10).rounded())
	}
	
	private func commitDecimalField(text: Binding<String>, to value: Binding<Double>) {
		let parsedValue = parseDouble(from: text.wrappedValue)
		value.wrappedValue = parsedValue
		text.wrappedValue = format(value: parsedValue)
	}
	
	private func syncDecimalText(for newValue: Double, textBinding: Binding<String>) {
		if newValue != parseDouble(from: textBinding.wrappedValue) {
			textBinding.wrappedValue = format(value: newValue)
		}
	}
	
	private func updateValidationAndSync() {
		let parsedOdo = parseDouble(from: odometerText)
		if odometer != parsedOdo { odometer = parsedOdo }
		
		syncPrices()
		
		let isOdoValid = !odometerText.trimmingCharacters(in: .whitespaces).isEmpty
		
		let isPriceValid = priceInputMethod == .perUnit ?
		!pricePerUnitText.trimmingCharacters(in: .whitespaces).isEmpty :
		!priceTotalText.trimmingCharacters(in: .whitespaces).isEmpty
		
		let isAmountValid = amount > 0.0
		
		isFormValid = isOdoValid && isPriceValid && isAmountValid
	}
	
	private func syncPrices() {
		if priceInputMethod == .perUnit {
			let parsedPrice = parseDouble(from: pricePerUnitText)
			if pricePerUnit != parsedPrice { pricePerUnit = parsedPrice }
			
			if amount > 0.0 {
				let calculatedTotal = parsedPrice * amount
				let formattedTotal = format(value: calculatedTotal)
				if priceTotalText != formattedTotal { priceTotalText = formattedTotal }
			}
			
		} else if priceInputMethod == .total {
			let parsedTotal = parseDouble(from: priceTotalText)
			
			if amount > 0.0 {
				let calculatedUnit = parsedTotal / amount
				if pricePerUnit != calculatedUnit { pricePerUnit = calculatedUnit }
				
				let formattedUnit = format(value: calculatedUnit)
				if pricePerUnitText != formattedUnit { pricePerUnitText = formattedUnit }
			}
		}
	}
	
	private func parseDouble(from string: String) -> Double {
		Double(string.replacingOccurrences(of: ",", with: ".")) ?? 0.0
	}
	
	private func format(value: Double) -> String {
		value == 0.0 ? "" : String(format: "%g", value)
	}
}

#Preview {
    RefuelFormView(
		odometer: .constant(0.0),
		amount: .constant(0.0),
		pricePerUnit: .constant(0.0),
		fuelType: .constant(""),
		timestamp: .constant(.now),
		isFormValid: .constant(false),
		fuelTypes: ["Pertamax", "Pertalite"]
	)
	.environment(PreferencesService())
}
