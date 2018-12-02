//
//  NewsCollectionViewCell.swift
//  NewsTest
//
//  Created by Spencer Blackwood on 11/27/18.
//  Copyright © 2018 Spencer Blackwood. All rights reserved.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var outlet: UILabel!
    
    func displayArticle(title: String, media: String) {
        self.articleTitle.text = title
        self.outlet.text = media
    }
}
