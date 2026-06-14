//
//  CustomTextFieldView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 14/06/26.
//

import SwiftUI

struct CustomTextFieldView: View {
	@FocusState private var isFocused: Bool
	
	let label: String
	let placeholder: String
	
	@Binding var value: String
	
    var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			Text(label)
				.font(.title2)
				.bold()
				.padding(.leading, 12)
			
			TextField(placeholder, text: $value)
				.font(.title3)
				.padding(14)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.strokeBorder(.primary, lineWidth: 2)
						.opacity(isFocused ? 0.8 : 0.2)
				)
				.focused($isFocused)
		}
		.animation(.spring, value: isFocused)
    }
}

#Preview {
	CustomTextFieldView(label: "Label", placeholder: "Placeholder", value: .constant(""))
		.padding()
}
