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
    @IBOutlet weak var articleDescription: UILabel!
    
    func displayArticle(title: String?, description: String?) {
        guard let t = title else {
            self.articleTitle.text = ""
            return
        }
        self.articleTitle.text = t
        guard let d = description else {
            self.articleDescription.text = ""
            return
        }
        self.articleDescription.text = d
    }
}
