//
//  main.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation
import Combine

final class BluetoothAvailabilityUnit: Unit {

    let link: UnitLink

    @Soft private(set) var isAvailable = false

    init(requirement: Requirement<BluetoothAvailabilityUnit>, link: UnitLink) {
        self.link = link
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("BluetoothAvailabilityUnit satisfied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isAvailable = true
            self.link.manager?.setNeedsUpdate()
        }
    }

    func requirementsSatisfactionLost() { }
}



final class UserTokenUnit: Unit {

    let link: UnitLink

    @Soft private(set) var isAvailable = true
    @Hard private(set) var userName: String

    init(requirement: Requirement<UserTokenUnit>, link: UnitLink) throws {
        self.link = link
        self.userName = try requirement.value(for: \.$userName)
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("UserTokenUnit satisfied")
    }

    func requirementsSatisfactionLost() { }
}



final class DeviceConnectionUnit: Unit {

    let link: UnitLink

    @Hard private(set) var deviceUUID: UUID
    @Soft private(set) var isConnected: Bool

    init(requirement: Requirement<DeviceConnectionUnit>, link: UnitLink) throws {
        self.link = link
        self.deviceUUID = try requirement.value(for: \.$deviceUUID)
        self.isConnected = true

        addRequirement(BluetoothAvailabilityUnit.requirement(where: \.$isAvailable, equals: true))
        addRequirement(UserTokenUnit.requirement(where: \.$userName, equals: "Hello"))
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("DeviceConnectionUnit satisfied")
    }

    func requirementsSatisfactionLost() { }

    func sendMessage(rawMessage: String) {
        print(rawMessage)
        Program.shared.end()
    }
}



final class DeviceScannerUnit: Unit {

    let link: UnitLink

    @Published private(set) var foundDeviceUUIDs = [UUID]()

    init(requirement: Requirement<DeviceScannerUnit>, link: UnitLink) throws {
        self.link = link
        addRequirement(BluetoothAvailabilityUnit.requirement(where: \.$isAvailable, equals: true))
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("DeviceScannerUnit satisfied")
        foundDeviceUUIDs.append(UUID())
    }

    func requirementsSatisfactionLost() { }
}



final class SendMessage: Unit {
    struct Message: Hashable {
        let deviceUUID: UUID
        let userName: String
        let content: String
    }

    let link: UnitLink

    @Hard private(set) var message: Message

    lazy var connectedDevice = DeviceConnectionUnit
        .requirement(where: \.$deviceUUID, equals: message.deviceUUID)
        .and(where: \.$isConnected, equals: true)

    init(requirement: Requirement<SendMessage>, link: UnitLink) throws {
        self.link = link
        self.message = try requirement.value(for: \.$message)
        addRequirement(connectedDevice)
    }

    deinit {
        
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        print("SendMessage satisfied")
        let connectedDeviceUnit = resolvedUnits[connectedDevice]
        connectedDeviceUnit.sendMessage(rawMessage: message.content)
    }

    func requirementsSatisfactionLost() { }
}


class Program {
    var cancellables = Set<AnyCancellable>()
    var deviceScannerUnit: DeviceScannerUnit?
    var sendMessageUnit: SendMessage?

    static let shared = Program()

    func main() {
        let unitManager = UnitManager()
        unitManager.register(UserTokenUnit.self)
        unitManager.register(BluetoothAvailabilityUnit.self)
        unitManager.register(DeviceConnectionUnit.self)
        unitManager.register(DeviceScannerUnit.self)
        unitManager.register(SendMessage.self)

        let deviceScannerUnit = unitManager.resolve(DeviceScannerUnit.self)
        deviceScannerUnit.$foundDeviceUUIDs.sink { (foundDeviceUUIDs) in
            self.deviceScannerUnit = nil
            if let deviceUUID = foundDeviceUUIDs.first {
                let message = SendMessage.Message(
                    deviceUUID: deviceUUID,
                    userName: "karsten@bruns.me",
                    content: "Hello, World!"
                )

                unitManager.resolve(SendMessage.requirement(where: \.$message, equals: message))
            }
        }.store(in: &cancellables)

        self.deviceScannerUnit = deviceScannerUnit
    }

    func end(){
        deviceScannerUnit = nil
        OperationQueue.main.addOperation {
            exit(0)
        }
    }
}


Program.shared.main()
RunLoop.main.run()
