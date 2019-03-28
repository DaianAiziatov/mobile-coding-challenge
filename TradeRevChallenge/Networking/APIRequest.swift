//
//  APIRequest.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

struct APIRequest {
    // Past your access key here or add APIKeys.plist file into root project folder
    static var clientID: String? {
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
            let dictRoot = NSDictionary(contentsOfFile: path) {
            return dictRoot["Access_Key"] as? String
        } else {
            return nil
        }
    }
    static let photosPath = "photos/"

    static let photoPerPage = 30
}
