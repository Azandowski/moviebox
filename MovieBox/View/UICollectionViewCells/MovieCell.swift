//
//  MovieCell.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import SkeletonView

class FavoriteButton: UIButton {
    var indexPath: IndexPath!
    var collectionViewIndex: Int!
    var isFav: Bool!
}


class MovieCell: UICollectionViewCell, UniqueIdHelper {
    
    static var uniqueID: String = "movieCell"
    
    lazy var movieImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isSkeletonable = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true 
        return imageView
    }()
    
    lazy var movieTitleLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        label.isSkeletonable = true
        return label
    }()
    
    lazy var movieDescriptionLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 1
        label.isSkeletonable = true
        return label
    }()
    
    lazy var favoriteBtn: FavoriteButton = {
        let btn = FavoriteButton()
        btn.setTitle("В избранные", for: .normal)
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.rgb(200, 200, 200).cgColor
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.isSkeletonable = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSkeletonable = true
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews () {
        self.contentView.backgroundColor = UIColor.rgb(25, 25, 25)
        self.contentView.layer.cornerRadius = 8
        
        self.addShadow()
        
        for view in [movieImage, movieTitleLbl, movieDescriptionLbl, favoriteBtn] {
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addUIConstraints()
    }
    
    func showCellSkeleton () {
        let gradient = SkeletonGradient(baseColor: UIColor.wetAsphalt)
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        movieImage.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
        movieTitleLbl.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        movieDescriptionLbl.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        favoriteBtn.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
    
    func hideCellSkeleton () {
        movieImage.hideSkeleton()
        movieTitleLbl.hideSkeleton()
        movieDescriptionLbl.hideSkeleton()
        favoriteBtn.hideSkeleton()
    }
    
    
    private func addShadow () {
        let layer = self.contentView.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.8
    }
    
    private func addUIConstraints () {
        movieImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(175)
        }
        
        movieTitleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(movieImage.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(36)
        }
        
        movieDescriptionLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(movieTitleLbl.snp.bottom)
            make.height.equalTo(16)
        }
        
        favoriteBtn.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-12)
            make.top.equalTo(movieDescriptionLbl.snp.bottom).offset(4)
        }
    }
}
