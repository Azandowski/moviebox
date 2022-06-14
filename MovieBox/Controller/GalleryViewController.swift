//
//  GallerViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import AXPhotoViewer

final class GalleryViewController: UICollectionViewController {
    
    // MARK: - Props
    
    internal var numberOfColumns = 3
    
    internal var columnSpacing: CGFloat = 16
    
    internal var photos: [AXCustomPhoto] = []
    
    private let layout = UICollectionViewFlowLayout()
    
    // MARK: - Init
    
    init (photos: [AXCustomPhoto]) {
        super.init(collectionViewLayout: layout)
        self.photos = photos
        self.setUpLayout()
        self.setUpCollectionView()
        self.navigationItem.title = "\(photos.count) photos"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private method
    
    private func setUpCollectionView () {
        collectionView.register(ImageItemCell.self, forCellWithReuseIdentifier: ImageItemCell.uniqueID)
    }
    
    private func setUpLayout () {
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = columnSpacing
        
        let itemHeight = (self.view.frame.width - columnSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        layout.itemSize = CGSize(width: itemHeight / 0.4, height: itemHeight)
    }
}


extension GalleryViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageItemCell.uniqueID, for: indexPath) as! ImageItemCell
        cell.imageView.sd_setImage(with: photos[indexPath.row].url!)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataSource = AXPhotosDataSource(photos: photos)
        let photosViewController = AXPhotosViewController(dataSource: dataSource)
//        photosViewController.currentPhotoIndex = indexPath.row
        self.present(photosViewController, animated: true, completion: nil)
    }
}
