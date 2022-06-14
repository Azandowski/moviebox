//
//  ItemsStackView.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

class ItemsStackView: UIStackView {
    
    init (itemViews: [ItemView]) {
        super.init(frame: .zero)
        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .fill
        self.spacing = 4.0
        self.createItems(itemViews: itemViews)
    }
    
    private func createItems (itemViews: [ItemView]) {
        for itemView in itemViews {
            self.addArrangedSubview(itemView)
            let dividerView = createDivider()
            self.addArrangedSubview(dividerView)
            dividerView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(1)
            }
        }
    }
    
    func rebuildItems(with itemViews: [ItemView]) {
        for view in self.arrangedSubviews {
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        self.createItems(itemViews: itemViews)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDivider () -> UIView {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.layer.cornerRadius = 0.5
        return divider
    }
}
