//
//  NewsAPIResults.swift
//  NewsTest
//
//  Created by Spencer Blackwood on 11/27/18.
//  Copyright © 2018 Spencer Blackwood. All rights reserved.
//

import Foundation

struct NewsAPIResults: Codable {
    let status: String
    let totalResults: Int
    var articles: [NewsStory]
}
