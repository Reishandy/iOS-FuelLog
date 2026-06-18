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
			
			let rawText = try recognizeText(from: task.imageData)
			
			guard !rawText.isEmpty else {
				return VisionResult(id: task.id, extraction: nil, error: .noTextDetected)
			}
			
			try Task.checkCancellation()
			
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
	
	nonisolated private func recognizeText(from imageData: Data) throws -> String {
		let request = VNRecognizeTextRequest()
		request.recognitionLevel = .accurate
		request.usesLanguageCorrection = false
		request.automaticallyDetectsLanguage = false
		
		let handler = VNImageRequestHandler(data: imageData, options: [:])
		try handler.perform([request])
		
		let observations = request.results ?? []
		guard !observations.isEmpty else { return "" }
		
		let rowGrouped = Dictionary(grouping: observations) { obs -> Int in
			Int((obs.boundingBox.midY * 12).rounded()) // ~8% bands
		}
		
		let sortedRows = rowGrouped.sorted { $0.key > $1.key }
		
		return sortedRows.map { (_, rowObservations) in
			rowObservations
				.sorted { $0.boundingBox.minX < $1.boundingBox.minX } // left → right
				.compactMap { $0.topCandidates(1).first?.string }
				.joined(separator: " ")
		}.joined(separator: "\n")
	}
	
	nonisolated private func semanticExtract(from rawText: String) async throws -> RefuelExtraction {
		switch SystemLanguageModel.default.availability {
		case .available:
			break
		case .unavailable(let reason):
			switch reason {
			case .deviceNotEligible:
				throw VisionExtractError.intelligenceUnavailable
			default:
				throw VisionExtractError.modelNotReady
			}
		}
		
		let session = LanguageModelSession(
			instructions: Instructions("""
	You are a data extractor for a vehicle fuel log app. \
	You receive spatially-reconstructed OCR text from fuel pump displays \
	or vehicle dashboards, where each line pairs a value with its label.
	
	FUEL PUMP DISPLAY rules:
	- "JUMLAH HARGA" / "TOTAL PRICE" / "GRAND TOTAL" = total transaction cost. \
	  This is NOT any of the three fields — ignore it entirely.
	- "JUMLAH DIKELUARKAN DALAM LITER" / "VOLUME" / "LITRES" = fuel amount → `amount`
	- "HARGA SATU LITER" / "HARGA/LITER" / "UNIT PRICE" / "PRICE/L" = per-unit price → `pricePerUnit`
	- Fuel pump displays NEVER contain odometer readings. \
	  Do NOT set `odometer` from a pump image under any circumstances.
	
	VEHICLE DASHBOARD rules:
	- "ODO" / "ODOMETER" / "MILEAGE" = vehicle odometer → `odometer`
	- Dashboards typically won't have `amount` or `pricePerUnit`.
	
	CURRENCY / NUMBER FORMAT:
	- Indonesian/Malaysian receipts use periods as thousand separators: \
	  "81.618" means 81618 and "12.200" means 12200. Return plain integers.
	- A comma may be a decimal separator: "6,69" means 6.69.
	
	Extract only numeric values. If a field cannot be confidently identified, return null. \
	Never guess.
	""")
		)
		
		let response = try await session.respond(
			to: "Extract the fuel log fields from this OCR scan:\n\n\(rawText)",
			generating: RefuelExtraction.self
		)
		
		return response.content
	}
}
