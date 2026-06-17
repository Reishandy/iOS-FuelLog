//
//  Task.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 17/06/26.
//

import SwiftUI

struct VisionTask: Identifiable, Sendable {
	let id: UUID
	let imageData: Data
}

struct VisionResult: Identifiable, Sendable {
	let id: UUID
	// TODO: The vision type
}

struct QueueEvent: Sendable {
	let pendingCount: Int
	let completedTask: VisionResult?
}
