//
//  BTResource.swift
//  mbi-app
//
//  Created by 埜原菽也 on H30/01/24.
//  Copyright © 平成30年 M.A. Eng. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: Service & Characteristic UUIDs
let ServiceUUID = CBUUID(string: "180F") // battery service
let CharacteristicUUID = CBUUID(string: "2A19") // battery level char

let BLENotifyBatteryLevel = NSNotification.Name("BLENotifyBatteryLevel")

class BTResource: NSObject {

  // MARK: - Properties
  // Bluetooth properties
  let notification = NotificationCenter.default // aliasing
  var peripheral: CBPeripheral?                 // peripheral instance
  var characteristic: CBCharacteristic?         // peripheral's characteristic

  // Timing handling to avoid message spam
  var txTimer: Timer?       // timer to avoid transmission spam
  var rxTimer: Timer?       // timeout for data RX
  var allowTX: Bool = true  // blocks transmission during timeout

  // Message system workaround for single-characteristic module
  var command: (String, Int?)?              // last command transmitted
  var command_queue: [(String, Int?)] = [] // next command to transmit
  var partial: String = ""                 // partial message received

  // MARK: - Constructors
  init(_ peripheral: CBPeripheral) {
    super.init()
    self.peripheral = peripheral
    self.peripheral?.delegate = self
    startDiscoveringServices()
  }

  // Force reset at deconstruction
  deinit { self.reset() }

  // MARK: - Connection
  func startDiscoveringServices() {
    self.peripheral?.discoverServices([])
  }

  func reset() {
    if let peripheral = self.peripheral, let characteristic = self.characteristic {
      peripheral.setNotifyValue(false, for: characteristic)
    }
    self.peripheral = nil
  }

  // MARK: - Data TX & RX
  func write(_ string: String, with arg: Int? = nil) {

    guard allowTX else {
      command_queue.append((string, arg))
      return
    }

    command = (string, arg)
    var tx = string
    if arg != nil { tx.append(String(arg!)) }

    if let characteristic = self.characteristic {
      if let data = tx.data(using: .ascii) {
//        print("Write to device: ", tx, " [", data, "]")
        self.peripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        startTimer()
      }
    }
  }

  // Resend command
  @objc func rewrite() {
    stopTimer()
  }

  // MARK: - Timers
  func startTimer(_ delay: Double = 2.0) {
    allowTX = false
    txTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(rewrite), userInfo: nil, repeats: false)
  }

  func stopTimer() {
    if txTimer == nil { return } // nothing to stop
    txTimer?.invalidate()
    txTimer = nil
    allowTX = true
  }
}

extension BTResource: CBPeripheralDelegate {

  // MARK: - Peripheral Delegate Functions
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if peripheral != self.peripheral { return }
    if error != nil { fatalError() }
    if peripheral.services == nil || peripheral.services!.count == 0 { return }

    for service in peripheral.services! {
      NSLog("Service found: \(service)")
      if service.uuid == ServiceUUID {
        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if (peripheral != self.peripheral) { return }
    if (error != nil) { return }

    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        NSLog("Characteristic found: \(characteristic)")
        if characteristic.uuid == CharacteristicUUID {
          self.characteristic = characteristic
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    guard error != nil else { return }

    NSLog("Update Notification changed for \(characteristic.uuid)")
  }

  //
  // didUpdateValueFor
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if peripheral != self.peripheral { return }
    if error != nil { return }
    if characteristic != self.characteristic { return }

    if let data = characteristic.value {
      switch characteristic.service.uuid.uuidString {
      case "180F": // battery
        let value: Int = data.withUnsafeBytes { $0.pointee }
        notifyBatteryLevel(value)
        print("Battery level updated: \(value) [\(characteristic.service.uuid)] [\(data)]")
      /*
      case "180D": // heart rate
        if data.count >= 1 {
          let flags: UInt8 = data.subdata(in: 0..<1).withUnsafeBytes { $0.pointee }
          print("HR Flags: \(String(flags, radix: 2)) [\(characteristic.service.uuid)] [\(data)]")
        }

        if data.count >= 2 {
          let measurement: UInt8 = data.subdata(in: 1..<2).withUnsafeBytes { $0.pointee }
          print("HR Measurement: \(measurement) [\(characteristic.service.uuid)] [\(data)]")
        }

        if data.count >= 3 {
          let energy: UInt8 = data.subdata(in: 2..<3).withUnsafeBytes { $0.pointee }
          let exponent: UInt8 = data.subdata(in: 3..<4).withUnsafeBytes { $0.pointee }
          print("EE value: \(energy)e\(exponent) kJ [\(characteristic.service.uuid)] [\(data)]")
        }
      */
      default:
        break
      }

    }

    stopTimer()
  }

  func notifyBatteryLevel(_ data: Int) {
    let info = [ "battery": String(data) ]
    notification.post(name: BLENotifyBatteryLevel, object: self, userInfo: info)
  }


}
