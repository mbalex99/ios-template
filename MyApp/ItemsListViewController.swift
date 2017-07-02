//
//  ItemsListViewController.swift
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import UIKit
import RealmSwift

class ItemsListViewController: UIViewController {
    
    
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white
        
        // let's setup the tableview
        let views: [String: Any] = [
            "tableView": tableView,
            "topLayoutGuide": self.topLayoutGuide
        ]
        
        view.addConstraints(
            NSLayoutConstraint
                .constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views)
        )
        view.addConstraints(
            NSLayoutConstraint
                .constraints(withVisualFormat: "V:[topLayoutGuide]-0-[tableView]-0-|", options: [], metrics: nil, views: views)
        )
    }
    
}
