//
//  UserDefaults+Extensions.swift
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    var rosUrl: String? {
        get {
            return self.string(forKey: "rosUrl")
        }set(val) {
            guard var val = val else { return }
            if(val.characters.last == "/") {
                self.set(val.characters.removeLast(), forKey: "")
            }
            self.set(val, forKey: "rosUrl")
        }
    }
    
    var authUrl: String? {
        guard let rosUrl = rosUrl else { return nil }
        if(rosUrl.contains("realm://")) {
            return rosUrl.replacingOccurrences(of: "realm://", with: "http://")
        }
        if(rosUrl.contains("realms://")) {
            return rosUrl.replacingOccurrences(of: "realms://", with: "https://")
        }
        if(rosUrl.contains("https://") || rosUrl.contains("http://")){
            return rosUrl
        }
        return nil
    }
    
    var realmUrl: String? {
        guard let rosUrl = rosUrl else { return nil }
        if(rosUrl.contains("http://")) {
            return rosUrl.replacingOccurrences(of: "http://", with: "realm://")
        }
        if(rosUrl.contains("https://")) {
            return rosUrl.replacingOccurrences(of: "https://", with: "realms://")
        }
        if(rosUrl.contains("https://") || rosUrl.contains("http://")){
            return rosUrl
        }
        return nil
    }
}
