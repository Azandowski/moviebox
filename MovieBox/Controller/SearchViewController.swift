//
//  SearchViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//
import UIKit
import SDWebImage

final class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, Alertable {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var tvShowCollectionView: UICollectionView!
    @IBOutlet weak var actorsCollectionView: UICollectionView!
    private var movies = [Movie]()
    private var tvShows = [TvShow]()
    private var actors = [Person]()
    let searchBar = UISearchBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        ApiService.shared.getPersonPopular(completionHandler: { (personPopular) in
            self.actors = [Person]()
            self.actors = personPopular
            print(self.actors)
            self.actorsCollectionView.reloadData()
        }) { (msg) in
            self.showAlert("Error", msg)
        }
        
        MediaType.allCases.forEach { (type) in
            ApiService.movieLoader.getDiscoverMedia(mediaType: type, completionHandler: { (response) in
                if (type == .movie) {
                    self.movies = response.results as! [Movie]
                    self.movieCollectionView.reloadData()
                } else {
                    self.tvShows = response.results as! [TvShow]
                    self.tvShowCollectionView.reloadData()
                }
            }) { (msg) in
                self.showAlert("Error", msg)
            }
        }
    }
    
    
    func setUpNavBar() {
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search MovieBox"
        searchBar.backgroundColor = UIColor.darkColor
        navigationItem.titleView = searchBar
        searchBar.isTranslucent = true
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(withIdentifier: SearchTableViewController.uniqueID) as? SearchTableViewController {
            self.present(UINavigationController(rootViewController: searchVC), animated: false, completion: nil)
        }
    }
    
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == movieCollectionView {
            return movies.count
        } else if collectionView == tvShowCollectionView {
            return tvShows.count
        } else if collectionView == actorsCollectionView {
            return actors.count
        } else {
            return 1
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == movieCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchMovieCell
            let movie = movies[indexPath.row]
            cell.nameLabel.text = movie.title
            cell.movieImage.sd_setImage(with: URL(string: movie.imageUrl ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
            return cell
        } else if collectionView == tvShowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchTVCell", for: indexPath) as! SearchMovieCell
            let tvShow = tvShows[indexPath.row]
            cell.tvLabel.text = tvShow.title
            cell.tvImage.sd_setImage(with: URL(string: tvShow.imageUrl ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
            return cell
        } else if collectionView == actorsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchPersonCell", for: indexPath) as! SearchMovieCell
            let person = actors[indexPath.row]
            cell.actorNameLabel.text = person.name
            cell.actorImageView.sd_setImage(with: URL(string: person.avatarURL), placeholderImage: UIImage(named: "placeholder.png"))
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item + 1)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let movieVC = storyboard.instantiateViewController(withIdentifier: MovieViewController.uniqueID) as? MovieViewController {
            if collectionView == movieCollectionView {
                movieVC.media = movies[indexPath.row] as MediaData
                self.navigationController?.pushViewController(movieVC, animated: true)
            } else if collectionView == tvShowCollectionView {
                movieVC.media = tvShows[indexPath.row] as MediaData
                self.navigationController?.pushViewController(movieVC, animated: true)
            }
            
        }
            if collectionView == actorsCollectionView {
                let person = actors[indexPath.row]
                let personVC = PersonViewController()
                personVC.person = person
                self.navigationController?.pushViewController(personVC, animated: true)
            }
    }

}
