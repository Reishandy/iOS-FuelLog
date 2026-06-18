//
//  VisionExtractService.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 17/06/26.
//

import Vision
import FoundationModels

actor VisionExtractService {
	private var queue: [VisionTask] = []
	private var processingTask: Task<Void, Never>?
	
	private let (stream, continuation) = AsyncStream.makeStream(of: QueueEvent.self)
	var events: AsyncStream<QueueEvent> { stream }
	
	func enqueue(_ task: VisionTask) {
		queue.append(task)
		broadcast()
		
		if processingTask == nil {
			processingTask = Task { await drainQueue() }
		}
	}
	
	func cancelAll() {
		queue.removeAll()
		processingTask?.cancel()
		processingTask = nil
		broadcast()
	}
	
	private func drainQueue() async {
		while !queue.isEmpty {
			if Task.isCancelled { break }
			
			let currentTask = queue.first!
			
			let result = await process(currentTask)
			
			if Task.isCancelled { break }
			
			queue.removeFirst()
			broadcast(result: result)
		}
		
		processingTask = nil
	}
	
	private func broadcast(result: VisionResult? = nil) {
		continuation.yield(QueueEvent(pendingCount: queue.count, completedTask: result))
	}
	
	/// Two-stage pipeline:
	///   1. Vision OCR  →  raw text strings from the image
	///   2. Foundation Models  →  semantic field extraction via constrained decoding
	nonisolated private func process(_ task: VisionTask) async -> VisionResult {
		do {
			try Task.checkCancellation()
			
			// Stage 1 — OCR
			let rawText = try recognizeText(from: task.imageData)
			
			guard !rawText.isEmpty else {
				return VisionResult(id: task.id, extraction: nil, error: .noTextDetected)
			}
			
			try Task.checkCancellation()
			
			// Stage 2 — Semantic extraction
			let extraction = try await semanticExtract(from: rawText)
			return VisionResult(id: task.id, extraction: extraction, error: nil)
			
		} catch is CancellationError {
			return VisionResult(id: task.id, extraction: nil, error: nil)
		} catch let error as VisionExtractError {
			return VisionResult(id: task.id, extraction: nil, error: error)
		} catch {
			return VisionResult(id: task.id, extraction: nil, error: .extractionFailed(error.localizedDescription))
		}
	}
	
	/// Synchronously runs `VNRecognizeTextRequest` on the image data and
	/// returns all recognized strings joined by newlines.
	nonisolated private func recognizeText(from imageData: Data) throws -> String {
		let request = VNRecognizeTextRequest()
		request.recognitionLevel = .accurate
		request.usesLanguageCorrection = false
		request.automaticallyDetectsLanguage = true
		
		let handler = VNImageRequestHandler(data: imageData, options: [:])
		try handler.perform([request])
		
		return (request.results ?? [])
			.compactMap { $0.topCandidates(1).first?.string }
			.joined(separator: "\n")
	}
	
	/// Uses the on-device Apple Intelligence model to semantically parse raw OCR
	/// text into a typed `RefuelExtraction` struct.
	nonisolated private func semanticExtract(from rawText: String) async throws -> RefuelExtraction {
		switch SystemLanguageModel.default.availability {
		case .available:
			break
		case .unavailable(let reason):
			switch reason {
			case .deviceNotEligible:
				throw VisionExtractError.intelligenceUnavailable
			default:
				// Covers .appleIntelligenceNotEnabled, model not downloaded, etc.
				throw VisionExtractError.modelNotReady
			}
		}
		
		let session = LanguageModelSession(
			instructions: Instructions("""
		 You are a data extractor for a vehicle fuel log app.
		 You receive raw OCR text scanned from fuel pump receipts, \
		 fuel station displays, or vehicle dashboards.
		 Extract only the numeric values for the three requested fields.
		 Amounts from receipts in currencies like IDR/MYR/PHP may look like \
		 "10.000" or "10,000" — always return these as plain decimals (10000).
		 If a field cannot be confidently identified, leave it null.
		 Never guess. Do not extract fuel type.
		 """)
		)
		
		let response = try await session.respond(
			to: "Extract the fuel log fields from this OCR scan:\n\n\(rawText)",
			generating: RefuelExtraction.self
		)
		
		return response.content
	}
}
