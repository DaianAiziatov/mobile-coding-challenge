//
//  FullPhotoCollectionViewCell.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class FullPhotoCollectionViewCell: UICollectionViewCell {

    private var activityIndicator: UIActivityIndicatorView!
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.flashScrollIndicators()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0

        self.addSubview(scrollView)

        imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        scrollView.addSubview(imageView)

        activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        imageView.frame = self.bounds
        activityIndicator.frame = self.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.setZoomScale(1, animated: true)
        configure(with: .none)
    }

    func configure(with photo: Photo?) {
        if let photo = photo {
            guard let fullPath = photo.urls?.full, let fullURL = URL(string: fullPath) else {
                setErrorImage()
                return
            }
            UIImage.downloaded(from: fullURL) { [weak self] result in
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

extension FullPhotoCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
