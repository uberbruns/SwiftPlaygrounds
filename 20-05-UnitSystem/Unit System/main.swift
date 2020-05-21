//
//  main.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation

final class BluetoothAvailabilityUnit: Unit {

    let control: UnitControl

    @Output private(set) var isAvailable = true

    init(requirement: Requirement<BluetoothAvailabilityUnit>, control: UnitControl) {
        self.control = control
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("BluetoothAvailabilityUnit satisfied")
    }

    func requirementsSatisfactionLost() { }
}



final class UserTokenUnit: Unit {

    let control: UnitControl

    @Output private(set) var isAvailable = true
    @Id private(set) var userName: String

    init(requirement: Requirement<UserTokenUnit>, control: UnitControl) throws {
        self.userName = try requirement.value(for: \.$userName)
        self.control = control
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("UserTokenUnit satisfied")
    }

    func requirementsSatisfactionLost() { }
}



final class DeviceConnectionUnit: Unit {

    let control: UnitControl

    @Id private(set) var deviceUUID: UUID
    @Output private(set) var isConnected: Bool

    init(requirement: Requirement<DeviceConnectionUnit>, control: UnitControl) throws {
        self.deviceUUID = try requirement.value(for: \.$deviceUUID)
        self.isConnected = true
        self.control = control

        addRequirement(BluetoothAvailabilityUnit.requirement(where: \.$isAvailable, equals: true))
        addRequirement(UserTokenUnit.requirement(where: \.$userName, equals: "Hello"))
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

    let control: UnitControl

    private(set) var foundDeviceUUIDs = [UUID]()

    init(requirement: Requirement<DeviceScannerUnit>, control: UnitControl) throws {
        self.control = control
        addRequirement(BluetoothAvailabilityUnit.requirement(where: \.$isAvailable, equals: true))
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

    let control: UnitControl

    @Id private(set) var message: Message

    lazy var connectedDevice = DeviceConnectionUnit
        .requirement(where: \.$deviceUUID, equals: message.deviceUUID)
        .and(where: \.$isConnected, equals: true)

    init(requirement: Requirement<SendMessage>, control: UnitControl) throws {
        message = try requirement.value(for: \.$message)
        self.control = control
        addRequirement(connectedDevice)
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("SendMessage satisfied")
        let connectedDeviceUnit: DeviceConnectionUnit = resolvedUnits[connectedDevice]
        connectedDeviceUnit.sendMessage(rawMessage: message.content)
    }

    func requirementsSatisfactionLost() { }
}



let unitManager = UnitManager()
unitManager.register(UserTokenUnit.self)
unitManager.register(BluetoothAvailabilityUnit.self)
unitManager.register(DeviceConnectionUnit.self)
unitManager.register(DeviceScannerUnit.self)
unitManager.register(SendMessage.self)


let deviceScannerUnit = unitManager.resolve(DeviceScannerUnit.self)

if let deviceUUID = deviceScannerUnit.foundDeviceUUIDs.first {
    let message = SendMessage.Message(
        deviceUUID: deviceUUID,
        userName: "karsten@bruns.me",
        content: "Hello, World!"
    )

    _ = unitManager.resolve(SendMessage.requirement(where: \.$message, equals: message))
    // SendMessage.dequeue(from: unitManager, where: \.$message, equals: message)
}

