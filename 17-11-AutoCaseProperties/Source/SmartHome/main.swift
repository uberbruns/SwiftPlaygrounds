//
//  main.swift
//  SmartHome
//
//  Created by Karsten Bruns on 28.11.17.
//  Copyright © 2017 Karsten Bruns. All rights reserved.
//

import Foundation

protocol AutoCaseProperties { }

enum Connection: AutoCaseProperties {
    case wired
    case bluetooth(visibility: BluetoothVisibility)
}

enum BluetoothVisibility: AutoCaseProperties {
    
    enum State: AutoCaseProperties {
        case connected
        case disconnected
    }

    case visible(state: State, rssi: Int)
    case notVisible
}

enum Device: AutoCaseProperties {

    enum PowerSwitchState: AutoCaseProperties {
        case off
        case on
    }

    enum LightState: AutoCaseProperties {
        case off
        case on(brightness: Double)
    }

    case powerSwitch(state: PowerSwitchState, connection: Connection)
    case light(state: LightState, connection: Connection)
    case shades(connection: Connection)
    case thermostat(connection: Connection)
}

enum BluetoothSupport: AutoCaseProperties {
    case notSupported
    case supported(signal: Int)
}


let device = Device.light(state: .on(brightness: 0.5), connection: .bluetooth(visibility: .visible(state: .disconnected, rssi: -20)))

// Simple Example

if case .light(state: .on(let brightness), connection: _) = device {
    print("Light is on at \(brightness)")
}

if case .light(.on(let brightness), _) = device {
    print("Light is on at \(brightness)")
}

if let brightness = device.light?.state.on?.brightness {
    print("Light is on at \(brightness)")
}



// Less Simple Example

// Pattern matching with and without labels:
//
// + Allows matching and assigning multiple values
// - Too verbose or not verbose enough
// - Breaks when you add, remove or change associated values
// - Nested

if case .light(state: _, connection: .bluetooth(visibility: .visible(state: _, rssi: (-60)...))) = device {
    print("something")
}

if case .light(_, .bluetooth(.visible(_, (-60)...))) = device {
    print("something")
}

// Optional chaining using auto generated accessors
//
// + More readable
// + No nesting
// + Does not break if you add, remove or change associated values
// - You can only read one value, no powerful pattern matching

if let rssi = device.light?.connection.bluetooth?.visibility.visible?.rssi, rssi >= -60  {
    print("something")
}

