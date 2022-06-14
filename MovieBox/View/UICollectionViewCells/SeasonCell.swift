//
//  SeasonCell.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class SeasonCell: UICollectionViewCell, UniqueIdHelper {
    static var uniqueID: String = "seasonCell"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .darkColor
        label.textAlignment = .center
        return label
    }()
    
    lazy var subtitleLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkColor
        label.alpha = 0.6
        label.textAlignment = .center
        return label
    }()
    
    lazy var subtitleLbl2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkColor
        label.textAlignment = .center
        label.alpha = 0.6
        return label
    }()
    
    override func didMoveToSuperview() {
        if (superview != nil) {
            self.setUp()
        }
    }
    
    fileprivate func setUp () {
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLbl)
        self.contentView.addSubview(subtitleLbl)
        self.contentView.addSubview(subtitleLbl2)
        
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 30
        
        subtitleLbl2.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-80)
        }
        
        subtitleLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(subtitleLbl2.snp.top)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(subtitleLbl.snp.top).offset(-4)
        }
        
        
        imageView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(titleLbl.snp.top).offset(-16)
        }
    }
}
