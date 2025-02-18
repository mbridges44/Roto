//
//  Item.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//

import SwiftData
import Foundation

@Model
final class Item: Identifiable {
    var timestamp: Date

    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
    }
}
