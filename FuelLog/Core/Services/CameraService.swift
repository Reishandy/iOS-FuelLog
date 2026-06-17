//
//  CameraService.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 17/06/26.
//

import AVFoundation
import SwiftUI

@Observable
class CameraService: NSObject, AVCapturePhotoCaptureDelegate {
	var session = AVCaptureSession()
	var permissionStatus: AVAuthorizationStatus = .notDetermined
	
	private let output = AVCapturePhotoOutput()
	private var completionHandler: ((Data) -> Void)?
	
	override init() {
		super.init()
		checkPermission()
	}
	
	func checkPermission() {
		permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
	}
	
	func requestPermission() {
		AVCaptureDevice.requestAccess(for: .video) { granted in
			DispatchQueue.main.async {
				self.checkPermission()
				if granted {
					self.setupSession()
				}
			}
		}
	}
	
	func setupSession() {
		guard permissionStatus == .authorized else { return }
		
		if session.isRunning { return }
		
		session.beginConfiguration()
		
		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
			  let input = try? AVCaptureDeviceInput(device: device) else { return }
		
		if session.canAddInput(input) { session.addInput(input) }
		
		if session.canAddOutput(output) { session.addOutput(output) }
		
		session.commitConfiguration()
		
		DispatchQueue.global(qos: .background).async {
			self.session.startRunning()
		}
	}
	
	func capturePhoto(completion: @escaping (Data) -> Void) {
		self.completionHandler = completion
		let settings = AVCapturePhotoSettings()
		output.capturePhoto(with: settings, delegate: self)
	}
	
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let data = photo.fileDataRepresentation() else { return }
		completionHandler?(data)
	}
	
	func setFocus(focusPoint: CGPoint) {
		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
		
		do {
			try device.lockForConfiguration()
			
			if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
				device.focusPointOfInterest = focusPoint
				device.focusMode = .autoFocus
			}
			
			if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
				device.exposurePointOfInterest = focusPoint
				device.exposureMode = .autoExpose
			}
			
			device.unlockForConfiguration()
		} catch {
			print("Failed to lock device for focus: \(error.localizedDescription)")
		}
	}
}
