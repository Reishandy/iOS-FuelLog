import Foundation

enum Currency: String, CaseIterable {
	case usd = "USD"
	case cad = "CAD"
	case brl = "BRL"
	case mxn = "MXN"
	
	case chf = "CHF"
	case eur = "EUR"
	case gbp = "GBP"
	case sek = "SEK"
	case `try` = "TRY"
	
	case aed = "AED"
	case sar = "SAR"
	case zar = "ZAR"
	
	case aud = "AUD"
	case cny = "CNY"
	case hkd = "HKD"
	case inr = "INR"
	case jpy = "JPY"
	case krw = "KRW"
	case nzd = "NZD"
	case twd = "TWD"
	
	case idr = "IDR"
	case myr = "MYR"
	case php = "PHP"
	case sgd = "SGD"
	case thb = "THB"
	case vnd = "VND"
	
	var displayName: String {
		return Locale.current.localizedString(forCurrencyCode: self.rawValue) ?? self.rawValue
	}
	
	var symbol: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = self.rawValue
		formatter.locale = Locale.current
		
		return formatter.currencySymbol ?? self.rawValue
	}
}
