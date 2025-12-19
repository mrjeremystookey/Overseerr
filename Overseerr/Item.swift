//
//  Item.swift
//  Overseerr
//
//  Created by Jeremy Stookey on 12/18/25.
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
