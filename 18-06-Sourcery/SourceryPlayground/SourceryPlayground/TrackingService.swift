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
    SettingsServiceEnvironmentProtocol,
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
    typealias EnvironmentProtocol = TrackingServiceEnvironmentProtocol

    private let env: AnyEnvironment
    private let database: DatabaseProtocol
    private let locationManager: LocationManagerProtocol
    // sourcery:end

    init(env: EnvironmentProtocol, withLimit limit: Int) {
        // sourcery:inline:TrackingService.Environment.Init
        self.database = env.database
        self.locationManager = env.locationManager
        self.env = env
        // sourcery:end
    }

    // sourcery:inline:TrackingService.Environment.ConvenienceInit
    convenience init(env: AnyEnvironment, withLimit limit: Int) throws {
        if let env = env as? EnvironmentProtocol {
            self.init(env: env, withLimit: limit)
        } else {
            throw EnvironmentError()
        }
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
class SettingsService {

    private enum Environment {
        case database(DatabaseProtocol)
    }

    // sourcery:inline:SettingsService.Environment.Properties
    typealias EnvironmentProtocol = SettingsServiceEnvironmentProtocol

    private let env: AnyEnvironment
    private let database: DatabaseProtocol
    // sourcery:end

    init(env: SettingsServiceEnvironmentProtocol) {
        // sourcery:inline:SettingsService.Environment.Init
        self.database = env.database
        self.env = env
        // sourcery:end
    }

    // sourcery:inline:SettingsService.Environment.ConvenienceInit
    convenience init(env: AnyEnvironment) throws {
        if let env = env as? EnvironmentProtocol {
            self.init(env: env)
        } else {
            throw EnvironmentError()
        }
    }
    // sourcery:end
}


// sourcery:inline:SettingsService.Environment.Protocol
protocol SettingsServiceEnvironmentProtocol: AnyEnvironment {
    var database: DatabaseProtocol { get }
}

struct SettingsServiceEnvironment: SettingsServiceEnvironmentProtocol {
    let database: DatabaseProtocol
}
// sourcery:end


// SAMLE SETUP

let env = GlobalEnvironment()
let trackingService = TrackingService(env: env, withLimit: 5)
let settingsService = SettingsService(env: env)
