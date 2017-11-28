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

if let brightness = device.light?.state.on?.brightness {
    print("Light is on at \(brightness)")
}

if case .light(state: .on(let brightness), connection: _) = device {
    print("Light is on at \(brightness)")
}

if case .light(.on(let brightness), _) = device {
    print("Light is on at \(brightness)")
}


// Less Simple Example

if let rssi = device.light?.connection.bluetooth?.visibility.visible?.rssi, rssi > -60  {
    print("Light signal present")
}

if case .light(state: _, connection: .bluetooth(visibility: .visible(state: _, rssi: (-60)...))) = device {
    print("Light signal present")
}

if case .light(_, .bluetooth(.visible(_, (-60)...))) = device {
    print("Light signal present")
}
