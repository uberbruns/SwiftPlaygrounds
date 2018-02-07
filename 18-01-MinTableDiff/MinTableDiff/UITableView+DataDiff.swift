//
//  UITableView+Diff.swift
//  MinTableDiff
//
//  Created by Karsten Bruns on 06.02.18.
//  Copyright © 2018 eos.uptrade GmbH. All rights reserved.
//

import UIKit


struct RowData {
    var reuseIdentifier: String
    var identity: AnyHashable
    var data: AnyHashable
}


struct SectionData {
    var reuseIdentifier: String
    var identity: AnyHashable
    var data: AnyHashable
    var rows: [RowData]
}


extension UITableView {
    
    func reloadData(oldSections: [SectionData], newSections: [SectionData], animated: Bool) {
        guard animated else {
            reloadData()
            return
        }
        
        // Build identities
        let newIdentities = newSections.map({ $0.identity })
        let oldIdentities = oldSections.map({ $0.identity })
        
        // Check for movements and double identities
        let existingNew = newIdentities.filter({ oldIdentities.contains($0) })
        let remainingOld = oldIdentities.filter({ newIdentities.contains($0) })
        let movedIdentities = existingNew != remainingOld
        let doubleIdentities = newIdentities.count > Set(newIdentities).count
        if  movedIdentities || doubleIdentities {
            // Reload and early return: We no not support moves and double identities
            reloadData()
            return
        }
        
        // Get index pathes for row updates
        var updatePathesPerSection = [Int: ([IndexPath], [IndexPath], [IndexPath])]()
        for (newIndex, newIdentity) in newIdentities.enumerated() {
            if let oldIndex = oldIdentities.index(of: newIdentity) {
                let newSection = newSections[newIndex]
                let oldSection = oldSections[oldIndex]
                if let updatePathes = updatePaths(oldRows: oldSection.rows, newRows: newSection.rows, oldSection: oldIndex, newSection: newIndex) {
                    updatePathesPerSection[newIndex] = updatePathes
                } else {
                    reloadData()
                    return
                }
            }
        }
        
        // Update table view
        performBatchUpdates({
            // Remove obsolete items
            for (oldIndex, oldIdentity) in oldIdentities.enumerated().reversed() {
                if !newIdentities.contains(oldIdentity) {
                    deleteSections(IndexSet(integer: oldIndex), with: .automatic)
                }
            }
            
            // Add or reload new items
            for (newIndex, newIdentity) in newIdentities.enumerated() {
                let newSection = newSections[newIndex]
                if let oldIndex = oldIdentities.index(of: newIdentity) {
                    let oldSection = oldSections[oldIndex]
                    if newSection.data != oldSection.data {
                        reloadSections(IndexSet(integer: newIndex), with: .automatic)
                    }
                    if let updatePathes = updatePathesPerSection[newIndex] {
                        deleteRows(at: updatePathes.0, with: .automatic)
                        insertRows(at: updatePathes.1, with: .automatic)
                        reloadRows(at: updatePathes.2, with: .automatic)
                    }
                } else {
                    insertSections(IndexSet(integer: newIndex), with: .automatic)
                }
            }
        }, completion: nil)
    }
    
    private func updatePaths(oldRows: [RowData], newRows: [RowData], oldSection: Int, newSection: Int) -> ([IndexPath], [IndexPath], [IndexPath])? {
        // Build identities
        let newIdentities = newRows.map({ $0.identity })
        let oldIdentities = oldRows.map({ $0.identity })
        
        // Check if items are valid
        let existingNew = newIdentities.filter({ oldIdentities.contains($0) })
        let remainingOld = oldIdentities.filter({ newIdentities.contains($0) })
        let movedIdentities = existingNew != remainingOld
        let doubleIdentities = newIdentities.count > Set(newIdentities).count
        if  movedIdentities || doubleIdentities {
            return nil
        }
        
        var deleteIndexPaths = [IndexPath]()
        var insertIndexPaths = [IndexPath]()
        var reloadIndexPaths = [IndexPath]()
        
        // Remove obsolete items
        for (oldIndex, oldIdentity) in oldIdentities.enumerated().reversed() {
            if !newIdentities.contains(oldIdentity) {
                deleteIndexPaths.append(IndexPath(row: oldIndex, section: oldSection))
            }
        }
        
        // Add or reload new items
        for (newIndex, newIdentity) in newIdentities.enumerated() {
            let newRow = newRows[newIndex]
            if let oldIndex = oldIdentities.index(of: newIdentity) {
                let oldRow = oldRows[oldIndex]
                if newRow.data != oldRow.data {
                    reloadIndexPaths.append(IndexPath(row: newIndex, section: newSection))
                }
            } else {
                insertIndexPaths.append(IndexPath(row: newIndex, section: newSection))
            }
        }
        
        return (deleteIndexPaths, insertIndexPaths, reloadIndexPaths)
    }
}


extension Array where Element == SectionData {
    
    subscript(indexPath indexPath: IndexPath) -> RowData {
        get {
            return self[indexPath.section].rows[indexPath.row]
        }
    }
}
