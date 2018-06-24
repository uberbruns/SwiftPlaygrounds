//
//  CompanyService.swift
//  Neptune
//
//  Created by Karsten Bruns on 23.06.18.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import Foundation



// SAMPLE DEPENDENCIES

protocol DatabaseProtocol { }

class Database: DatabaseProtocol { }

protocol LocationManagerProtocol { }

class LocationManager: LocationManagerProtocol { }



// GLOBALE ENVIRONMENT

// sourcery:inline:Setup.Environment
protocol AnyEnvironment { }

struct EnvironmentError: Error { }
// sourcery:end

struct GlobalEnvironment:
    // sourcery:inline:Global.Environment
    AnyEnvironment,
    SettingServiceEnvironmentProtocol,
    TrackingServiceEnvironmentProtocol {
    // sourcery:end
    var database: DatabaseProtocol = Database()
    var locationManager: LocationManagerProtocol = LocationManager()
}



// SAMLE SERVICES

// sourcery:environment
class TrackingService {

    private enum Environment {
        case database(DatabaseProtocol)
        case locationManager(LocationManagerProtocol)
    }

    // sourcery:inline:TrackingService.Environment.Properties
    private let env: AnyEnvironment
    private let database: DatabaseProtocol
    private let locationManager: LocationManagerProtocol
    // sourcery:end

    // sourcery:inline:TrackingService.Environment.Init
    init(env: AnyEnvironment) throws {
        if let env = env as? TrackingServiceEnvironmentProtocol {
            self.database = env.database
            self.locationManager = env.locationManager
        } else {
            throw EnvironmentError()
        }
        self.env = env
    }

    init(env: TrackingServiceEnvironmentProtocol) {
        self.database = env.database
        self.locationManager = env.locationManager
        self.env = env
    }
    // sourcery:end
}

// sourcery:inline:TrackingService.Environment.Protocol
protocol TrackingServiceEnvironmentProtocol: AnyEnvironment {
    var database: DatabaseProtocol { get }
    var locationManager: LocationManagerProtocol { get }
}

struct TrackingServiceEnvironment: TrackingServiceEnvironmentProtocol {
    let database: DatabaseProtocol
    let locationManager: LocationManagerProtocol
}
// sourcery:end

// sourcery:environment
class SettingService {

    private enum Environment {
        case database(DatabaseProtocol)
    }

    // sourcery:inline:SettingService.Environment.Properties
    private let env: AnyEnvironment
    private let database: DatabaseProtocol
    // sourcery:end

    // sourcery:inline:SettingService.Environment.Init
    init(env: AnyEnvironment) throws {
        if let env = env as? SettingServiceEnvironmentProtocol {
            self.database = env.database
        } else {
            throw EnvironmentError()
        }
        self.env = env
    }

    init(env: SettingServiceEnvironmentProtocol) {
        self.database = env.database
        self.env = env
    }
    // sourcery:end
}


// sourcery:inline:SettingService.Environment.Protocol
protocol SettingServiceEnvironmentProtocol: AnyEnvironment {
    var database: DatabaseProtocol { get }
}

struct SettingServiceEnvironment: SettingServiceEnvironmentProtocol {
    let database: DatabaseProtocol
}
// sourcery:end


// SAMLE SETUP

let env = GlobalEnvironment()
let trackingService = TrackingService(env: env)
let settingService = SettingService(env: env)
