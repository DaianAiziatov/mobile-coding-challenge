//
//  Photo.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

struct Photo: Decodable {

    private(set) var id: String
    private(set) var description: String?
    private(set) var alternativedesription: String?
    private(set) var width: Int?
    private(set) var height: Int?
    private(set) var color: String?
    private(set) var likes: Int = 0
    private(set) var urls: Urls?
    private(set) var user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case alternativedesription = "alt_description"
        case width
        case height
        case color
        case likes
        case urls
        case user
    }
}
