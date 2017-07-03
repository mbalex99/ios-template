//
//  Item.swift
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    dynamic var _id: String = UUID().uuidString
    dynamic var name: String = ""
    dynamic var body: String = ""
    dynamic var isDone: Bool = false
    dynamic var timestamp: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
