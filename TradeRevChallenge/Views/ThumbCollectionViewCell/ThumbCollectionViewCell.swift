//
//  ThumbCollectionViewCell.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class ThumbCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: .none)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
    }

    func configure(with photo: Photo?) {
        if let photo = photo {
            guard let thumbPath = photo.urls?.thumb, let thumbURL = URL(string: thumbPath) else {
                setErrorImage()
                return
            }
            UIImage.downloaded(from: thumbURL) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(_):
                    DispatchQueue.main.async {
                        self.setErrorImage()
                    }
                case .success(let image):
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.imageView.image = image
                        self.imageView.isHidden = false
                    }
                }
            }
        } else {
            activityIndicator.startAnimating()
            imageView.isHidden = true
        }

    }

    private func setErrorImage() {
        activityIndicator.stopAnimating()
        imageView.image = UIImage(named: "error")
    }

}
