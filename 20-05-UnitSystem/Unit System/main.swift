//
//  main.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation

final class BluetoothAvailabilityUnit: Unit {

    @Output private(set) var isAvailable = true

    init(requirement: Requirement) {
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("BluetoothAvailabilityUnit satisfied")
    }

    func requirementsSatisfactionLost() { }
}



final class UserTokenUnit: Unit {

    @Output private(set) var isAvailable = true
    @Id private(set) var userName: String

    init(requirement: Requirement) throws {
        self.userName = try requirement.get(\UserTokenUnit.$userName)
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("UserTokenUnit satisfied")
    }

    func requirementsSatisfactionLost() { }
}



final class DeviceConnectionUnit: Unit {

    @Id private(set) var deviceUUID: UUID
    @Output private(set) var isConnected: Bool

    init(requirement: Requirement) throws {
        self.deviceUUID = try requirement.get(\DeviceConnectionUnit.$deviceUUID)
        self.isConnected = true
    }

    func requirements() -> [Requirement] {
        [
            BluetoothAvailabilityUnit.required(where: \.$isAvailable, equals: true),
            UserTokenUnit.required(where: \.$userName, equals: "Hello")
        ]
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("DeviceConnectionUnit satisfied")
    }

    func requirementsSatisfactionLost() { }

    func sendMessage(rawMessage: String) {
        print(rawMessage)
    }
}



final class DeviceScannerUnit: Unit {

    private(set) var foundDeviceUUIDs = [UUID]()

    func requirements() -> [Requirement] {
        [BluetoothAvailabilityUnit.required(where: \.$isAvailable, equals: true)]
    }

    init(requirement: Requirement) throws {
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("DeviceScannerUnit satisfied")
        foundDeviceUUIDs = [UUID()]
    }

    func requirementsSatisfactionLost() { }
}



final class SendMessage: Unit {
    struct Message: Hashable {
        let deviceUUID: UUID
        let userName: String
        let content: String
    }

    @Id private(set) var message: Message

    lazy var connectedDevice = DeviceConnectionUnit.required(where: \.$deviceUUID, equals: message.deviceUUID)
        .and(where: \DeviceConnectionUnit.$isConnected, equals: true)

    init(requirement: Requirement) throws {
        self.message = try requirement.get(\SendMessage.$message)
    }

    func requirements() -> [Requirement] {
        [connectedDevice]
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("SendMessage satisfied")
        let connectedDeviceUnit: DeviceConnectionUnit = resolvedUnits[connectedDevice]
        connectedDeviceUnit.sendMessage(rawMessage: message.content)
    }

    func requirementsSatisfactionLost() { }
}



let units = UnitRegistry()
units.register(UserTokenUnit.self)
units.register(BluetoothAvailabilityUnit.self)
units.register(DeviceConnectionUnit.self)
units.register(DeviceScannerUnit.self)
units.register(SendMessage.self)


let deviceScannerUnit = units.dequeue(DeviceScannerUnit.self)

if let deviceUUID = deviceScannerUnit.foundDeviceUUIDs.first {
    let message = SendMessage.Message(
        deviceUUID: deviceUUID,
        userName: "karsten@bruns.me",
        content: "Hello, World!"
    )

    _ = units.dequeue(SendMessage.self, for: SendMessage.required(where: \.$message, equals: message))
    // SendMessage.dequeue(from: units, where: \.$message, equals: message)
}
