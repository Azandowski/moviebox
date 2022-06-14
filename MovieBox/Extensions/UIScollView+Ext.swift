//
//  UIScollView+Ext.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

extension UIScrollView {
    func fitSizeOfContent() {
        let sumHeight = self.subviews.map({$0.frame.size.height}).reduce(0, {x, y in x + y})
        self.contentSize = CGSize(width: self.frame.width, height: sumHeight)
    }
}

