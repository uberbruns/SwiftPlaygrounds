//
//  UnitProperty.swift
//  Unit System
//
//  Created by Karsten Bruns on 17.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol UnitProperty: AnyObject {
    associatedtype Value: Equatable
    var wrappedValue: Value { get }
}
