//
//  BleUpdates.swift
//  SmartOBD2
//
//  Created by kemo konteh on 8/6/23.
//

import Foundation
import CoreBluetooth

extension BluetoothViewModel {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }
        switch characteristic.uuid.uuidString {
        case "FFE1":
            guard let response = characteristic.value else {
                return
            }
            guard let responseString = String(data: response, encoding: .utf8)?.replacingOccurrences(of: " ", with: "") else {
                print("Invalid data format")
                return
            }
            elm?.parseResponse(response: responseString)
            
        case "F000FFC1-0451-4000-B000-000000000000":
            if let response = characteristic.value {
                guard let responseString = String(data: response, encoding: .utf8) else {
                    print("Invalid data format")
                    return
                }
                print("Manufacturer: \(responseString))")
            }
        case "2A24":
            if let response = characteristic.value {
                guard let responseString = String(data: response, encoding: .utf8) else {
                    print("Invalid data format")
                    return
                }
                print("Manufacturer: \(responseString))")
            }
        case "2A26":
            if let response = characteristic.value {
                guard let responseString = String(data: response, encoding: .utf8) else {
                    print("Invalid data format")
                    return
                }
                print("Manufacturer: \(responseString))")
            }
            
        default:
            print("Unknown characteristic")
        }
    }
}