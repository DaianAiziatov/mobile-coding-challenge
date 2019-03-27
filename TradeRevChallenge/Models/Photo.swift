//
//  Photo.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

struct Photo: Decodable {

    private(set) var description: String?
    private(set) var alternativeDesription: String?
    private(set) var color: String?
    private(set) var likes: Int = 0
    private(set) var urls: Urls?
    private(set) var user: User?

    enum CodingKeys: String, CodingKey {
        case description
        case alternativeDesription = "alt_description"
        case color
        case likes
        case urls
        case user
    }
}
