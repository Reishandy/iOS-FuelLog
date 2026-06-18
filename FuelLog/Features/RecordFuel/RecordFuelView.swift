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
	@State private var focusPoint: CGPoint? = nil
	@State private var showFocusReticle: Bool = false
	
	private var isProcessing: Bool {
		recordFuelViewModel.pendingCount > 0
	}
	
	private var processingText: String {
		isProcessing ? "processing \(recordFuelViewModel.pendingCount) image\(recordFuelViewModel.pendingCount > 1 ? "s" : "")" : "waiting for image"
	}
	
	var body: some View {
		Group {
			switch recordFuelViewModel.cameraService.permissionStatus {
			case .authorized:
				ZStack(alignment: .bottom) {
					CameraPreviewView(
						session: recordFuelViewModel.cameraService.session,
						service: recordFuelViewModel.cameraService,
						onFocusChange: { tapLocation in
							self.focusPoint = tapLocation
							
							withAnimation(.easeInOut(duration: 0.2)) {
								self.showFocusReticle = true
							}
							
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
								withAnimation(.easeIn(duration: 0.2)) {
									self.showFocusReticle = false
								}
							}
						}
					)
					.ignoresSafeArea()
					
					if showFocusReticle, let point = focusPoint {
						Rectangle()
							.stroke(Color.yellow, lineWidth: 1)
							.frame(width: 70, height: 70)
							.position(point)
							.ignoresSafeArea()
					}
					
					Color.black
						.opacity(flashOpacity)
						.ignoresSafeArea()
						.allowsHitTesting(false)
					
					Button {
						triggerShutterAnimation()
						
						recordFuelViewModel.cameraService.capturePhoto { rawData in
							recordFuelViewModel.addImageTask(rawData)
						}
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
					.padding(.bottom, 20)
				}
				.onAppear {
					recordFuelViewModel.cameraService.setupSession()
				}
				
			case .notDetermined:
				EmptyStateView(
					title: "Camera Access Required",
					subTitle: "We need access to your camera to show the viewfinder and take photos.",
					actionText: "Grant Permission"
				) {
					recordFuelViewModel.cameraService.requestPermission()
				}
				
			default:
				EmptyStateView(
					title: "Camera access was denied",
					subTitle: "Please enable it in iPhone Settings.",
					actionText: "Open Settings"
				) {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				}
			}
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
						recordFuelViewModel.cleanup()
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
						recordFuelViewModel.cleanup()
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
