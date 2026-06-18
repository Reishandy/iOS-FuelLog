//
//  RecordFuelViewModel.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 16/06/26.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI
import Toasts

@Observable
class RecordFuelViewModel {
	private var modelContext: ModelContext
	private var visionExtractService: VisionExtractService
	private var vehicleId: UUID
	private var vehicle: Vehicle? = nil
	
	var fuelTypes: [String] = []
	var maxAmount: Double {
		vehicle?.tankCapacity ?? 0.0
	}
	var pendingCount: Int = 0
	var toastToPresent: ToastValue?
	var toastCounter: Int = 0
	
	var selectedPhotoItems: [PhotosPickerItem] = []
	var cameraService: CameraService
	
	var isAddSheetPresented: Bool = false
	var addOdometer: Double = 0.0
	var addAmount: Double = 0.0
	var addPricePerUnit: Double = 0.0
	var addFuelType: String = ""
	var addTimestamp: Date = .now
	
	var isAddFormDirty: Bool {
		self.addOdometer != 0.0 ||
		self.addAmount != 0.0 ||
		self.addPricePerUnit != 0.0
	}
	var isAddFormFilled: Bool {
		self.addOdometer != 0.0 &&
		self.addAmount != 0.0 &&
		self.addPricePerUnit != 0.0
	}
	
	init(modelContext: ModelContext, vehicleId: UUID) {
		self.modelContext = modelContext
		self.visionExtractService = VisionExtractService()
		self.cameraService = CameraService()
		self.vehicleId = vehicleId
		
		Task { await observeQueue() }
	}
	
	func fetchData() {
		do {
			let targetId = self.vehicleId
			var descriptor = FetchDescriptor<Vehicle>(
				predicate: #Predicate { $0.id == targetId }
			)
			descriptor.fetchLimit = 1
			
			self.vehicle = try modelContext.fetch(descriptor).first
			
			let refuels = try modelContext.fetch(FetchDescriptor<Refuel>())
			self.fuelTypes = Array(Set(refuels.compactMap { $0.fuelType }))
			
			self.addTimestamp = .now
		} catch {
			print("ERROR > Failed populating RecordFuelViewModel: \(error)")
		}
	}
	
	func addRefuel() {
		let newRefeul = Refuel(
			odometer: self.addOdometer,
			amount: self.addAmount,
			pricePerUnit: self.addPricePerUnit,
			fuelType: self.addFuelType.isEmpty ? nil : self.addFuelType,
			timestamp: self.addTimestamp
		)
		
		self.vehicle?.refuels.append(newRefeul)
		self.fetchData()
		self.clearAddRefuel()
	}
	
	func clearAddRefuel() {
		self.addOdometer = 0.0
		self.addAmount = 0.0
		self.addPricePerUnit = 0.0
		self.addFuelType = ""
		self.addTimestamp = .now
	}
	
	func processSelectedPhotos() async {
		for item in self.selectedPhotoItems {
			if let data = try? await item.loadTransferable(type: Data.self) {
				addImageTask(data)
			}
		}
		
		self.selectedPhotoItems = []
	}
	
	func addImageTask(_ imageData: Data) {
		let newTask = VisionTask(
			id: UUID(),
			imageData: imageData,
		)
		
		Task { await self.visionExtractService.enqueue(newTask) }
	}
	
	func cleanup() {
		if cameraService.session.isRunning {
			cameraService.session.stopRunning()
		}
		
		Task { await self.visionExtractService.cancelAll() }
	}
	
	private func observeQueue() async {
		for await event in await self.visionExtractService.events {
			self.pendingCount = event.pendingCount
			
			if let result = event.completedTask {
				self.updateFromResult(result)
			}
		}
	}
	
	private func updateFromResult(_ visionResult: VisionResult) {
		if !visionResult.isSuccessful {
			self.toastToPresent = ToastValue(
				icon: Image(systemName: "exclamationmark.triangle"),
				message: visionResult.error?.errorDescription ?? "Unable to extract"
			)
			self.toastCounter += 1
			
			return
		}
		
		self.addOdometer = visionResult.extraction?.odometer ?? self.addOdometer
		self.addAmount = visionResult.extraction?.amount ?? self.addAmount
		self.addPricePerUnit = visionResult.extraction?.pricePerUnit ?? self.addPricePerUnit
		
		if self.isAddFormFilled {
			self.isAddSheetPresented = true
			
			Task { await self.visionExtractService.cancelAll() }
			
			return
		}
		
		if visionResult.extraction?.odometer != nil ||
			visionResult.extraction?.amount != nil ||
			visionResult.extraction?.pricePerUnit != nil {
			
			self.toastToPresent = ToastValue(
				icon: Image(systemName: "checkmark.circle"),
				message: "Data extracted"
			)
			self.toastCounter += 1
			
			return
		}
	}
}
