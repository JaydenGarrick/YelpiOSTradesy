//
//  YelpModels.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import Foundation

struct YelpTopLevelJSON: Codable {
    let businesses: [Business]
}

struct Business: Codable, Equatable {
    let name: String?
    let rating: Double?
    let phoneNumber: String?
    let imageURLString: String?
    let distance: Double?
    let displayPhone: String?
    let location: Location?
    let price: String?
        
    enum CodingKeys: String, CodingKey {
        case name
        case rating
        case phoneNumber = "phone"
        case imageURLString = "image_url"
        case distance
        case displayPhone = "display_phone"
        case location
        case price
    }
}

struct Location: Codable, Equatable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zipCode: String?
    let country: String?
    let state: String?
}
