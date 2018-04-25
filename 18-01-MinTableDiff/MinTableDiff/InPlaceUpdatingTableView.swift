//
//  InPlaceUpdatingTableView.swift
//  MinTableDiff
//
//  Created by Karsten Bruns on 06.02.18.
//  Copyright © 2018 eos.uptrade GmbH. All rights reserved.
//

import UIKit


protocol InPlaceUpdatingTableViewDataSource: class {
    func tableView(_ tableView: UITableView, updateCell: UITableViewCell, at indexPath: IndexPath) -> Bool
}


class InPlaceUpdatingTableView: UITableView {
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        guard let dataSource = dataSource as? InPlaceUpdatingTableViewDataSource else {
            super.reloadRows(at: indexPaths, with: animation)
            return
        }
        
        var normallyReloadedRows = indexPaths
        let visibleRows = Set(indexPathsForVisibleRows ?? [])
        
        for indexPath in visibleRows.intersection(indexPaths) {
            guard let cell = cellForRow(at: indexPath) else { continue }
            let cellWasUpdated = dataSource.tableView(self, updateCell: cell, at: indexPath)
            if cellWasUpdated, let index = normallyReloadedRows.index(of: indexPath) {
                normallyReloadedRows.remove(at: index)
            }
        }
        
        super.reloadRows(at: normallyReloadedRows, with: animation)
    }
}
