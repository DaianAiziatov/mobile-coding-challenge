//
//  FullPhotoViewController.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

protocol FullPhotoViewControllerDelegate: class {
    func update(photos: [Photo], and currentPage: Int)
}

class FullPhotoViewController: UIViewController, AlertDisplayable {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var likesCount: UIBarButtonItem!
    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var navigationBar: UINavigationBar!

    weak var delegate: FullPhotoViewControllerDelegate?
    var photos = [Photo]()
    var currentPage: Int = 0
    var passedContentOffset = IndexPath()

    private var client = APIClient()
    private var isFetchInProgress = false
    private var isAlreadyTapped = false {
        didSet {
            navigationBar.isHidden = isAlreadyTapped
            toolbar.isHidden = isAlreadyTapped
            descriptionLabel.isHidden = isAlreadyTapped
            collectionView.backgroundColor = isAlreadyTapped ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    private var lastContentOffset: CGFloat = 0
    private var previousVisibleIndexPath: IndexPath = [0, 0]

    override var prefersStatusBarHidden: Bool {
        return navigationBar.isHidden == true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.bounces = false
        collectionView.register(FullPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.reloadData()
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.passedContentOffset, at: .left, animated: false)
            self.setAdditionalInfo(for: self.passedContentOffset)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapScrollView(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(tapGesture)

        // TODO: - Add prefetch for fullscreen mode and resolve bug with zooming

    }
    
    @IBAction func handleTapDoneButton(_ sender: UIBarButtonItem) {
        delegate?.update(photos: photos, and: currentPage)
        self.dismiss(animated: true)
    }

    private func fetchPhotos() {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        client.fetchPhotos(from: currentPage) { [unowned self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.onFetchFailed(with: error.reason)
                }
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    self.photos.append(contentsOf: response.photos)
                    if response.page > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: response.photos)
                        self.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.onFetchCompleted(with: .none)
                    }
                }
            }
        }
    }
    
    @objc
    private func handleTapScrollView(recognizer: UITapGestureRecognizer) {
        isAlreadyTapped = !isAlreadyTapped
    }

    private func setAdditionalInfo(for indexPath: IndexPath?) {
        if let indexPath = indexPath {
            self.descriptionLabel.text = self.photos[indexPath.item].description
            self.likesCount.title = "\(self.photos[indexPath.item].likes)"
        }
    }
}

extension FullPhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setAdditionalInfo(for: collectionView.indexPathsForVisibleItems.first)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setAdditionalInfo(for: collectionView.indexPathsForVisibleItems.first)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

extension FullPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? FullPhotoCollectionViewCell {
            cell.configure(with: photos[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
}

extension FullPhotoViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            fetchPhotos()
        }
    }
}

// MARK: - Helpers for pagination
private extension FullPhotoViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= photos.count - 1
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            collectionView.isHidden = false
            collectionView.reloadData()
            return
        }
        collectionView.insertItems(at: newIndexPathsToReload)
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        collectionView.reloadItems(at: indexPathsToReload)
    }

    func onFetchFailed(with reason: String) {
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        displayAlert(with: title, message: reason, actions: [action])
    }

    func calculateIndexPathsToReload(from newPhotos: [Photo]) -> [IndexPath] {
        let startIndex = photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
