//
//  Currency.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import Foundation

/// A curated list of the most common global currencies.
enum Currency: String, CaseIterable {
	case usd = "USD"
	case eur = "EUR"
	case gbp = "GBP"
	case jpy = "JPY"
	case aud = "AUD"
	case cad = "CAD"
	case cny = "CNY"
	case inr = "INR"
	case sgd = "SGD"
	case idr = "IDR"
	case chf = "CHF"
	case krw = "KRW"
	
	var displayName: String {
		return Locale.current.localizedString(forCurrencyCode: self.rawValue) ?? self.rawValue
	}
	
	var symbol: String {
		switch self {
		case .usd, .aud, .cad, .sgd:
			return "$"
		case .eur:
			return "€"
		case .gbp:
			return "£"
		case .jpy, .cny:
			return "¥"
		case .inr:
			return "₹"
		case .idr:
			return "Rp"
		case .chf:
			return "CHF"
		case .krw:
			return "₩"
		}
	}
}
