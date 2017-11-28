// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension BluetoothSupport {

	struct Supported {
		let signal: Int
	}

	var isNotSupported: Bool {
		if case .notSupported = self {
			return true
		} else {
			return false
		}
	}

	var isSupported: Bool {
		if case .supported = self {
			return true
		} else {
			return false
		}
	}

	var supported: Supported? {
		switch self {
		case .supported(let signal):
			return Supported(signal: signal)
		default:
			return nil
		}
	}
}


extension BluetoothVisibility {

	struct Visible {
		let state: State
		let rssi: Int
	}

	var isVisible: Bool {
		if case .visible = self {
			return true
		} else {
			return false
		}
	}

	var visible: Visible? {
		switch self {
		case .visible(let state, let rssi):
			return Visible(state: state, rssi: rssi)
		default:
			return nil
		}
	}

	var isNotVisible: Bool {
		if case .notVisible = self {
			return true
		} else {
			return false
		}
	}
}


extension BluetoothVisibility.State {

	var isConnected: Bool {
		if case .connected = self {
			return true
		} else {
			return false
		}
	}

	var isDisconnected: Bool {
		if case .disconnected = self {
			return true
		} else {
			return false
		}
	}
}


extension Connection {

	struct Bluetooth {
		let visibility: BluetoothVisibility
	}

	var isWired: Bool {
		if case .wired = self {
			return true
		} else {
			return false
		}
	}

	var isBluetooth: Bool {
		if case .bluetooth = self {
			return true
		} else {
			return false
		}
	}

	var bluetooth: Bluetooth? {
		switch self {
		case .bluetooth(let visibility):
			return Bluetooth(visibility: visibility)
		default:
			return nil
		}
	}
}


extension Device {

	struct PowerSwitch {
		let state: PowerSwitchState
		let connection: Connection
	}

	struct Light {
		let state: LightState
		let connection: Connection
	}

	struct Shades {
		let connection: Connection
	}

	struct Thermostat {
		let connection: Connection
	}

	var isPowerSwitch: Bool {
		if case .powerSwitch = self {
			return true
		} else {
			return false
		}
	}

	var powerSwitch: PowerSwitch? {
		switch self {
		case .powerSwitch(let state, let connection):
			return PowerSwitch(state: state, connection: connection)
		default:
			return nil
		}
	}

	var isLight: Bool {
		if case .light = self {
			return true
		} else {
			return false
		}
	}

	var light: Light? {
		switch self {
		case .light(let state, let connection):
			return Light(state: state, connection: connection)
		default:
			return nil
		}
	}

	var isShades: Bool {
		if case .shades = self {
			return true
		} else {
			return false
		}
	}

	var shades: Shades? {
		switch self {
		case .shades(let connection):
			return Shades(connection: connection)
		default:
			return nil
		}
	}

	var isThermostat: Bool {
		if case .thermostat = self {
			return true
		} else {
			return false
		}
	}

	var thermostat: Thermostat? {
		switch self {
		case .thermostat(let connection):
			return Thermostat(connection: connection)
		default:
			return nil
		}
	}
}


extension Device.LightState {

	struct On {
		let brightness: Double
	}

	var isOff: Bool {
		if case .off = self {
			return true
		} else {
			return false
		}
	}

	var isOn: Bool {
		if case .on = self {
			return true
		} else {
			return false
		}
	}

	var on: On? {
		switch self {
		case .on(let brightness):
			return On(brightness: brightness)
		default:
			return nil
		}
	}
}


extension Device.PowerSwitchState {

	var isOff: Bool {
		if case .off = self {
			return true
		} else {
			return false
		}
	}

	var isOn: Bool {
		if case .on = self {
			return true
		} else {
			return false
		}
	}
}


