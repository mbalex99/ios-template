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
    dynamic var name: String = "New Project"
    dynamic var editedTimestamp: NSDate = NSDate()
    
    let items = List<Item>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    static var myProjectsRealm: Realm {
        let syncConfig =
            SyncConfiguration(user: SyncUser.current!, realmURL: URL(string: "\(UserDefaults.standard.realmUrl!)/~/myProjects")!)
        let realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig))
        return realm
    }

}
