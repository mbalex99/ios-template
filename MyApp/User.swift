//
//  User.swift
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var _id: String = SyncUser.current?.identity ?? ""
    dynamic var username: String = ""
    dynamic var name: String = ""

    static var globalUsersRealm: Realm {
        let syncConfig =
            SyncConfiguration(user: SyncUser.current!, realmURL: URL(string: "\(UserDefaults.standard.realmUrl!)/globalUsers")!)
        let realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig))
        return realm
    }
}
