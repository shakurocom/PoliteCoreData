//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import UIKit
import PoliteCoreData_Framework

class ExampleViewController: UITableViewController {

    private enum TableSection: String, CaseIterable {
        case section1 = "First Section"
        case section2 = "Second Section"
    }

    private let dataStorage: DataStorage = ExamplePoliteCoreData(modelName: "DataModel")

    private let dateFormatter: DateFormatter = DateFormatter()

    private var itemsObserver: FetchedResultsController<CDListItem, ManagedListItem>?

    private var changes: [FetchedResultsControllerChangeType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 50.0
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension

        tableView.sectionHeaderHeight = 30.0
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium

        itemsObserver = dataStorage.itemsObserver()
        itemsObserver?.didChangeContent = { [weak self] _ in
            self?.navigationItem.leftBarButtonItem?.isEnabled = false
            self?.navigationItem.rightBarButtonItem?.isEnabled = false

            let changes = self?.changes ?? []
            self?.tableView.performBatchUpdates({
                changes.forEach { value in
                    switch value {
                    case .insert(let indexPath):
                        self?.tableView.insertRows(at: [indexPath], with: .top)
                    case .delete(let indexPath):
                        self?.tableView.deleteRows(at: [indexPath], with: .top)
                    case .move(let oldIndexPath, let newIndexPath):
                        self?.tableView.deleteRows(at: [oldIndexPath], with: .top)
                        self?.tableView.insertRows(at: [newIndexPath], with: .top)
                    case .update(let indexPath):
                        self?.tableView.reloadRows(at: [indexPath], with: .fade)
                    case .insertSection(let index):
                        self?.tableView.insertSections(IndexSet(integer: index), with: .fade)
                    case .deleteSection(let index):
                        self?.tableView.deleteSections(IndexSet(integer: index), with: .fade)
                    }
                }
            }, completion: { _ in
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                self?.navigationItem.leftBarButtonItem?.isEnabled = true
            })
            self?.changes.removeAll()
        }
        itemsObserver?.didChangeFetchedResults = { [weak self] (_, change) in
            self?.changes.append(change)
        }
        try? itemsObserver?.performFetch()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return itemsObserver?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsObserver?.numberOfItemsInSection(section) ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return itemsObserver?.sectionName(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath)
        if let created = itemsObserver?.itemAtIndexPath(indexPath).created {
            (cell as? ExampleCell)?.setup(dateFormatter.string(from: created))
        }
        return cell
    }
}

private extension ExampleViewController {
    @IBAction private func createItemButtonTapped() {
        let randomSection = TableSection.allCases.randomElement() ?? .section1
        dataStorage.createItem(ListItem(section: randomSection.rawValue))
    }

    @IBAction private func removeItemButtonTapped() {
        guard let sections = itemsObserver?.numberOfSections(), sections > 0 else {
            return
        }

        let section = Int.random(in: 0..<sections)
        guard let rows = itemsObserver?.numberOfItemsInSection(section), rows > 0 else {
            return
        }

        let row = Int.random(in: 0..<rows)
        if let item = itemsObserver?.itemAtIndexPath(IndexPath(row: row, section: section)) {
            dataStorage.removeItem(item)
        }
    }
}
