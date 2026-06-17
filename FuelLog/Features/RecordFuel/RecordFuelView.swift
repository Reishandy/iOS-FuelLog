//
//  RecordFuelView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI
import SwiftData

struct RecordFuelView: View {
	@Namespace private var recordFuelScreenNameSpace
	@Environment(\.dismiss) private var dismiss
	
	@State var recordFuelViewModel: RecordFuelViewModel
	
	@State private var isAddSheetPresented: Bool = false
	@State private var isDismissConfirmationShown: Bool = false
	
	var body: some View {
		ZStack(alignment: .bottom) {
			// TODO: Camera view
			Text("TODO CAMERA")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.gray)
			
			Button {
				// TODO: Camera
			} label: {
				Circle()
					.frame(width: 70)
					.foregroundStyle(.white)
			}
			.buttonStyle(.plain)
			.background {
				Circle()
					.frame(width: 85, height: 85)
					.glassEffect()
			}
			.padding(.bottom, 30)
		}
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					if recordFuelViewModel.isAddFormDirty {
						isDismissConfirmationShown = true
					} else {
						dismiss()
					}
				} label: {
					Image(systemName: "chevron.left")
						.font(.body.weight(.semibold))
				}
				.confirmationDialog(
					"Discard Change",
					isPresented: $isDismissConfirmationShown
				) {
					Button("Discard Change", role: .destructive) {
						recordFuelViewModel.clearAddRefuel()
						dismiss()
					}
					.buttonStyle(.bordered)
				} message: {
					Text("Are you sure you want to discard this refuel?")
				}
			}
			
			ToolbarItem(placement: .bottomBar) {
				Button("Pick from gallery", systemImage: "photo.on.rectangle") {
					// TODO: Gallery Picker
				}
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				// TODO: Processing image loading, and notification if sucess process
				Text("Idling")
					.frame(maxWidth: .infinity)
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button {
					isAddSheetPresented = true
				} label: {
					Image(systemName: "fuelpump")
						.foregroundStyle(.white)
				}
				.buttonStyle(.glassProminent)
				.tint(.orange)
				.matchedTransitionSource(id: "addSheetSource", in: recordFuelScreenNameSpace)
			}
		}
		.sheet(isPresented: $isAddSheetPresented) {
			RefuelAddSheetView(
				odometer: $recordFuelViewModel.addOdometer,
				amount: $recordFuelViewModel.addAmount,
				pricePerUnit: $recordFuelViewModel.addPricePerUnit,
				fuelType: $recordFuelViewModel.addFuelType,
				timestamp: $recordFuelViewModel.addTimestamp,
				fuelTypes: recordFuelViewModel.fuelTypes,
				onDismissClick: {
					isAddSheetPresented = false
				},
				onSaveClick: {
					isAddSheetPresented = false
					recordFuelViewModel.addRefuel()
					dismiss()
				}
			)
			.navigationTransition(.zoom(sourceID: "addSheetSource", in: recordFuelScreenNameSpace))
		}
		.task {
			recordFuelViewModel.fetchData()
		}
	}
}

#Preview {
	let context = PreviewContainer.shared.mainContext
	
	let descriptor = FetchDescriptor<Vehicle>()
	let vehicles = try? context.fetch(descriptor)
	
	let firstVehicleId = vehicles?.first?.id ?? UUID()
	
	NavigationStack {
		RecordFuelView(
			recordFuelViewModel:
				RecordFuelViewModel(
					modelContext: context,
					vehicleId: firstVehicleId
				)
		)
	}
}
