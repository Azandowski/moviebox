//
//  SectionView.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import SnapKit

class SectionView: UIView {
    lazy var headerView = HeaderView()
    
    lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.alpha = 0.6
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        return lbl
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    func setUp () {
        self.backgroundColor = UIColor.darkColor
        self.alpha = 1
        
        
        self.setUpViews()
        self.setUpConstraints()
    }
    
    private func setUpViews () {
        self.addSubview(headerView)
        self.addSubview(subtitleLabel)
        self.addSubview(contentView)
    }
    
    private func setUpConstraints () {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(37)
            make.top.equalTo(headerView.snp.bottom).offset(-2)
            make.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(subtitleLabel)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
