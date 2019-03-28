//
//  ThumbCollectionViewCell.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class ThumbCollectionViewCell: UICollectionViewCell {

    private var activityIndicator: UIActivityIndicatorView!
    private var imageView: UIImageView!
    private var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.addSubview(view)

        imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = self.bounds
        activityIndicator.frame = self.bounds
        NSLayoutConstraint(
            item: imageView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: imageView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        ).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: .none)
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
        self.imageView.isHidden = false
        imageView.image = UIImage(named: "error")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
