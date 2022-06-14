//
//  PersonViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class PersonViewController: UIViewController, Alertable {
    
    struct PersonCareer {
        var year: Int?
        var character: String
        var movie: String
    }
    // MARK: - UI Outlets
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "demoCell")
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.uniqueID)
        tableView.register(TextCell.self, forCellReuseIdentifier: TextCellConfigurator.reuseId)
        tableView.contentInset = UIEdgeInsets(top: self.view.frame.height * 0.6, left: 0, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    fileprivate lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.addSubview(headerImage)
        headerView.addSubview(gradientImageView)
        headerView.addSubview(overlayView)
        headerView.addSubview(titleLbl)
        
        gradientImageView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        headerImage.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        return headerView
    }()
    
    fileprivate lazy var headerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "moviePlaceholder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    fileprivate lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var gradientImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "fog")
        return imageView
    }()
    
    fileprivate lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        return overlayView
    }()
        
    
    // MARK: - Props
    
    var person: Person!
    
    fileprivate var movies: DataSection<MediaData> = DataSection(
        data: [],
        page: 1,
        isLoading: true,
        isFinished: false
    )
    
    fileprivate var cellsData: [[CellConfigurator]] {
        return [
            person.biography != nil ? [
            TextCellConfigurator(item: TextCellData(
                title: "Биография", body: person.biography!
            ))] : [],
            (careerSteps ?? []).map {
                return textCellFromCareerStep(item: $0)
            }
        ]
    }
    
    fileprivate var careerSteps: [PersonCareer]?
    
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTableView()
        self.updateUI()
        self.setUpUI()
        self.loadPersonMovies()
        self.loadPersonData()
    }
    
    fileprivate func setUpTableView () {
        self.view.backgroundColor = .black
        self.view.addSubview(tableView)
        self.view.addSubview(headerView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: self.view.frame.height * 0.6)
    }
    
    fileprivate func setUpUI () {
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.view.frame.height * 0.6), animated: true)
    }
}

// MARK: - Private methods

extension PersonViewController {
    fileprivate func updateUI () {
        self.headerImage.sd_setImage(with: URL(string: person.wallpaperURL), placeholderImage: UIImage(named: "moviePlaceholder"))
        self.titleLbl.text = (person.name ?? "").split(separator: " ").joined(separator: "\n")
    }
    
    fileprivate func loadPersonMovies () {
        MediaType.allCases.forEach { (mediaType) in
            ApiService.movieLoader.getPersonMovies(mediaType: mediaType, id: person.id, completionHandler: { (data) in
                let didLoadAllMediaTypes = self.movies.data.count != 0
                
                self.movies.isLoading = false
                self.movies.data.append(contentsOf: data)
                self.movies.isFinished = true
                self.tableView.reloadData()
                
                if (didLoadAllMediaTypes) {
                    self.careerSteps = self.generateCareer()
                    self.tableView.reloadData()
                }
            }) { (msg) in
                self.showAlert("Error", msg)
            }
        }
    }
    
    fileprivate func loadPersonData () {
        ApiService.shared.getPersonDetails(personID: person.id, completionHandler: { (newPerson) in
            self.person = newPerson
            self.tableView.reloadData()
        }) { (msg) in
            self.showAlert("Error", msg)
        }
    }
    
    fileprivate func generateCareer () -> [PersonCareer] {
        var personCareerSteps:[PersonCareer] = []
        
        self.movies.data.forEach { (mediaData) in
            let yearArr = (mediaData.date ?? "").split(separator: "-")
            let year = yearArr.count > 1 ? yearArr[0] : nil
            
            let personCareerStep = PersonCareer(
                year: Int(year ?? "") ?? nil,
                character: mediaData.character ?? "",
                movie: mediaData.title)
            personCareerSteps.append(personCareerStep)
        }
        
        personCareerSteps.sort { (a, b) -> Bool in
            return a.year ?? 0 > b.year ?? 0
        }
        
        return personCareerSteps
    }
    
    fileprivate func textCellFromCareerStep (item: PersonCareer) -> TextCellConfigurator {
        let year = item.year != nil ? String(item.year!) : "-"
        return TextCellConfigurator(item: TextCellData(
            title: item.movie,
            body: item.character + " (\(year))")
        )
    }
}


// MARK: - UI TableView Delegate and DataSource

extension PersonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.cellsData.count + 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : cellsData[section - 1].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return self.configureMoviesCell(for: indexPath)
        } else {
            let item = self.cellsData[indexPath.section - 1][indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: type(of: item).reuseId)!
            cell.backgroundColor = .black
            cell.selectionStyle = .none
            item.configure(cell: cell, index: indexPath.row + 1)
            return cell
        }
    }
    
    fileprivate func configureMoviesCell (for indexPath: IndexPath) -> MainTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.uniqueID) as! MainTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = .black
        cell.sectionView.headerView.titleLabel.text = "Movies"
        cell.sectionView.subtitleLabel.text = "One of the best actors"
        cell.sectionView.backgroundColor = .black
        cell.moviesCollectionView.delegate = self
        cell.moviesCollectionView.dataSource = self
        cell.moviesCollectionView.tag = indexPath.row
        cell.moviesCollectionView.reloadData()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        
        if (scrollView is UITableView) {
            if (y >= 0) {
                let minHeight: CGFloat = 70.0
                let currentHeight = max(minHeight, y)
                self.headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: currentHeight)
                self.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1 - (abs(y) * 1 / (view.frame.height * 0.8)))
                if (self.titleLbl.text == "Actor") {
                    self.titleLbl.text = person.name
                }
                
            } else {
                self.titleLbl.text = "Actor"
            }
        }
    }
}



// MARK: - UICollecitonView DataSource and Delegate

extension PersonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.isLoading ? movies.data.count + 3 : movies.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.uniqueID, for: indexPath) as! MovieCell
        
        if (movies.isLoading && indexPath.row >= movies.data.count) {
            cell.showCellSkeleton()
        } else {
            let movie = movies.data[indexPath.row]
            cell.hideCellSkeleton()
            cell.movieTitleLbl.text = movie.title
            cell.movieDescriptionLbl.text = movie.date
            cell.movieImage.sd_setImage(with: URL(string: movie.imageUrl ?? ""), placeholderImage: UIImage(named: "moviePlaceholder"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let movieVC = storyboard.instantiateViewController(withIdentifier: MovieViewController.uniqueID) as? MovieViewController {
            movieVC.media = movies.data[indexPath.row]
            self.navigationController?.pushViewController(movieVC, animated: true)
        }
    }
}
