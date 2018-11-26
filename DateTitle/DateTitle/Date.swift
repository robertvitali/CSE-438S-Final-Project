//
//  Date.swift
//  DateTitle
//
//  Created by Robert on 11/25/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import Foundation

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: self)
    }
}
