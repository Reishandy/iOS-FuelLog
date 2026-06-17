//
//  EmptyStateView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 17/06/26.
//

import SwiftUI

struct EmptyStateView: View {
	let title: String
	let subTitle: String
	var actionText: String? = nil
	var action: (() -> Void)? = nil
	
    var body: some View {
		VStack(spacing: action != nil ? 20 : 8) {
			Text(title)
				.font(.title2)
				.bold()
			
			Text(subTitle)
				.multilineTextAlignment(.center)
				.opacity(0.7)
			
			if let action = action, let actionText = actionText {
				Button(actionText) {
					action()
				}
				.buttonStyle(.glassProminent)
				.tint(.orange)
			}
		}
    }
}

#Preview {
	VStack(spacing: 20) {
		EmptyStateView(title: "Empty", subTitle: "There is nothing here")
		EmptyStateView(title: "Empty", subTitle: "There is nothing here", actionText: "Add Something") {}
	}
}
