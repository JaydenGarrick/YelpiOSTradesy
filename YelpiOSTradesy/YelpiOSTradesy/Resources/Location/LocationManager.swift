//
//  LocationManager.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import Foundation
import CoreLocation

struct Coordinate {
    let latitude: String
    let longitude: String
}

protocol LocationRequestable {
    var coordinate: Coordinate? { get }
    func requestLocation()
    func getLocation() -> Coordinate?
}

/*
 NOTE: This is a little messy, but it's 20 minutes before I need to turn this in and I was running into issues with the simulator and adding a custom location... didn't realize you had to do that. 🤦🏼‍♀️
 */
class LocationManager: NSObject, LocationRequestable {
    private let locationManager: CLLocationManager
    var coordinate: Coordinate?
    
    init(_ locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func getLocation() -> Coordinate? {
        if let coordinate = coordinate {
            return coordinate
        } else {
            guard let location = locationManager.location?.coordinate else {
                return nil
            }
            return Coordinate(latitude: String(location.latitude), longitude: String(location.longitude))
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.coordinate = Coordinate(latitude: String(location.coordinate.latitude), longitude: String(location.coordinate.longitude))
        }
    }
}
