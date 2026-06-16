//
//  NavigationRouter.swift
//  FuelLog
//
//  Created by Muhammad Akbar Reishandy on 13/06/26.
//

import SwiftUI

@Observable
class NavigationRouter {
	var path = NavigationPath()
	
	init(path: NavigationPath = NavigationPath()) {
		self.path = path
	}
	
	func navigate(to route: AppRoute) {
		path.append(route)
	}
	
	func popToRoot() {
		path.removeLast(path.count)
	}
}
