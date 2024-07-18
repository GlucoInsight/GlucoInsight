//
//  Item.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
