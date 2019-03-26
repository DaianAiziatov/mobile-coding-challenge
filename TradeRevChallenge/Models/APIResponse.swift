//
//  APIResponse.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

struct APIResponse {
    private(set) var photos: [Photo]
    private(set) var totalPhotos: Int
    private(set) var page: Int
    private(set) var photosPerPage: Int
    private(set) lazy var totalPages: Int = {
        if totalPhotos % photosPerPage == 0 {
            return totalPhotos / photosPerPage
        } else {
            return (totalPhotos / photosPerPage) + 1
        }
    }()

    init(photos: [Photo], totalPhotos: Int, page: Int, photosPerPage: Int) {
        self.photos = photos
        self.totalPhotos = totalPhotos
        self.page = page
        self.photosPerPage = photosPerPage
    }
}
