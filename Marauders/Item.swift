//
//  Item.swift
//  Marauders
//
//  Created by tiscomacnb2486 on 12/11/2568 BE.
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
