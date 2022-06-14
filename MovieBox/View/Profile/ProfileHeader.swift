//
//  ProfileHeader.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class ProfileHeaderView: UIView {
    lazy var avatarView: ProfileAvatar = {
        let avatarView = ProfileAvatar()
        avatarView.snp.makeConstraints { (make) in
            make.width.height.equalTo(60)
        }
        avatarView.layer.cornerRadius = 12
        
        avatarView.titleLbl.text = "YY"
        return avatarView
    }()
    
    lazy var nameLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    lazy var emailLbl: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        label.alpha = 0.8
        label.textColor = .white
        return label
    }()
    
    lazy var labelsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        button.setImage(UIImage(systemName: "pencil.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    init () {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUp () {
        self.addSubview(avatarView)
        self.addSubview(labelsStack)
        self.addSubview(editButton)
        
        labelsStack.addArrangedSubview(nameLbl)
        labelsStack.addArrangedSubview(emailLbl)
        
        
        avatarView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }
        
        editButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(avatarView)
            make.width.height.equalTo(40)
        }
        
        labelsStack.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarView)
            make.trailing.equalTo(editButton).inset(16)
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
        }
    }
}
