//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

import Foundation
import UIKit
import PoliteCoreData_Framework

internal class ExampleCoreDataViewController: UIViewController {

    class func instantiate(_ storage: DataStorage) -> ExampleCoreDataViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller: ExampleCoreDataViewController = storyboard.instantiateViewController(withIdentifier: "ExampleCoreDataViewController")

        controller.storage = storage

        return controller
    }

    @IBOutlet private var contentTableView: UITableView!

    private var storage: DataStorage?
    private var exampleFetchedResultController: FetchedResultsController<CDExampleEntity, ManagedExampleEntity>?
    private var changes: [FetchedResultsControllerChange] = []

    private enum Constant {
        static let cellReuseIdentifier: String = "UITableViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Core Data", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))

        exampleFetchedResultController = storage?.exampleFetchedResultController()

        exampleFetchedResultController?.willChangeContent = { (_) in }

        exampleFetchedResultController?.didChangeEntity = {[weak self] (_, changeType) in
            guard let actualSelf = self else {
                return
            }
            actualSelf.changes.append(changeType)
        }
        exampleFetchedResultController?.didChangeContent = {[weak self] (_) in
            guard let actualSelf = self else {
                return
            }
            actualSelf.applyChanges()
        }
        do {
            try exampleFetchedResultController?.performFetch()
        } catch let error {
            assertionFailure("\(type(of: self)) - \(#function): . \(error)")
        }
        contentTableView.reloadData()
    }

}

extension ExampleCoreDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleFetchedResultController?.numberOfItemsInSection(section) ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return exampleFetchedResultController?.numberOfSections() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(indexPath: indexPath, reuseIdentifier: Constant.cellReuseIdentifier)
        if let item = exampleFetchedResultController?.item(indexPath: indexPath) {
            cell.textLabel?.text = item.identifier
            cell.detailTextLabel?.text = "createdAt: \(item.createdAt); updatedAt: \(item.updatedAt)"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
            self?.deleteItem(at: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - Private

private extension ExampleCoreDataViewController {
    @objc func addButtonPressed() {
        storage?.insertLastItem()
    }

    func deleteItem(at indexPath: IndexPath) {
        if let item = exampleFetchedResultController?.item(indexPath: indexPath) {
            storage?.deleteItem(item.identifier)
        }
    }

    func applyChanges() {
        if view.window == nil {
            contentTableView.reloadData()
        } else {
            contentTableView.beginUpdates()
            changes.forEach { (value) in
                switch value {
                case .insert(let indexPath):
                    contentTableView.insertRows(at: [indexPath], with: .fade)
                case .delete(let indexPath):
                    contentTableView.deleteRows(at: [indexPath], with: .fade)
                case .move(let indexPath, let newIndexPath):
                    contentTableView.deleteRows(at: [indexPath], with: .fade)
                    contentTableView.insertRows(at: [newIndexPath], with: .fade)
                case .update(let indexPath):
                    contentTableView.reloadRows(at: [indexPath], with: .fade)
                case .insertSection(let index):
                    contentTableView.insertSections(IndexSet(integer: index), with: .fade)
                case .deleteSection(let index):
                    contentTableView.deleteSections(IndexSet(integer: index), with: .fade)
                }
            }
            contentTableView.endUpdates()
        }
        changes.removeAll()
    }
}
