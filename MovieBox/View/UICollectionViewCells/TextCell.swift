//
//  TextCell.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

typealias TextCellConfigurator = TableCellConfigurator<TextCell, TextCellData>

struct TextCellData {
    let title: String
    let body: String
}

class TextCell: UITableViewCell, ConfigurableCell {
    
    lazy var headerView: HeaderView = {
        let view = HeaderView()
        return view
    }()
    
    lazy var descriptionLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.alpha = 0.7
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(headerView)
        self.contentView.addSubview(descriptionLbl)
        
        headerView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
        }
        
        descriptionLbl.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(headerView.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: TextCellData, index: Int) {
        self.headerView.titleLabel.text = data.title
        self.descriptionLbl.text = data.body
    }
}
