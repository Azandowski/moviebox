//
//  FavouritesViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class FavouritesViewController: UIViewController, Alertable, FavoriteHandler, FavoriteChangeResponser {
    
    // MARK: - Outlets
    
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.uniqueID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .darkColor
        return collectionView
    }()
    
    // MARK: - Props
    
    fileprivate lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let width = self.view.frame.width - 32 - (spacing * CGFloat(numberOfColumns))
        layout.itemSize = CGSize(width: width / CGFloat(numberOfColumns), height: 280)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return layout
    }()
    
    let emptyView = EmptyView(mode: .large)
    
    fileprivate let spacing: CGFloat = 8.0
    fileprivate let numberOfColumns: Int = 2
 
    
    // MARK: - Init
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (AppStore.shared.favMovies.keys.count == 0) {
            self.showEmptyView()
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkColor
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(responseToChangeInFavs(notification:)), name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil)
    }
    
    // MARK: - Private methods
    
    private func showEmptyView () {
        self.view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func responseToChangeInFavs(notification: NSNotification) {
        self.collectionView.reloadData()
        
        if (AppStore.shared.favMovies.keys.count == 0) {
            self.showEmptyView()
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
    @objc private func favBtnOnClick (sender: FavoriteButton) {
        let indexPath = sender.indexPath
        let currentKey = AppStore.shared.favMovies.keys[AppStore.shared.favMovies.keys.index(AppStore.shared.favMovies.keys.startIndex, offsetBy: indexPath!.row)]
        let item = AppStore.shared.favMovies[currentKey]
        
        _ = sender.isFav ? self.removeFromFavourite(id: item!.id) : self.addToFavorite(movie: item!)
    }
}


extension FavouritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppStore.shared.favMovies.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.uniqueID, for: indexPath) as! MovieCell
        let currentKey = AppStore.shared.favMovies.keys[AppStore.shared.favMovies.keys.index(AppStore.shared.favMovies.keys.startIndex, offsetBy: indexPath.row)]
        let item = AppStore.shared.favMovies[currentKey]
        
        cell.movieImage.sd_setImage(with: URL(string: item?.imageUrl ?? ""), placeholderImage: UIImage(named: "moviePlaceholder"))
        cell.movieTitleLbl.text = item?.title ?? ""
        cell.movieDescriptionLbl.text = ""
        
        let isFav = AppStore.shared.favMovies[item!.id] != nil
        
        cell.favoriteBtn.setTitle(isFav ? "Remove" : "Add", for: .normal)
        cell.favoriteBtn.isFav = isFav
        cell.favoriteBtn.indexPath = indexPath
        cell.favoriteBtn.collectionViewIndex = collectionView.tag
        
        cell.favoriteBtn.addTarget(self, action: #selector(favBtnOnClick(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let currentKey = AppStore.shared.favMovies.keys[AppStore.shared.favMovies.keys.index(AppStore.shared.favMovies.keys.startIndex, offsetBy: indexPath.row)]
        
        if let item = AppStore.shared.favMovies[currentKey] {
            ApiService.movieLoader.getDetails(mediaType: item.mediaType, id: item.id, showLoading: true, completionHandler: { (data) in
                if let movieVC = storyboard.instantiateViewController(withIdentifier: MovieViewController.uniqueID) as? MovieViewController {
                    movieVC.media = data
                    self.navigationController?.pushViewController(movieVC, animated: true)
                }
            }) { (error) in
                self.showAlert("Error", error)
            }
        }
    }
}
