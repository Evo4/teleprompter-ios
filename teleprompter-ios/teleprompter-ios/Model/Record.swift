//
//  Record.swift
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit

class Record: Codable, Hashable {
    
    var hashValue: Int {
        return number.hashValue
    }
    
    var number: Int
    var isDone: Bool
    var text: String
    var musicUrl: URL
    
    var description: String {
        return "\(number). \(text)"
    }
    
    init(number: Int, isDone: Bool, text: String, musicUrl: URL) {
        self.number = number
        self.isDone = isDone
        self.text = text
        self.musicUrl = musicUrl
    }
    
    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
