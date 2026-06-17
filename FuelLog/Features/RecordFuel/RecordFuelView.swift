//
//  RecordFuelView.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct RecordFuelView: View {
	@Namespace private var recordFuelScreenNameSpace
	@Environment(\.dismiss) private var dismiss
	
	@State var recordFuelViewModel: RecordFuelViewModel
	
	@State private var isAddSheetPresented: Bool = false
	@State private var isDismissConfirmationShown: Bool = false
	@State private var buttonScale: CGFloat = 1.0
	@State private var flashOpacity: Double = 0.0
	
	private var isProcessing: Bool {
		recordFuelViewModel.pendingCount > 0
	}
	
	private var processingText: String {
		isProcessing ? "processing \(recordFuelViewModel.pendingCount) image\(recordFuelViewModel.pendingCount > 1 ? "s" : "")" : "capture to start process"
	}
	
	private var statusColor: Color {
		guard let isSuccess = recordFuelViewModel.isStatusSuccess else {
			return .clear
		}
		return isSuccess ? .green : .red
	}
	
	var body: some View {
		ZStack(alignment: .bottom) {
			// TODO: Camera view
			Text("TODO CAMERA")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.gray)
			
			LinearGradient(
				colors: [statusColor, .clear],
				startPoint: .bottom,
				endPoint: .top
			)
			.blur(radius: 50)
			.frame(height: 200)
			.offset(y: 100)
			.ignoresSafeArea()
			.allowsHitTesting(false)
			.animation(.easeInOut(duration: 0.5), value: statusColor)
			
			Color.black
				.opacity(flashOpacity)
				.ignoresSafeArea()
				.allowsHitTesting(false)
			
			Button {
				triggerShutterAnimation()
				
				// TODO: Camera
				recordFuelViewModel.addImageTask(Data())
			} label: {
				Circle()
					.frame(width: 70)
					.foregroundStyle(.white)
					.scaleEffect(buttonScale)
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
		.navigationTitle("Record Refuel")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					if recordFuelViewModel.isAddFormDirty {
						isDismissConfirmationShown = true
					} else {
						recordFuelViewModel.cancelQueue()
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
						recordFuelViewModel.cancelQueue()
						dismiss()
					}
					.buttonStyle(.bordered)
				} message: {
					Text("Are you sure you want to discard this refuel?")
				}
			}
			
			ToolbarItem(placement: .bottomBar) {
				PhotosPicker(
					selection: $recordFuelViewModel.selectedPhotoItems,
					maxSelectionCount: 0,
					matching: .images
				) {
					Label("Pick from gallery", systemImage: "photo.on.rectangle.angled")
				}
				.onChange(of: recordFuelViewModel.selectedPhotoItems) { oldValue, newValue in
					guard !newValue.isEmpty else { return }
					
					Task { await recordFuelViewModel.processSelectedPhotos() }
				}
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				HStack {
					Text(processingText)
						.font(.callout)
					
					if isProcessing {
						ProgressView()
					}
				}
				.animation(.default, value: isProcessing)
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
				maxAmount: recordFuelViewModel.maxAmount,
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
	
	private func triggerShutterAnimation() {
		flashOpacity = 1.0
		withAnimation(.easeInOut(duration: 0.5)) {
			flashOpacity = 0.0
		}
		
		withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
			buttonScale = 0.8
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
				buttonScale = 1.0
			}
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
