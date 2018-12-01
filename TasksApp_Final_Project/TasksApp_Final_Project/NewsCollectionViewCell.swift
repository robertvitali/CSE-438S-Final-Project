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
    
    func displayArticle(title: String?) {
        guard let t = title else {
            self.articleTitle.text = ""
            return
        }
        self.articleTitle.text = t
    }
}
