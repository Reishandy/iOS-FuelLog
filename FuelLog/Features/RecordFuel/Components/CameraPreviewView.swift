//
//  CameraPreviewView.swift
//  FuelLog
//

import SwiftUI
import AVFoundation

class VideoPreviewView: UIView {
	override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
	
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		return layer as! AVCaptureVideoPreviewLayer
	}
	
	var onFocusChange: ((CGPoint) -> Void)?
	var service: CameraService?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		addGestureRecognizer(tapGesture)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleTap(_ gesture: UITapGestureRecognizer) {
		let location = gesture.location(in: self)
		let cameraPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: location)
		
		service?.setFocus(focusPoint: cameraPoint)
		onFocusChange?(location)
	}
}

struct CameraPreviewView: UIViewRepresentable {
	let session: AVCaptureSession
	let service: CameraService
	var onFocusChange: ((CGPoint) -> Void)?
	
	func makeUIView(context: Context) -> VideoPreviewView {
		let view = VideoPreviewView()
		view.videoPreviewLayer.session = session
		view.videoPreviewLayer.videoGravity = .resizeAspectFill
		view.service = service
		view.onFocusChange = onFocusChange
		return view
	}
	
	func updateUIView(_ uiView: VideoPreviewView, context: Context) {
		if uiView.videoPreviewLayer.session !== session {
			uiView.videoPreviewLayer.session = session
		}
		uiView.service = service
		uiView.onFocusChange = onFocusChange
	}
}
