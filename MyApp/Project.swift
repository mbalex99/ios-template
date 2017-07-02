//
//  Project.swift
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
    
    dynamic var _id: String = UUID().uuidString
    dynamic var title: String = ""
    
    let items = List<Item>()
    
}
