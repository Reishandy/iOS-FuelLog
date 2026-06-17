//
//  VisionExtractService.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 17/06/26.
//

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
	
	nonisolated private func process(_ task: VisionTask) async -> VisionResult {
		do {
			try Task.checkCancellation()
			
			// TODO: Vision processing
			try await Task.sleep(for: .seconds(1))
			
			await Task.yield()
			
			return VisionResult(id: task.id)
		} catch is CancellationError {
			return VisionResult(id: task.id)
		} catch {
			return VisionResult(id: task.id)
		}
	}
}
