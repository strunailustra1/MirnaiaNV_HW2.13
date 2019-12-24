//
//  ViewController.swift
//  MirnaiaNV_HW2.13
//
//  Created by Наталья Мирная on 24/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let taskRepository = TaskRepository.instance
    private let cellID = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tasks = taskRepository.fetchAll()
    }

    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = "Task list"
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor(
                displayP3Red: 21/255,
                green: 101/255,
                blue: 192/255,
                alpha: 194/255
            )
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
            // Add button to navigation bar
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addNewTask))
            
            navigationController?.navigationBar.tintColor = .white
        }
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New task", message: "What do you want to do?", saveActionHandler: { (taskText) in
            guard let task = self.taskRepository.create(taskName: taskText) else { return }
            self.tasks.append(task)
            let cellIndex = IndexPath(row: self.tasks.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        })
    }
}

// MARK: - Table View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
}

// MARK: - Table View Delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var contextualActions: [UIContextualAction] = []

        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completionHandler) in
            self.showAlert(
                title: "Edit task",
                message: "What do you want change?",
                saveActionHandler: { (newTaskName) in
                    let task = self.tasks[indexPath.row]
                    if self.taskRepository.update(task: task, newName: newTaskName) {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                },
                textFieldConfigurationHandler: { (textField) in
                    textField.text = self.tasks[indexPath.row].name
                }
            )
        })
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let task = self.tasks[indexPath.row]
            if self.taskRepository.delete(task) {
                self.tasks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        contextualActions.append(editAction)
        contextualActions.append(deleteAction)
        
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: contextualActions)
        swipeActionsConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeActionsConfiguration
    }
}

// MARK: - Alert controller
extension TaskListViewController {
    private func showAlert(title: String, message: String, saveActionHandler: @escaping ((String) -> Void), textFieldConfigurationHandler: ((UITextField) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }
            saveActionHandler(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField(configurationHandler: textFieldConfigurationHandler)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
