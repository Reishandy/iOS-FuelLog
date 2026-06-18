//
//  VisionType.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 17/06/26.
//

import SwiftUI
import FoundationModels

struct VisionTask: Identifiable, Sendable {
	let id: UUID
	let imageData: Data
}

struct VisionResult: Identifiable, Sendable {
	let id: UUID
	let extraction: RefuelExtraction?
	let error: VisionExtractError?
	
	var isSuccessful: Bool { extraction != nil }
}

struct QueueEvent: Sendable {
	let pendingCount: Int
	let completedTask: VisionResult?
}

@Generable
struct RefuelExtraction: Sendable {
	@Guide(description: """
  Vehicle odometer/mileage as a plain decimal number. \
  ONLY present on vehicle dashboards — look for labels "ODO", "ODOMETER", "MILEAGE", or "KM" \
  referring explicitly to vehicle distance. \
  NEVER set this field from a fuel pump display — pumps do not show odometer readings. \
  Return null if no such label is present.
  """)
	var odometer: Double?
	
	@Guide(description: """
  Total volume of fuel dispensed as a plain decimal number. \
  Indonesian pumps label this "JUMLAH DIKELUARKAN DALAM LITER" or "JUMLAH DIKELUARKAN". \
  Other pumps may use "VOLUME", "LITRES", "LITERS", "QTY", or "VOL". \
  Return the number only — no unit symbols.
  """)
	var amount: Double?
	
	@Guide(description: """
  Price charged *per unit* of fuel as a plain decimal number. \
  Indonesian pumps label this "HARGA SATU LITER" or "HARGA/LITER". \
  Other pumps may use "PRICE/L", "UNIT PRICE", or "RM/L". \
  The per-unit price is always much smaller than the total transaction price — \
  do NOT use "JUMLAH HARGA" or any total/grand-total value here. \
  Return the number only.
  """)
	var pricePerUnit: Double?
}

enum VisionExtractError: Error, Sendable, LocalizedError {
	case noTextDetected
	case intelligenceUnavailable
	case modelNotReady
	case extractionFailed(String)
	
	var errorDescription: String? {
		switch self {
		case .noTextDetected:
			return "No text was detected in the image."
		case .intelligenceUnavailable:
			return "Apple Intelligence is not available."
		case .modelNotReady:
			return "The on-device model is still preparing."
		case .extractionFailed(let message):
			return "Extraction failed: \(message)"
		}
	}
}
