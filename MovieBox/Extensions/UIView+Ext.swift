//
//  UIView+Ext.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import SkeletonView

extension UIView {
    func showCustomAnimatedSkeleton () {
        let gradient = SkeletonGradient(baseColor: UIColor.wetAsphalt)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        self.isSkeletonable = true
        self.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
}
