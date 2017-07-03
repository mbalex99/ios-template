//
//  ProjectsListViewController
//  MyApp
//
//  Created by Maximilian Alexander on 7/1/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    var projects: Results<Project>!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white
        title = "Projects"
        
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
        
        projects = Project.myProjectsRealm.objects(Project.self).sorted(byKeyPath: "editedTimestamp", ascending: false)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        notificationToken = projects.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ProjectsListViewController.addBarButtonDidTap))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(ProjectsListViewController.logoutBarButtonDidTap))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath) ?? UITableViewCell()
        let project = projects[indexPath.row]
        cell.textLabel?.text = project.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        let projectItemsViewController = ProjectItemsListViewController(project: project)
        navigationController?.pushViewController(projectItemsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            projects.realm?.beginWrite()
            projects.realm?.delete(projects[indexPath.row])
            if let notificationToken = notificationToken {
                try! projects.realm?.commitWrite(withoutNotifying: [notificationToken])
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func addBarButtonDidTap(){
        let alertController = UIAlertController(title: "Create a Project", message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Your new project name"
        })
        let confirmAction = UIAlertAction(title: "Create", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let newProjectName: String = alertController.textFields?[0].text ?? "New Project"
            
            let realm = Project.myProjectsRealm
            let newProject = Project()
            newProject.name = newProjectName
            try! realm.write {
                realm.create(Project.self, value: newProject)
            }
        })
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: { _ in })
    }
    
    func logoutBarButtonDidTap(){
        let alertController = UIAlertController(title: "Logout?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes, Logout", style: .destructive, handler: { [weak self](_ action: UIAlertAction) -> Void in
            SyncUser.current?.logOut()
            self?.navigationController?.setViewControllers([LoginViewController()], animated: true)
        })
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: { _ in })
    }
    
    deinit {
        notificationToken?.stop()
    }
}
