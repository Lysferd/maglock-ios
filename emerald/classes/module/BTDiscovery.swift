//
//  BTDiscovery.swift
//  mbi-app
//
//  Created by 埜原菽也 on H30/01/24.
//  Copyright © 平成30年 M.A. Eng. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: Shared Instance
//let btDiscoverySharedInstance = BTDiscovery()

let BLENotifyConnected = NSNotification.Name("BLENotifyConnected")

class BTDiscovery: NSObject {

  // MARK: - Private Variables
  fileprivate let notification = NotificationCenter.default
  fileprivate let ServiceUUID = CBUUID(string: "180F")

  var queue: DispatchQueue!
  var centralManager: CBCentralManager!
  var peripherals: [CBPeripheral] = []
  var datasource: ResourcesDatasource?

  // MARK: - Initialization
  override init() {
    super.init()

    queue = DispatchQueue(label: "eng.moritzalmeida")
    centralManager = CBCentralManager(delegate: self, queue: queue)
  }

  deinit { disconnect() }

  // MARK: - Scanning
  func startScanning() {
    if centralManager.state != .poweredOn { return }
    if centralManager.isScanning { return }
    centralManager.scanForPeripherals(withServices: [ServiceUUID])
  }

  func stopScanning() {
    centralManager.stopScan()
  }

  func disconnect() {
    for peripheral in peripherals {
      centralManager.cancelPeripheralConnection(peripheral)
    }

    clearDevices()
  }

  private func clearDevices() {
    //datasource.clear
    peripherals = []
  }

}

extension BTDiscovery: CBCentralManagerDelegate {

  /*
  // BT Central Manager delegations
  // BT Discovery
  */
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

    if peripheral.name == nil || peripheral.name == "" { return }
    print("Found device: \(peripheral.name ?? "NIL") [\(peripheral.identifier)]")

    if peripherals.firstIndex(of: peripheral) == nil {
      peripherals.append(peripheral)
      central.connect(peripheral, options: nil)

      print("Attempting connection with \(peripheral.name ?? "NIL")")
    }
  }

  // BT Connection
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    datasource?.add(BTResource(peripheral))
    notify_connected()

    print("Connected to \(peripheral.name ?? "NIL")")
  }

  // BT Disconnection
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if error != nil { return }

    if let index = peripherals.firstIndex(of: peripheral) {
      peripherals.remove(at: index)
      datasource?.remove(index)

      NSLog("Disconnected from \(peripheral.name ?? "NIL")")
    }
  }

  /*
  // State change handler
  // Actually does nothing?
  */
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch (central.state) {
    case .poweredOff:
      print("Bluetooth state is POWERED OFF")
      self.clearDevices()

    case .unauthorized:
      print("Bluetooth state is UNAUTHORIZED")
      // Indicate to user that the iOS device does not support BLE.
      break

    case .unknown:
      print("Bluetooth state is UNKNOWN")
      // Wait for another event
      break

    case .poweredOn:
      print("Bluetooth state is POWERED ON")
      self.startScanning()

    case .resetting:
      print("Bluetooth state is RESETTING")
      self.clearDevices()

    case .unsupported:
      print("Bluetooth state is UNSUPPORTED")
      break
    }
  }

  func notify_connected() {
    notification.post(name: BLENotifyConnected, object: self)
  }

}

