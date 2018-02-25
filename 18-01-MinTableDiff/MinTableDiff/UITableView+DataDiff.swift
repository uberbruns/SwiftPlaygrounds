//
//  UITableView+Diff.swift
//  MinTableDiff
//
//  Created by Karsten Bruns on 06.02.18.
//  Copyright © 2018 eos.uptrade GmbH. All rights reserved.
//

import UIKit


/// Data representing the content of a table view row.
struct RowData {
    /// The reuse identifier used to register the table view cell.
    var reuseIdentifier: String
    
    /// The identity of the data set. Used to determine if a cell needs to be updated (known identity), inserted (new identity) or deleted (obsolete identity).
    var identity: AnyHashable
    
    /// The data representing the content of a table view row. Different hashes on a known identity, trigger a table view cell reload.
    var data: AnyHashable
}


/// Data representing the content of a table view section.
struct SectionData {
    /// The identity of the section. Used to determine if a section needs to be updated (known identity), inserted (new identity) or deleted (obsolete identity).
    var identity: AnyHashable
    
    /// The data representing the content of a table view section. Different hashes on a known identity, trigger a table view section reload.
    var data: AnyHashable
    
    /// A list of rows displayed in the table view section.
    var rows: [RowData]
}


extension UITableView {
    
    /// Performs an animated batch update on the table view by calculating
    /// the differences between `oldSections` and `newSections`.
    ///
    /// - Parameters:
    ///   - oldSections: An array of `SectionData` representing the current and soon to be old data of displayed content.
    ///   - newSections: An array of `SectionData` representing the new data of displayed content.
    ///   - animated: Pass `true` to see animated table view updated. `False` currently ommits the diffing and just does a `reloadData()`.
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
            // Reload and early return: We do not support moves and double identities
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
            // Remove obsolete sections
            for (oldIndex, oldIdentity) in oldIdentities.enumerated().reversed() {
                if !newIdentities.contains(oldIdentity) {
                    deleteSections(IndexSet(integer: oldIndex), with: .automatic)
                }
            }
            
            // Add or reload new sections and apply row deletions, insertions or reloads
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
    
    /// Calculates the index pathes that need to be deleted, inserted or reloaded.
    ///
    /// - Parameters:
    ///   - oldRows: An array representing the current state of row data.
    ///   - newRows: An array representing the new state of row data.
    ///   - oldSection: An integer with the section index of the `oldRows`.
    ///   - newSection: An integer with the section index of the `newRows`.
    /// - Returns: Returns a 3-part-tuple of index path lists (deletions, insetions, reloads).
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
    
    /// A convenience subscript that allows access to `RowData` in an array of `SectionData`
    ///
    /// - Parameter indexPath: The indexPath to the row data.
    subscript(indexPath indexPath: IndexPath) -> RowData {
        get {
            return self[indexPath.section].rows[indexPath.row]
        }
    }
}
