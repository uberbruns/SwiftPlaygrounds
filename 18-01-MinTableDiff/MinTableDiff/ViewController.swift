//
//  ViewController.swift
//  MinTableDiff
//
//  Created by Karsten Bruns on 06.02.18.
//  Copyright © 2018 eos.uptrade GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    let tableView = InPlaceUpdatingTableView(frame: .zero, style: .grouped)
    var sections = [SectionData]()
    var nextGen = true
    var firstNames = false

    // MARK: - View lifecycle
    
    override func loadView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Setup navigation bar
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Names", style: .plain, target: self, action: #selector(handleFirstNameButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "NextGen", style: .plain, target: self, action: #selector(handleNextGenButton))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView(animated: false)
    }

    // MARK: - Update

    func updateView(animated: Bool) {
        let picard = RowData(reuseIdentifier: "cell", identity: "picard", data: firstNames ? "Jean-Luc" : "Picard")
        let sisko = RowData(reuseIdentifier: "cell", identity: "sisko", data: firstNames ? "Benjamin" : "Sisko")
        let janeway = RowData(reuseIdentifier: "cell", identity: "janeway", data: firstNames ? "Kathrin" : "Janeway")
        let archer = RowData(reuseIdentifier: "cell", identity: "archer", data: firstNames ? "Jonathan" : "Archer")
        let kirk = RowData(reuseIdentifier: "cell", identity: "kirk", data: firstNames ? "James T." : "Kirk")

        let oldSections = sections
        let rows: [RowData]
        if nextGen {
            rows = [picard, kirk, sisko, archer, janeway]
        } else {
            rows = [picard, sisko, janeway]
        }
        let newSections = [SectionData(reuseIdentifier: "header", identity: "captains", data: firstNames ? "Last Names" : "Last Names", rows: rows)]
        
        sections = newSections
        tableView.reloadData(oldSections: oldSections, newSections: newSections, animated: animated)
    }

    // MARK: - User interaction handlers

    @objc func handleFirstNameButton() {
        firstNames = !firstNames
        updateView(animated: true)
    }
    
    @objc func handleNextGenButton() {
        nextGen = !nextGen
        updateView(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        
        switch (cell, row.reuseIdentifier, row.data) {
        case (let cell, "cell", let title as String):
            cell.textLabel?.text = title
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionData = sections[section]
        if let title = sectionData.data as? String {
            return title
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath: indexPath]
        print(row.data)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: InPlaceUpdatingTableViewDataSource {
    
    func tableView(_ tableView: UITableView, updateCell cell: UITableViewCell, at indexPath: IndexPath) -> Bool {
        let row = sections[indexPath.section].rows[indexPath.row]
        
        switch (cell, row.reuseIdentifier, row.data) {
        case (let cell, "cell", let title as String):
            cell.textLabel?.text = title
            return true
        default:
            return false
        }
    }
}
