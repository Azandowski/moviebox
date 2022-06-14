//
//  EmptyView.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class EmptyView: UIView {
    
    enum EmptyViewMode {
        case small, large
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "moviePlaceholder")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel ()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.text = "Not Found"
        label.textAlignment = .center
        return label
    }()
    
    init(mode: EmptyViewMode = .small) {
        super.init(frame: .zero)
        self.setUpViews(mode: mode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpViews (mode: EmptyViewMode) {
        self.backgroundColor = .darkColor
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel).inset(
                mode ==  EmptyViewMode.small ? -16 : 40
            )
            
            if (mode == EmptyViewMode.small) {
                make.width.height.equalTo(128)
            } else {
                make.width.height.equalTo(256)
            }
        }
    }
}


