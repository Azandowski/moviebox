//
//  MovieCollectionViewCell.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    func setup(with movie: Movie) {
        movieImageView.image = UIImage(named: "movieImg")
        nameLabel.text = movie.title
    }
}
