//
//  HomeView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 12/06/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
		ScrollView {
			Text("")
		}
		.navigationTitle("Vehicles")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					
				} label: {
					Image(systemName: "gearshape")
				}
			}
			
			ToolbarItem(placement: .bottomBar) {
				Button {
					
				} label: {
					Image(systemName: "plus")
				}
			}
		}
    }
}

#Preview {
	NavigationStack	{
		HomeView()
	}
}
