//
//  EpisodeViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import SkeletonView

final class EpisodeViewController: UIViewController, Alertable {
    
    // MARK: - Outlets
    
    fileprivate lazy var seasonsCollectionView: UICollectionView = {
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.itemSize = CGSize(width: 40, height: 64)
        horizontalLayout.minimumLineSpacing = 16
        horizontalLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EpisodeNumberCell.self, forCellWithReuseIdentifier: EpisodeNumberCell.uniqueID)
        collectionView.backgroundColor = .darkColor
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.uniqueID)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .black
        return tableView
    }()
    
    // MARK: - Props
    
    var tvID: Int!
    var numberOfSeasons: Int!
    var currentSeason: Int!
    var currentEpisodes: [Episode] = []
    fileprivate var isLoading: Bool = true
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = "Seasons"
        self.view.backgroundColor = .black
        self.setUpUI()
        self.loadData(seasonID: self.currentSeason)
        self.seasonsCollectionView.scrollToItem(at: IndexPath(row:  self.currentSeason - 1, section: 0), at: .left, animated: true)
    }
    
    // MARK: - UI
    
    fileprivate func setUpUI () {
        self.view.addSubview(seasonsCollectionView)
        self.view.addSubview(tableView)
        
        seasonsCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(64)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(seasonsCollectionView.snp.bottom)
        }
    }
}

// MARK: - Network
extension EpisodeViewController {
    fileprivate func loadData (seasonID: Int) {
        preLoadHandler()
        
        ApiService.shared.getEpisodes(tvID: tvID, seasonID: seasonID, completionHandler: { (episodes) in
            self.dataHandler(episodes: episodes)
        }) { (msg) in
            self.errorHandler(error: msg)
        }
    }
    
    fileprivate func preLoadHandler () {
        self.currentEpisodes = []
        self.isLoading = true
        self.tableView.reloadData()
    }
    
    fileprivate func dataHandler (episodes: [Episode]) {
        self.isLoading = false
        self.currentEpisodes = episodes
        self.tableView.reloadData()
    }
    
    fileprivate func errorHandler (error: String) {
        self.showAlert("Error", error)
    }
}


// MARK: - CollectionView: Season Number Selector
extension EpisodeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfSeasons
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeNumberCell.uniqueID, for: indexPath) as! EpisodeNumberCell
        cell.titleLbl.text = "\(indexPath.row + 1)"
        
        cell.lineView.isHidden = indexPath.row + 1 != self.currentSeason
        cell.titleLbl.textColor = indexPath.row + 1 != self.currentSeason ? .gray : .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.currentSeason != indexPath.row + 1) {
            self.currentSeason = indexPath.row + 1
            self.loadData(seasonID: self.currentSeason)
            self.seasonsCollectionView.reloadData()
        }
    }
}


extension EpisodeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isLoading ? 3 : self.currentEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.uniqueID, for: indexPath) as! EpisodeCell
        cell.selectionStyle = .none
        
        if (isLoading) {
            cell.showSkeleton()
        } else {
            let episode = currentEpisodes[indexPath.row]
            
            cell.hideSkeleton()
            cell.episodeImageView.sd_setImage(with: URL(string: episode.imageURL ?? ""), placeholderImage: UIImage(named: "moviePlaceholder"))
            cell.episodeLbl.text = "EPISODE \(episode.episodeNumber)"
            cell.titleLbl.text = episode.title
        }
        
        return cell
    }
}
