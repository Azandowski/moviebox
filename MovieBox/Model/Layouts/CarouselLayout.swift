//
//  CarouselLayout.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//


import UIKit

final class CarouselLayout: UICollectionViewLayout {
    
    var itemSpacing: CGFloat = 20.0
    var itemSize: CGSize = CGSize(width: 200, height: 200)
    var sideItemVisibleWidth: CGFloat = 40.0
    
    private var itemCount: Int = 0
    private var itemWidthAndSpacing: CGFloat {
        return itemSpacing + itemSize.width
    }
    
    private var contentWidth: CGFloat {
        return CGFloat(itemCount) * itemWidthAndSpacing + itemSpacing + itemSize.width / 2
    }
    
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        itemCount = collectionView.numberOfItems(inSection: 0)
        var currentX: CGFloat = sideItemVisibleWidth + itemSpacing
        layoutAttributes = []
        
        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.size = itemSize
            let currentScrollX = collectionView.contentOffset.x + itemWidthAndSpacing
            let centerX = currentX + itemSize.width / 2
            let centerY = collectionView.bounds.maxY - itemSize.height / 2
            let xDifference = abs(currentScrollX - centerX)
            
            if (xDifference < itemSize.width) {
                let deltaScale = 0.4 - (0.4 / (itemSize.width)) * xDifference
                let difference = (deltaScale * itemSize.height / 2)
                attributes.transform = CGAffineTransform(scaleX: 1, y: 1 + deltaScale).translatedBy(x: 0, y: -difference)
                attributes.alpha = 0.4 + 4 * deltaScale
            }
            
            attributes.center = CGPoint(x: centerX, y: centerY)
            layoutAttributes.append(attributes)
            
            currentX += itemWidthAndSpacing
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: itemSize.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for attribure in layoutAttributes where attribure.indexPath == indexPath {
            return attribure
        }
        
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
