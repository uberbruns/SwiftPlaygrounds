//
//  CollectionViewFillLayout.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 29.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


protocol CollectionViewFillLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellTypeForItemAt indexPath: IndexPath) -> UICollectionViewCell.Type
    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment
    func collectionView(_ collectionView: UICollectionView, minimumHeightForItemAt indexPath: IndexPath) -> CGFloat
}


class CollectionViewFillLayout: UICollectionViewLayout {

    private var cachedLayoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var insertedDeletedOrMovedIndexPaths = Set<IndexPath>()
    private var cachedContentSize = CGSize.zero
    private var cachedBounds = CGRect.zero
    private var invalidateEverything = true


    // MARK: Preparations

    override func prepare() {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? CollectionViewFillLayoutDelegate else { return }

        // Cache invalidation
        if invalidateEverything || collectionView.bounds.size != cachedBounds.size {
            invalidateCachedLayoutAttributes()
        }

        // Build an array of index paths
        var indexPaths = [IndexPath]()
        for section in 0..<collectionView.numberOfSections {
            let items = 0..<collectionView.numberOfItems(inSection: section)
            indexPaths += items.map { IndexPath(item: $0, section: section) }
        }

        // Map index paths to Fill Layout Items
        let items = indexPaths.lazy.map { (indexPath: IndexPath) -> CollectionViewFillLayout.Item<IndexPath> in
            // Item alignment
            let alignment = delegate.collectionView(collectionView, alignmentForItemAt: indexPath)

            // Item size
            let cellSize: CGSize
            if let itemAttributes = self.cachedLayoutAttributes[indexPath] {
                cellSize = itemAttributes.frame.size
            } else {
                // Getting cell size be configuring
                let cellType = delegate.collectionView(collectionView, cellTypeForItemAt: indexPath)
                let cell = cellType.init(frame: CGRect.zero)
                let minimumHeight = delegate.collectionView(collectionView, minimumHeightForItemAt: indexPath)
                delegate.collectionView(collectionView, configureCell: cell, forItemAt: indexPath)

                NSLayoutConstraint.activate([
                    { $0.priority = .defaultLow; return $0 }(cell.contentView.heightAnchor.constraint(equalToConstant: minimumHeight)),
                    { $0.priority = .defaultHigh; return $0 }(cell.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight)),
                ])

                let maximumCellSize = CGSize(width: collectionView.bounds.width, height: .greatestFiniteMagnitude)
                cellSize = cell.contentView.systemLayoutSizeFitting(maximumCellSize,
                                                                    withHorizontalFittingPriority: .required,
                                                                    verticalFittingPriority: UILayoutPriority(1))
            }

            return CollectionViewFillLayout.Item(with: indexPath, height: cellSize.height, alignment: alignment)
        }

        // Solve layout
        let bounds = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        let result = CollectionViewFillLayout.solve(with: items,
                                                    inside: bounds,
                                                    offset: collectionView.contentOffset.y,
                                                    clipOffset: invalidateEverything,
                                                    safeArea: collectionView.safeAreaInsets)

        // Cache
        cachedBounds = collectionView.bounds
        cachedContentSize = result.contentSize
        invalidateCachedLayoutAttributes()

        for (index, positioning) in result.positionings.enumerated() {
            let indexPath = positioning.object
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.frame = positioning.frame
            itemAttributes.zIndex = positioning.alignment == .stickyBottom ? index + 1000 : index
            cachedLayoutAttributes[indexPath] = itemAttributes
        }

        // Reset state
        invalidateEverything = false

        // Configure collection view
        collectionView.isPrefetchingEnabled = false // Removing this or setting it to true -> Dragons (Invisible and/or unresponsive cells when bounds are changing)
        collectionView.scrollIndicatorInsets.bottom = result.stickyBottomHeight
    }

    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        insertedDeletedOrMovedIndexPaths.removeAll()
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                insertedDeletedOrMovedIndexPaths.insert(updateItem.indexPathAfterUpdate!)
            case .delete:
                insertedDeletedOrMovedIndexPaths.insert(updateItem.indexPathBeforeUpdate!)
            case .move:
                insertedDeletedOrMovedIndexPaths.insert(updateItem.indexPathAfterUpdate!)
                insertedDeletedOrMovedIndexPaths.insert(updateItem.indexPathBeforeUpdate!)
            default:
                break
            }
        }
    }


    // MARK: Invalidation

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if context.invalidateEverything {
            invalidateEverything = true
            invalidateCachedLayoutAttributes()
        }
    }

    private func invalidateCachedLayoutAttributes() {
        cachedLayoutAttributes.removeAll(keepingCapacity: true)
    }


    // MARK: Layout

    override var collectionViewContentSize: CGSize {
        return cachedContentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedLayoutAttributes.values.filter {
            $0.frame.intersects(rect)
        }
    }


    // MARK: Animation

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cachedLayoutAttributes[itemIndexPath]
        if insertedDeletedOrMovedIndexPaths.contains(itemIndexPath) {
            layoutAttributes?.alpha = 0
            insertedDeletedOrMovedIndexPaths.remove(itemIndexPath)
        }
        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cachedLayoutAttributes[itemIndexPath]
        if insertedDeletedOrMovedIndexPaths.contains(itemIndexPath) {
            layoutAttributes?.alpha = 0
            insertedDeletedOrMovedIndexPaths.remove(itemIndexPath)
        }
        return layoutAttributes
    }
}
