//
//  ProjectItemsListViewController
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectItemsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let project: Project
    var notificationToken: NotificationToken?
    
    init(project: Project){
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white
        title = project.name
        
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
                .constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: [], metrics: nil, views: views)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ProjectsListViewController.addBarButtonDidTap))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath) ?? UITableViewCell()
        let item = project.items[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = project.items[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            project.realm?.beginWrite()
            project.items.remove(objectAtIndex: indexPath.row)
            if let notificationToken = notificationToken {
                try! project.realm?.commitWrite(withoutNotifying: [notificationToken])
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func addBarButtonDidTap(){
        
    }
    
    deinit {
        notificationToken?.stop()
    }
}
