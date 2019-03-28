//
//  ViewController.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, AlertDisplayable {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!

    private var photos = [Photo]()
    private var client = APIClient()

    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    private var totalCount: Int {
        return total
    }
    private var currentCount: Int {
        return photos.count
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.startAnimating()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(ThumbCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        fetchPhotos()
    }

    // Handle device rotation
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Fetch photo
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
                    self.total = response.totalPhotos
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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFull", let destination = (segue.destination as? FullPhotoViewController) {
            destination.photos = photos
            destination.currentPage = currentPage
            destination.delegate = self
            if let cell = sender as? UICollectionViewCell, let indexPath = self.collectionView.indexPath(for: cell) {
                destination.passedContentOffset = indexPath
            }
        }
    }

    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if bottom reached and we are still not in the end of fetching
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            if collectionView.indexPathsForVisibleItems.count < total {
                fetchPhotos()
            }
        }
    }
}

// MARK: - Collection View Data Source
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ThumbCollectionViewCell {
            cell.configure(with: photos[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - Collection View Delegate Flow Layout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showFull", sender: collectionView.cellForItem(at: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfPhotosInRow = CGFloat(collectionView.frame.size.width > collectionView.frame.size.height ? 5.0 : 3.0)
        let size = collectionView.frame.size.width / numberOfPhotosInRow - 3.0
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}

// MARK: - Collection View Data Source Prefetching
extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            fetchPhotos()
        }
    }
}

extension PhotosViewController: FullPhotoViewControllerDelegate {
    func update(photos: [Photo], and currentPage: Int) {
        self.currentPage = currentPage
        let difference = photos.difference(from: self.photos)
        self.photos = photos
        let indexPathsToReload = self.calculateIndexPathsToReload(from: difference)
        self.onFetchCompleted(with: indexPathsToReload)
    }
}

// MARK: - Helpers for pagination
private extension PhotosViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= self.currentCount - 1
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            indicatorView.stopAnimating()
            collectionView.isHidden = false
            collectionView.reloadData()
            return
        }
        collectionView.insertItems(at: newIndexPathsToReload)
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        collectionView.reloadItems(at: indexPathsToReload)
    }

    func onFetchFailed(with reason: String) {
        indicatorView.stopAnimating()
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
