//
//  Logging.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import Foundation
import os

protocol Loggable {
    func logEvent(_ event: String)
}

struct Logger: Loggable {
    func logEvent(_ event: String) {
        #if DEBUG
        print("Event: \(event)")
        #endif
        os_log("Event: %@", event)
    }
}
