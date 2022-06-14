//
//  ItemsView.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class ItemView: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .gray
        return lbl
    }()
    
    lazy var subtitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLbl)
        self.addSubview(subtitleLbl)
        
        subtitleLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(4)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview() 
            make.bottom.equalToSuperview().offset(-2)
            make.top.equalTo(subtitleLbl.snp.bottom).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

