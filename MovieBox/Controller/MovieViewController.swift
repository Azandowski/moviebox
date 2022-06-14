//
//  MovieViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import AXPhotoViewer

final class MovieViewController: UIViewController, UniqueIdHelper, Alertable, FavoriteHandler, FavoriteChangeResponser {
    
    // MARK: - Oulets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wallpaperImageView: UIImageView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLbl: UILabel!
    @IBOutlet weak var movieDesLbl: UILabel!
    @IBOutlet weak var genresStackView: UIStackView!
    @IBOutlet weak var aboutSectionView: SectionView!
    @IBOutlet weak var castSectionView: SectionView!
    @IBOutlet weak var otherMovies: SectionView!
    @IBOutlet weak var factsSectionView: SectionView!
    @IBOutlet weak var imagesSectionView: SectionView!
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    @IBOutlet weak var moreButton: UIButton!
    
    lazy var aboutLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 14)
        lbl.numberOfLines = 0
        lbl.alpha = 0.6
        return lbl
    }()
    
    lazy var castCollectionView: PersonList = {
        let collectionView = PersonList()
        collectionView.setUp()
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var otherMoviesCollectionView: MoviesList = {
        let collectionView = MoviesList()
        collectionView.setUp()
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var factItemsView: ItemsStackView = {
        let itemsStackView = ItemsStackView(itemViews: [])
        return itemsStackView
    }()
    
    lazy var imagePreviewCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 24
        layout.itemSize = CGSize(width: 200, height: 84)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageItemCell.self, forCellWithReuseIdentifier: ImageItemCell.uniqueID)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var showMoreButton: UIView = {
        let showMoreView = UIView()
        showMoreView.backgroundColor = .red
        showMoreView.alpha = 0.7
        
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 17, weight: .bold)
        lbl.text = "Show more"
        lbl.textAlignment = .center
        
        showMoreView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.center.leading.trailing.equalToSuperview()
        }
        
        return showMoreView
    }()
    
    let movieImageVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    
    // MARK: - Props
    
    var media: MediaData!
    
    static var uniqueID: String = "MovieViewController"
    
    var recommendedMovies: DataSection<MediaData> = DataSection(
        data: [],
        page: 1,
        isLoading: true,
        isFinished: false
    )
    
    private var castActors: DataSection<Person> = DataSection(
        data: [],
        page: 1,
        isLoading: true,
        isFinished: false
    )
    
    private var mediaType: MediaType {
        return media is Movie ? MediaType.movie : MediaType.tv
    }
    
    private var imageURLs: [MovieImage] = []
    
    private var factsData: [(String, String)] {
        if (mediaType == .tv) {
            let tvShow = media as! TvShow
            return [("Country", tvShow.originalCoutries?.joined(separator: ", ") ?? "Undefined"),
                ("Seasons count", tvShow.numberOfSeasons != nil ? "\(tvShow.numberOfSeasons!)" : "Undefined"),
                ( "Episodes count", tvShow.numberOfEpisodes != nil ? "\(tvShow.numberOfEpisodes!)" : "Undefined")]
        } else {
            let movie = media as! Movie
            return [
                ("Country", movie.originalCountries?.map { $0.name }.joined(separator: ", ") ?? "Undefined"),
                ("Language", movie.initialLanguage ?? "Undefined"),
                ("Status", movie.status ?? "Undefined")
            ]
        }
    }
    
    private var showSeasons: Bool {
        return mediaType == .tv && ((media as! TvShow).seasons ?? []).count > 0
    }
    
    // MARK: - UI
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.animateOnViewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadFullDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.updateUI()
        self.loadRecommended()
        self.loadPeople()
        self.loadMovieImages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(responseToChangeInFavs(notification:)), name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil)
    }

    
    // MARK: - UIAction
    
    @objc fileprivate func onMoreButtonClick () {
        if (self.showSeasons) {
            self.hidesBottomBarWhenPushed = true
            let seasonsViewController = SeasonsViewController()
            seasonsViewController.tvID = self.media.id
            seasonsViewController.seasons = (self.media as! TvShow).seasons ?? []
            self.navigationController?.pushViewController(seasonsViewController, animated: true)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.frame.height), animated: true)
        }
    }
    
    @objc func responseToChangeInFavs(notification: NSNotification) {
        self.otherMoviesCollectionView.reloadData()
    }
    
    @objc func onFavButtonClicked (sender: FavoriteButton) {
        let movieData = self.recommendedMovies.data[sender.indexPath.row]
        
        _ = sender.isFav ? self.removeFromFavourite(id: movieData.id) : self.addToFavorite(movie: movieData.getFavItem())
    }
    
    // MARK: - UI Functions
    
    private func setUpUI () {
        self.view.backgroundColor = UIColor.darkColor
        self.scrollView.delegate = self
        self.moreButton.addTarget(self, action: #selector(onMoreButtonClick), for: .touchUpInside)
        
        setUpSectionView(sectionView: aboutSectionView, title: "Details", subtitle: "Full details", subview: aboutLbl)
        setUpSectionView(sectionView: castSectionView, title: "Cast", subtitle: "TOP BILLED CAST", subview: castCollectionView)
        setUpSectionView(sectionView: otherMovies, title: "Recommendated movies", subtitle: "Watch with us", subview: (otherMoviesCollectionView))
        setUpSectionView(sectionView: imagesSectionView, title: "Photo", subtitle: "Full list", subview: imagePreviewCollectionView)
        
        aboutLbl.snp.makeConstraints { (make) in
            make.bottom.top.leading.trailing.equalToSuperview()
        }
        
        castCollectionView.snp.makeConstraints { (make) in
            make.bottom.top.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }

        otherMoviesCollectionView.snp.makeConstraints { (make) in
            make.bottom.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
        imagePreviewCollectionView.snp.makeConstraints { (make) in
            make.bottom.top.leading.trailing.equalToSuperview()
            make.height.equalTo(84)
        }
        
        calculateHeight()
        setUpMovieBackground()
        generateGenreChips()
    }
    
    
    private func updateUI () {
        self.movieImageView.showCustomAnimatedSkeleton()
        self.moviePosterImageView.showCustomAnimatedSkeleton()
        
        if (media.bigImageUrl == nil || media.bigImageUrl == "") {
            self.movieImageView.image = UIImage(named: "moviePlaceholder")
            self.movieImageView.hideSkeleton()
        } else {
            self.movieImageView.sd_setImage(with: URL(string: media.bigImageUrl ?? "")) { (newImage, _, _, _) in
                self.movieImageView.hideSkeleton()
                self.movieImageView.image = newImage
            }
        }
        
        self.moviePosterImageView.sd_setImage(with: URL(string: media.imageUrl ?? "")) { (newImage, _, _, _) in
            self.moviePosterImageView.hideSkeleton()
            self.moviePosterImageView.image = newImage
        }
        
        self.wallpaperImageView.sd_setImage(with:  URL(string: media.bigImageUrl ?? ""))
        self.movieTitleLbl.text = media.title
        self.movieDesLbl.text = media.date
        self.progressView.value = CGFloat(10 * media.voteAverage)
        self.aboutLbl.text = media.overview 
    }
    
    private func calculateHeight () {
        scrollView.contentSize.height = wallpaperImageView.frame.height + self.view.frame.height * 0.7
    }
}


// MARK: - Private methods

extension MovieViewController {
    private func setUpSectionView (
        sectionView: SectionView,
        title: String,
        subtitle: String,
        subview: UIView
    ) {
        sectionView.setUp()
        sectionView.headerView.titleLabel.text = title
        sectionView.subtitleLabel.text = subtitle
        sectionView.contentView.addSubview(subview)
    }
    
    private func generateGenreChips () {
        genresStackView.alignment = .leading
        genresStackView.distribution = .fillEqually
        
        for (i, genre) in media.genres.enumerated() {
            if (i != 3) {
                let genreChipView = createGenreChip (genre: genre)
                genresStackView.addArrangedSubview(genreChipView)
            }
        }
    }
    
    private func showFacts () {
        factItemsView.rebuildItems(with: factsData.map({ (fact) -> ItemView in
            let itemView = ItemView()
            itemView.titleLbl.text = fact.1
            itemView.subtitleLbl.text = fact.0
            return itemView
        }))
        
        setUpSectionView(sectionView: factsSectionView, title: "Facts", subtitle: "Can be interesting", subview: factItemsView)
        
        factItemsView.snp.makeConstraints { (make) in
            make.bottom.top.leading.trailing.equalToSuperview()
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        
        self.calculateHeight()
    }
    
    private func createGenreChip (genre: Genre) -> ChipView {
        let chipView = ChipView()
        chipView.titleLbl.text = genre.name
        return chipView
    }
    
    private func setUpMovieBackground () {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.movieImageView.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
        self.movieImageView.layer.addSublayer(gradientLayer)
        self.movieImageView.clipsToBounds = true
        self.movieImageView.layer.masksToBounds = true
        
        self.movieImageView.addSubview(movieImageVisualEffectView)
        self.movieImageVisualEffectView.frame = self.movieImageView.frame
        self.movieImageVisualEffectView.alpha = 0
    }
    
    private func showEmptyView (for sectionView: SectionView) {
        let emptyView = EmptyView()
        sectionView.contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}



// MARK: - Networking

extension MovieViewController {
    private func loadRecommended () {
        ApiService.movieLoader.loadRecommendationsMovie(mediaType: mediaType, id: media.id, complitionHandler: { (movieResponse) in
            self.recommendedMovies.isLoading = false
            self.recommendedMovies.next(totalPages: movieResponse.total_pages)
            self.recommendedMovies.data = movieResponse.results
            self.otherMoviesCollectionView.reloadData()
            
            if (movieResponse.results.count == 0) {
                self.showEmptyView(for: self.otherMovies)
            }
            
        }) { (msg) in
            self.showAlert("Error", msg)
        }
    }
    
    private func paginatieRecommended () {
        recommendedMovies.isLoading = true
        self.otherMoviesCollectionView.reloadData()

        ApiService.movieLoader.loadRecommendationsMovie(mediaType: mediaType, id: media.id, page: recommendedMovies.page, complitionHandler: { (movieResponse) in
            self.recommendedMovies.isLoading = false
            self.recommendedMovies.next(totalPages: movieResponse.total_pages)
            self.recommendedMovies.data.append(contentsOf: movieResponse.results)
            self.otherMoviesCollectionView.reloadData()
        }) { (msg) in
            self.showAlert("Error", msg)
        }
    }
    
    private func loadPeople () {
        ApiService.shared.loadCastPeople(mediaType: mediaType, movieID: media.id, complitionHandler: { (personsResponse) in
            self.castActors.data = personsResponse.cast + personsResponse.crew
            self.castActors.isFinished = true
            self.castActors.isLoading = false
            self.castCollectionView.reloadData()
            
            if ((personsResponse.cast + personsResponse.crew).count == 0) {
                self.showEmptyView(for: self.castSectionView)
            }
        }) { (msg) in
            self.showAlert("Error", msg)
        }
    }
    
    private func loadFullDetails () {
        ApiService.movieLoader.getDetails(mediaType: mediaType, id: media.id, completionHandler: { (mediaData) in
            
            var isFavourite = self.media.isFavorite
            self.media = mediaData
            self.media.isFavorite = isFavourite
            self.showFacts()
            self.castCollectionView.reloadData()
            
            if (self.showSeasons) {
                self.moreButton.setTitle("Show Seasons", for: .normal)
            }
        }) { (msg) in
            self.showAlert("Error", msg)
        }
    }
    
    private func loadMovieImages () {
        ApiService.shared.loadImages(movieID: media.id, mediaType: mediaType, completionHandler: { (moveImages) in
            self.imageURLs = moveImages
            self.imagePreviewCollectionView.reloadData()
            self.calculateHeight()
        }) { (msg) in
            self.showAlert("Error", msg)
        }
    }
}


// MARK: - Collection View

extension MovieViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView is PersonList) {
            if (castActors.isLoading) {
                return castActors.data.count + 3
            } else {
                return castActors.data.count
            }
        } else if (collectionView is MoviesList) {
            if (recommendedMovies.isLoading) {
                return recommendedMovies.data.count + 3
            } else {
                return recommendedMovies.data.count
            }
        } else {
            return imageURLs.count > 5 ? 5 : imageURLs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView is PersonList) {
            return self.configurePersonListCell(for: indexPath, collectionView: collectionView)
        } else if collectionView is MoviesList {
            return self.configureMovieListCell(for: indexPath, collectionView: collectionView)
        } else if collectionView == imagePreviewCollectionView {
            return self.configureImagePreviewCell(for: indexPath, collectionView: collectionView)
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView is MoviesList) {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            if let movieVC = storyboard.instantiateViewController(withIdentifier: MovieViewController.uniqueID) as? MovieViewController {
                movieVC.media = recommendedMovies.data[indexPath.row]
                self.navigationController?.pushViewController(movieVC, animated: true)
            }
        } else if (collectionView == imagePreviewCollectionView) {
            self.navigationController?.pushViewController(GalleryViewController(photos: self.imageURLs.map {
                $0.toAXCustomPhoto()
            }), animated: true)
        } else if (collectionView is PersonList) {
            let person = castActors.data[indexPath.row]
            let personVC = PersonViewController()
            personVC.person = person
            self.navigationController?.pushViewController(personVC, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (scrollView == otherMoviesCollectionView) {
            let offsetX = scrollView.contentOffset.x
            let contentWidth = scrollView.contentSize.width
            
            if contentWidth < offsetX + scrollView.frame.size.width + 200 {
                if (!recommendedMovies.isFinished) {
                    paginatieRecommended()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.scrollView && !(scrollView is UICollectionView)) {
            animateOnScroll()
        }
    }
    
    // MARK: - Configure Cells
    
    private func configurePersonListCell (for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.uniqueID, for: indexPath) as! PersonCell
        
        if (castActors.isLoading && indexPath.row >= castActors.data.count) {
            cell.showCellSkeleton()
        } else {
            let personData = castActors.data[indexPath.row]
            cell.hideCellSkeleton()
            cell.avatarImage.sd_setImage(with: URL(string: personData.avatarURL), placeholderImage: UIImage(named: "moviePlaceholder"))
            cell.personNameLbl.text = personData.name
            cell.personDescriptionLbl.text = personData.characterName
        }
        
        return cell
    }
    
    private func configureMovieListCell (for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.uniqueID, for: indexPath) as! MovieCell
        
        if (recommendedMovies.isLoading && indexPath.row >= recommendedMovies.data.count) {
            cell.showCellSkeleton()
        } else {
            let movie = recommendedMovies.data[indexPath.row]
            cell.hideCellSkeleton()
            cell.movieTitleLbl.text = movie.title
            cell.movieDescriptionLbl.text = movie.date
            cell.movieImage.sd_setImage(with: URL(string: movie.imageUrl ?? ""), placeholderImage: UIImage(named: "moviePlaceholder"))
            
            let isFav = AppStore.shared.favMovies[movie.id] != nil
            
            cell.favoriteBtn.setTitle(isFav ? "Remove" : "Add", for: .normal)
            cell.favoriteBtn.isFav = isFav
            
            cell.favoriteBtn.indexPath = indexPath
            cell.favoriteBtn.collectionViewIndex = collectionView.tag
            
            cell.favoriteBtn.addTarget(self, action: #selector(onFavButtonClicked(sender:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    private func configureImagePreviewCell (for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageItemCell.uniqueID, for: indexPath) as! ImageItemCell
        cell.imageView.sd_setImage(with: URL(string: imageURLs[indexPath.row].url))
        
        if (indexPath.row == imageURLs.count - 1 || indexPath.row == 4) {
            cell.contentView.addSubview(showMoreButton)
            showMoreButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
//            showMoreButton.removeFromSuperview()
        }
        
        return cell
    }
}

// MARK: -  Animations

extension MovieViewController {
    private func animateOnScroll () {
        if (scrollView.contentOffset.y <= 65) {
            let posterScale = (scrollView.contentOffset.y > 65 ? 65 :  scrollView.contentOffset.y > 0 ? scrollView.contentOffset.y : 0) * 0.025
            let posterTranslationY = (scrollView.contentOffset.y > 65 ? 65 :  scrollView.contentOffset.y > 0 ? scrollView.contentOffset.y : 0)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.moviePosterImageView.transform = CGAffineTransform(scaleX: 1 + posterScale, y: 1 + posterScale).translatedBy(x: 0, y: -posterTranslationY)
                self.movieImageView.transform = CGAffineTransform(scaleX: 1 + posterScale, y: 1 + posterScale)
                self.movieImageVisualEffectView.alpha = (self.scrollView.contentOffset.y) / 65
            })
        }
    }
    
    
    private func animateOnViewDidLoad () {
        self.movieImageView.transform = CGAffineTransform(scaleX: 4, y: 0.4)
        self.moviePosterImageView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.movieImageView.transform = .identity
            self.moviePosterImageView.transform = .identity
        })
    }
}
