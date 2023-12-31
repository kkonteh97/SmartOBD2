//
//  LiveDataViewModel.swift
//  SMARTOBD2
//
//  Created by kemo konteh on 10/5/23.
//

import Combine
import SwiftUI

struct PIDMeasurement: Identifiable, Comparable, Hashable, Codable {
    static func < (lhs: PIDMeasurement, rhs: PIDMeasurement) -> Bool {
        lhs.id < rhs.id
    }

    let id: Date
    let value: Double

    init(time: Date, value: Double) {
           self.value = value
            self.id = time
       }
}

class DataItem: Identifiable, Codable {
    let command: OBDCommand
    var value: Double
    var unit: String?
    var selectedGauge: GaugeType?
    var measurements: [PIDMeasurement]

    init(command: OBDCommand,
         value: Double = 0,
         unit: String? = nil,
         selectedGauge: GaugeType? = nil,
         measurements: [PIDMeasurement] = []
    ) {
        self.command = command
        self.value = value
        self.unit = unit
        self.selectedGauge = selectedGauge
        self.measurements = measurements
    }
}

class LiveDataViewModel: ObservableObject {
    let obdService: OBDService
    let garage: Garage

    private var cancellables = Set<AnyCancellable>()

    @Published var currentVehicle: Vehicle?

    @Published var isRequestingPids = false

    @Published var data: [OBDCommand : DataItem] = [:]
    @Published var order: [OBDCommand] = []
    @Published var connectionState: ConnectionState = .notConnected


    private var timer: Timer?
    private var appendMeasurementsTimer: DispatchSourceTimer?
    private let measurementTimeLimit: TimeInterval = 120

    init(_ obdService: OBDService, _ garage: Garage) {
        self.obdService = obdService
        self.garage = garage

        obdService.$connectionState
            .sink { [weak self] state in
                self?.connectionState = state
            }
            .store(in: &cancellables)

        garage.$currentVehicle
            .sink { currentVehicle in
                self.currentVehicle = currentVehicle
            }
            .store(in: &cancellables)

        if let piddata = UserDefaults.standard.data(forKey: "pidData"),
           let pidData = try? JSONDecoder().decode([DataItem].self, from: piddata) {
            for item in pidData {
                self.data[item.command] = item
                self.order.append(item.command)
            }
        } else {
            // default pids SPEED and RPM
            data[.mode1(.rpm)] = DataItem(command: .mode1(.rpm), selectedGauge: .gaugeType1)
            data[.mode1(.speed)] = DataItem(command: .mode1(.speed), selectedGauge: .gaugeType2)
            order.append(.mode1(.rpm))
            order.append(.mode1(.speed))
        }
    }

    func saveDataItems() {
        print("saving data items")
        if let encodedData = try? JSONEncoder().encode(Array(data.values)) {
            UserDefaults.standard.set(encodedData, forKey: "pidData")
        }
    }

    func addPIDToRequest(_ pid: OBDCommand) {
        guard order.count < 6 else { return }
        if !data.keys.contains(pid) {
            data[pid] = DataItem(command: pid, selectedGauge: .gaugeType1)
            order.append(pid)
        } else {
            data.removeValue(forKey: pid)
            if let index = order.firstIndex(of: pid) {
                order.remove(at: index)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        stopTimer()
        appendMeasurementsTimer?.cancel()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01,
                                     repeats: true) { [weak self] _ in
            self?.startRequestingPIDs()
        }
        startAppendMeasurementsTimer()
    }

    func controlRequestingPIDs(status: Bool) {
        if status {
            guard timer == nil else { return }
            startTimer()
        } else {
            stopTimer()
            appendMeasurementsTimer?.cancel()
            isRequestingPids = false
        }
    }

    func startAppendMeasurementsTimer() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.appendMeasurements()
        }
        timer.resume()
        appendMeasurementsTimer = timer
    }

    func appendMeasurements() {
        DispatchQueue.main.async {
              for (_, item) in self.data {
                  item.measurements.append(PIDMeasurement(time: Date(), value: item.value))
                  item.measurements = item.measurements.filter { $0.id.timeIntervalSinceNow > -self.measurementTimeLimit }
            }
        }
    }

    func startRequestingPIDs() {
        guard !isRequestingPids else {
            return
        }
        isRequestingPids = true
        Task {
            do {
                let messages = try await obdService.elm327.requestPIDs(order)
                updateDataItems(messages: messages, keys: order)
            } catch {
                print(error)
            }
        }
    }

    private func updateDataItems(messages: [Message], keys: [OBDCommand]) {
        guard !messages.isEmpty else {
                return
        }
        guard let data = messages[0].data else {
            return
        }
        DispatchQueue.main.async {
            var res = BatchedResponse(response: data)
            keys.forEach { cmd in
                guard let value = res.getValueForCommand(cmd) else {
                    return
                }
                    // Update the data directly
                if let existingItem = self.data[cmd],
                   let newValue = decodeToMeasurement(value) {
                    existingItem.value = newValue.value
                    existingItem.unit = newValue.unit.symbol
                }
            }
            self.isRequestingPids = false
        }
    }
}

func decodeMeasurementToBindingDouble(_ measurement: OBDDecodeResult?) -> Binding<Double> {
    guard let measurement = measurement else {
        return .constant(0)
    }
    switch measurement {
    case .stringResult(let value):
        return .constant(Double(value) ?? 0)
    case .measurementResult(let value):
        return .constant(value.value)
    case .noResult:
        return .constant(0)
    default:
        return .constant(0)
    }
}

func decodeToMeasurement(_ result: OBDDecodeResult) -> Measurement<Unit>? {
    switch result {
    case .measurementResult(let value):
        return value
    default:
        return Measurement(value: 0, unit: UnitSpeed.kilometersPerHour)
    }
}

func decodeMeasurementToDouble(_ measurement: OBDDecodeResult?) -> Double {
    guard let measurement = measurement else {
        return 0
    }
    switch measurement {
    case .stringResult(let value):
        return Double(value) ?? 0
    case .measurementResult(let value):
        return value.value
    default:
        return 0
    }
}

func decodeMeasurementToString(_ measurement: OBDDecodeResult?) -> String {
    guard let measurement = measurement else {
        return "N/A"
    }
    switch measurement {
    case .stringResult(let value):
        return value
    case .measurementResult(let value):
        return "\(value.value) \(value.unit.symbol)"
    case .noResult:
        return "No Result"
    default:
        return "No Result"
    }
}
