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

struct GlobalEnvironment:
    // sourcery:inline:Main.Environment
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
    private let database: DatabaseProtocol
    private let locationManager: LocationManagerProtocol
    // sourcery:end

    init(env: TrackingServiceEnvironmentProtocol) {
        // sourcery:inline:TrackingService.Environment.Init
        self.database = env.database
        self.locationManager = env.locationManager
        // sourcery:end
    }
}

// sourcery:inline:TrackingService.Environment.Protocol
protocol TrackingServiceEnvironmentProtocol {
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
    private let database: DatabaseProtocol
    // sourcery:end

    init(env: SettingServiceEnvironmentProtocol) {
        // sourcery:inline:SettingService.Environment.Init
        self.database = env.database
        // sourcery:end
    }
}


// sourcery:inline:SettingService.Environment.Protocol
protocol SettingServiceEnvironmentProtocol {
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
