//
//  User.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

struct User: Decodable {
    private(set) var username: String?
    private(set) var name: String?
    private(set) var bio: String?
    private(set) var location: String?
}
