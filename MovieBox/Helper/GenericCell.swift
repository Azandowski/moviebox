//
//  GenericCell.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType, index: Int)
}

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView, index: Int)
}

class TableCellConfigurator<CellType: ConfigurableCell, DataType> : CellConfigurator where CellType.DataType == DataType, CellType: UITableViewCell {
    static var reuseId: String { return String(describing: CellType.self) }
    var item: DataType
    
    init(item: DataType) {
        self.item = item
    }
    
    func configure(cell: UIView, index: Int) {
        (cell as! CellType).configure(data: item, index: index)
    }
}
