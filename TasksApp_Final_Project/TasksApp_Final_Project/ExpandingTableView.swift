//
//  ExpandingTableView.swift
//  TasksApp_Final_Project
//
//  Created by Spencer Blackwood on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//
//  This is a UITableView that will expand its height to display all cells.

import UIKit

class ExpandingTableView: UITableView {
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
    }
    
    //  https://stackoverflow.com/questions/35876003/expand-uitableview-to-show-all-cells-in-stack-view
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
    
}
