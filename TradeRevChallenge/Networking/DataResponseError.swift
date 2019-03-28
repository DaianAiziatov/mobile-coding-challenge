//
//  DataResponseError.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

enum DataResponseError: Error {
    case network
    case decoding
    case noAccessKey
    
    var reason: String {
        switch self {
        case .network:
            return "An error occurred while fetching data "
        case .decoding:
            return "An error occurred while decoding data"
        case .noAccessKey:
            return "Please add APIKey.plist file with access key"
        }
    }
}
