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
  Vehicle odometer or mileage reading as a plain decimal number. \
  Look for labels such as "ODO", "MILEAGE", "KM", or a large running \
  number on a dashboard display or printed on a fuel receipt. \
  Return the number only — no unit symbols.
  """)
	var odometer: Double?
	
	@Guide(description: """
  Total volume of fuel dispensed as a plain decimal number. \
  On pump receipts this may be labelled "VOLUME", "LITRES", "LITERS", \
  "QTY", "VOL", "JML LITER", or similar. \
  Return the number only — no unit symbols.
  """)
	var amount: Double?
	
	@Guide(description: """
  Price charged *per unit* of fuel as a plain decimal number. \
  Look for labels such as "PRICE/L", "UNIT PRICE", "HARGA/LITER", \
  "RM/L", or similar. \
  Do NOT use the total transaction price — only the per-unit rate.
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
			return "No text was detected in the image. Try a clearer, well-lit photo."
		case .intelligenceUnavailable:
			return "Apple Intelligence is not available. Check Settings › Apple Intelligence & Siri."
		case .modelNotReady:
			return "The on-device model is still preparing. Please try again in a moment."
		case .extractionFailed(let message):
			return "Extraction failed: \(message)"
		}
	}
}
