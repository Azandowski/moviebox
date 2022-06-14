//
//  HeaderView.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        return lbl
    }()
    
    lazy var horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 2.5
        
        view.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(5)
        }
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews () {
        self.addSubview(titleLabel)
        self.addSubview(horizontalLine)
        
        horizontalLine.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().inset(4)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(horizontalLine)
            make.leading.equalTo(horizontalLine.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
    }
}
