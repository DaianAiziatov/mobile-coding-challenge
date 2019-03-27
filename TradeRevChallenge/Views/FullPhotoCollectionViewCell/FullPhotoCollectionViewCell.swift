//
//  FullPhotoCollectionViewCell.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class FullPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var likesCount: UIBarButtonItem!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var isAlreadyTapped = false {
        didSet {
            toolbar.isHidden = isAlreadyTapped
            descriptionLabel.isHidden = isAlreadyTapped
            scrollView.backgroundColor = isAlreadyTapped ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : photoColor ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    private var photoColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapScrollView(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapGesture)
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
            likesCount.title = "\(photo.likes)"
            if let description = photo.description {
                descriptionLabel.text = description
            } else {
                descriptionLabel.text = photo.alternativeDesription
            }
            if let color = photo.color {
                photoColor = UIColor(hexString: color)
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

    @objc
    private func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale,
                                                 center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }

    @objc
    private func handleTapScrollView(recognizer: UITapGestureRecognizer) {
        isAlreadyTapped = !isAlreadyTapped
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    private func setErrorImage() {
        activityIndicator.stopAnimating()
        imageView.image = UIImage(named: "error")
    }

}

extension FullPhotoCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
