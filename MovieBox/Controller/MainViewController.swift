//
//  ViewController.swift
//  MovieBox
//
// Created by Bekbolat Azamat
//  Copyright © 2022 Bekbolat Azamat. All rights reserved.
//

import UIKit
import SkeletonView
import SDWebImage
import SnapKit

class MainViewController: UIViewController, UniqueIdHelper, Alertable, FavoriteHandler, FavoriteChangeResponser {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    
    // MARK: - Props
    
    static var uniqueID = "MainViewController"
    
    var data: [MoviesSectionTypes: DataSection<MediaData>] = MoviesSectionTypes.allCases.reduce(into: [MoviesSectionTypes: DataSection]()) {
        $0[$1] = DataSection(data: [], isLoading: true)
    }
    
    // MARK: - UI Actions
    
    @objc private func doRefresh () {
        self.refreshControl.beginRefreshing()
        self.loadData()
    }
    
    @objc func responseToChangeInFavs(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpUI()
        self.loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(responseToChangeInFavs(notification:)), name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil)
    }
    
    // MARK: - Private methods
    
    private func setUpTableView () {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.addSubview(refreshControl)
    }
    
    private func setUpUI () {
        self.view.backgroundColor = UIColor.darkColor
    }
    
    @objc private func favBtnOnClick (sender: FavoriteButton) {
        let movieData = data.values[data.values.index(data.values.startIndex, offsetBy: sender.collectionViewIndex)]
        let mediaData = movieData.data[sender.indexPath.row]
        
        _ = sender.isFav ? self.removeFromFavourite(id: mediaData.id) : self.addToFavorite(movie: mediaData.getFavItem())
    }
    
    // MARK: - Navigation
    
    private func loadData () {
        MoviesSectionTypes.allCases.forEach { (type) in
            ApiService.movieLoader.loadMovieShowBySection(mediaType: type.mediaType, section: type, complitionHandler: { (moviesResponse) in
                self.data[type]!.data = moviesResponse.results
                self.data[type]?.isLoading = false
                self.data[type]?.next(totalPages: moviesResponse.total_pages)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }) { (msg) in
                self.showAlert("Error", msg)
            }
        }
    }
    
    private func doPagination (sectionIndex: Int) {
        let moviesSectionTypeIndex = data.keys.index(data.keys.startIndex, offsetBy: sectionIndex)
        let movieSectionType = data.keys[moviesSectionTypeIndex]

        let movieSectionData = data[movieSectionType]
        self.data[movieSectionType]?.isLoading = true
        self.tableView.reloadData()


        ApiService.movieLoader.loadMovieShowBySection(mediaType: movieSectionType.mediaType, section: movieSectionType, page: movieSectionData?.page ?? 1, complitionHandler: { (movieResponse) in
            self.data[movieSectionType]?.data.append(contentsOf: movieResponse.results)
            self.data[movieSectionType]?.isLoading = false
            self.data[movieSectionType]?.next(totalPages: movieResponse.total_pages)
            self.tableView.reloadData()
        }, complitionHandlerError: { (msg) in
            self.showAlert("Error", msg)
        })
    }
}


// MARK: - UITableView DataSource and Delegate

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.keys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.uniqueID) as! MainTableViewCell
        let movieData = data.values[data.values.index(data.values.startIndex, offsetBy: indexPath.row)]
        let sectionTitle = data.keys[data.keys.index(data.keys.startIndex, offsetBy: indexPath.row)].title
        
        
        cell.sectionView.headerView.titleLabel.text = sectionTitle
        cell.sectionView.subtitleLabel.text = "\(movieData.data.count) видео"
        cell.sectionView.alpha = 1
        cell.moviesCollectionView.delegate = self
        cell.moviesCollectionView.dataSource = self
        cell.moviesCollectionView.tag = indexPath.row
        cell.moviesCollectionView.reloadData()
        
        cell.selectionStyle = .none
        return cell
    }
}


// MARK: - UICollectionView DataSource and Delegate

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let movieData = data.values[data.values.index(data.values.startIndex, offsetBy: collectionView.tag)]
        return movieData.isLoading ? movieData.data.count + 3 : movieData.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieData = data.values[data.values.index(data.values.startIndex, offsetBy: collectionView.tag)]
        let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        if movieData.isLoading && indexPath.row >= movieData.data.count {
            movieCell.showCellSkeleton()
        } else {
            movieCell.hideCellSkeleton()
            movieCell.movieImage.showCustomAnimatedSkeleton()
            movieCell.movieImage.sd_setImage(with: URL(string: movieData.data[indexPath.row].imageUrl ?? "")) { (newImage, _, _, _) in
                movieCell.movieImage.hideSkeleton()
                movieCell.movieImage.image = newImage
            }
            
            movieCell.movieTitleLbl.text = movieData.data[indexPath.row].title
            movieCell.movieDescriptionLbl.text = movieData.data[indexPath.row].date
            
            let isFav = AppStore.shared.favMovies[movieData.data[indexPath.row].id] != nil
            
            movieCell.favoriteBtn.setTitle(isFav ? "Remove" : "Add", for: .normal)
            movieCell.favoriteBtn.isFav = isFav
        }
        
        movieCell.favoriteBtn.indexPath = indexPath
        movieCell.favoriteBtn.collectionViewIndex = collectionView.tag
        
        movieCell.favoriteBtn.addTarget(self, action: #selector(favBtnOnClick(sender:)), for: .touchUpInside)
        
        return movieCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let movieData = data.values[data.values.index(data.values.startIndex, offsetBy: collectionView.tag)]
        
        if let movieVC = storyboard.instantiateViewController(withIdentifier: MovieViewController.uniqueID) as? MovieViewController {
            movieVC.media = movieData.data[indexPath.row]
            self.navigationController?.pushViewController(movieVC, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        if (scrollView is UICollectionView) {
            if contentWidth < offsetX + scrollView.frame.size.width + 200 {
                let movieData = data.values[data.values.index(data.values.startIndex, offsetBy: scrollView.tag)]
                if (!movieData.isFinished) {
                    doPagination(sectionIndex: scrollView.tag)
                }
            }
        }
    }
}
