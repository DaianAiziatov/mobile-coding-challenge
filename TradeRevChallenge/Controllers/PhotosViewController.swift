//
//  ViewController.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        APIClient().fetchPhotos(from: 1) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(var response):
                print(response.totalPages)
            }
        }
    }
}
