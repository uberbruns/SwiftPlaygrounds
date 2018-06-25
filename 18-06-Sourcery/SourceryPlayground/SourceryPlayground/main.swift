//
//  main.swift
//  SourceryPlayground
//
//  Created by Karsten Bruns on 24.06.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation




let env = GlobalEnvironment()
let trackingService = TrackingService(env: env, withLimit: 5)
