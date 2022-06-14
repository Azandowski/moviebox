//
//  EpisodeCell.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import SkeletonView

final class EpisodeNumberCell: UICollectionViewCell, UniqueIdHelper {
    static var uniqueID: String = "episodeNumberCell"
    
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .gray
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.snp.makeConstraints { (make) in
            make.width.equalTo(12)
            make.height.equalTo(3)
        }
        return view
    }()
    
    
    
    override func didMoveToSuperview() {
        if (superview != nil) {
            setUpUI()
        }
    }
    
    fileprivate func setUpUI () {
        self.contentView.addSubview(containerView)
        
        containerView.addSubview(titleLbl)
        containerView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(lineView).offset(-4)
            make.top.equalToSuperview().offset(5)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.leading.trailing.centerY.equalToSuperview()
        }
    }
}


final class EpisodeCell: UITableViewCell, UniqueIdHelper {
    
    static var uniqueID: String = "episodeCell"
    
    lazy var episodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isSkeletonable = true
        return imageView
    }()
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.numberOfLines = 0
        lbl.textColor = .white
        lbl.isSkeletonable = true
        return lbl
    }()
    
    lazy var episodeLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .red
        lbl.font = .systemFont(ofSize: 13)
        lbl.isSkeletonable = true
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showCellSkeleton () {
        let gradient = SkeletonGradient(baseColor: UIColor.wetAsphalt)
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        episodeImageView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
        titleLbl.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        episodeLbl.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
    
    func hideCellSkeleton () {
        episodeImageView.hideSkeleton()
        titleLbl.hideSkeleton()
        episodeLbl.hideSkeleton()
    }
    
    fileprivate func setUp () {
        self.contentView.addSubview(episodeImageView)
        self.contentView.addSubview(titleLbl)
        self.contentView.addSubview(episodeLbl)
        
        self.backgroundColor = .black
        
        episodeImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(16)
            make.height.equalTo(80)
            make.width.equalTo(160)
        }
        
        episodeLbl.snp.makeConstraints { (make) in
            make.leading.equalTo(episodeImageView.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(20)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(episodeImageView.snp.trailing).offset(16)
            make.top.equalTo(episodeLbl.snp.bottom).offset(4)
        }
    }
}
