import SwiftData
import SwiftUI

@MainActor
class PreviewContainer {
	static let shared: ModelContainer = {
		do {
			let schema = Schema([Vehicle.self, Refuel.self])
			let config = ModelConfiguration(isStoredInMemoryOnly: true)
			let container = try ModelContainer(for: schema, configurations: [config])
			let context = container.mainContext
			
			func daysAgo(_ days: Int) -> Date {
				Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
			}
			
			let commuterPcx = Vehicle(
				name: "Commuter PCX",
				brand: "Honda",
				model: "PCX 160",
				year: 2024,
				tankCapacityLiter: 8.1,
				vehicleType: .motorcycle
			)
			
			let campusVario = Vehicle(
				name: "Campus Vario",
				brand: "Honda",
				model: "Vario 125",
				year: 2020,
				tankCapacityLiter: 5.5,
				vehicleType: .motorcycle
			)
			
			let cityBrio = Vehicle(
				name: "City Car",
				brand: "Honda",
				model: "Brio RS",
				year: 2021,
				tankCapacityLiter: 35.0,
				vehicleType: .car
			)
			
			let oldDieselToyota = Vehicle(
				name: "Family Hauler",
				brand: "Toyota",
				model: "Kijang Innova 2.5 G",
				year: 2007,
				tankCapacityLiter: 55.0,
				vehicleType: .car
			)
			
			context.insert(commuterPcx)
			context.insert(campusVario)
			context.insert(cityBrio)
			context.insert(oldDieselToyota)
			
			func generateHistory(
				for vehicle: Vehicle,
				startOdometer: Double,
				kmPerLiter: Double,
				avgLiters: Double,
				pricePerLiter: Double,
				fuelType: String,
				daysAgoList: [Int]
			) {
				var currentOdo = startOdometer
				
				for days in daysAgoList.sorted(by: >) {
					let variance = Double.random(in: -0.05...0.05)
					let rawLiters = avgLiters + (avgLiters * variance)
					let liters = (rawLiters * 10).rounded() / 10
					
					let refuel = Refuel(
						odometer: currentOdo,
						amount: liters,
						pricePerLiter: pricePerLiter,
						fuelType: fuelType,
						vehicle: vehicle
					)
					refuel.timestamp = daysAgo(days)
					context.insert(refuel)
					
					let distanceTraveled = liters * kmPerLiter
					currentOdo += distanceTraveled
				}
			}
			
			generateHistory(
				for: commuterPcx,
				startOdometer: 2000,
				kmPerLiter: 39.5,
				avgLiters: 6.0,
				pricePerLiter: 12950,
				fuelType: "Pertamax",
				daysAgoList: [89, 84, 80, 75, 71, 66, 62, 57, 53, 49, 44, 40, 35, 31, 26, 22, 18, 13, 9, 4, 1]
			)
			
			generateHistory(
				for: campusVario,
				startOdometer: 14500,
				kmPerLiter: 45.0,
				avgLiters: 4.2,
				pricePerLiter: 10000,
				fuelType: "Pertalite",
				daysAgoList: [88, 79, 70, 62, 53, 44, 35, 26, 17, 8, 2]
			)
			
			generateHistory(
				for: cityBrio,
				startOdometer: 30000,
				kmPerLiter: 12.5,
				avgLiters: 27.0,
				pricePerLiter: 12950,
				fuelType: "Pertamax",
				daysAgoList: [90, 83, 76, 69, 62, 55, 48, 41, 34, 27, 20, 13, 6]
			)
			
			generateHistory(
				for: oldDieselToyota,
				startOdometer: 248000,
				kmPerLiter: 10.0,
				avgLiters: 45.0,
				pricePerLiter: 6800,
				fuelType: "Biosolar",
				daysAgoList: [85, 70, 55, 35, 20, 5]
			)
			
			return container
		} catch {
			fatalError("Failed to create preview SwiftData container: \(error)")
		}
	}()
}
