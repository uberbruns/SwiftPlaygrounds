//
//  CollectionViewFillLayout.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 29.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


protocol CollectionViewDataSourceFillLayout: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellTypeAt indexPath: IndexPath) -> UICollectionViewCell.Type
    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, for indexPath: IndexPath)

    func collectionView(_ collectionView: UICollectionView, supplementaryViewTypeAt indexPath: IndexPath, position: CollectionViewFillLayout.SupplementaryViewPosition) -> UICollectionReusableView.Type?
    func collectionView(_ collectionView: UICollectionView, configureSupplementaryView view: UICollectionReusableView, for indexPath: IndexPath, position: CollectionViewFillLayout.SupplementaryViewPosition)
}


protocol CollectionViewDelegateFillLayout: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, alignmentForCellAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment
    func collectionView(_ collectionView: UICollectionView, minimumHeightForCellAt indexPath: IndexPath) -> CGFloat

    func collectionView(_ collectionView: UICollectionView, alignmentForSupplementaryViewAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment
    func collectionView(_ collectionView: UICollectionView, minimumHeightForSupplementaryViewAt indexPath: IndexPath) -> CGFloat
}


class CollectionViewFillLayout: UICollectionViewLayout {

    // MARK: Properties

    // State
    private var insertedDeletedOrMovedIndexPaths = Set<IndexPath>()
    var invalidateEverything = true

    // Cache
    private var cachedContentSize = CGSize.zero
    private var cachedBounds = CGRect.zero
    private var cachedLayoutAttributes = [TaggedIndexPath: UICollectionViewLayoutAttributes]()

    // Configuration
    var automaticallyAdjustScrollIndicatorInsets = true

    
    // MARK: Preparations

    override func prepare() {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? CollectionViewDelegateFillLayout & CollectionViewDataSourceFillLayout else { return }

        // Cache invalidation
        if invalidateEverything || collectionView.bounds.size != cachedBounds.size {
            invalidateCachedLayoutAttributes()
        }

        // Build an array of index paths
        var layoutItems = [CollectionViewFillLayout.Item<TaggedIndexPath>]()
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                for tag in [TaggedIndexPath.Tag.before, .item, .after] {
                    let indexPath = TaggedIndexPath(item: item, section: section, tag: tag)

                    // Item size
                    let cellSize: CGSize
                    if let itemAttributes = self.cachedLayoutAttributes[indexPath] {
                        cellSize = itemAttributes.frame.size
                    } else {
                        // Getting cell size be configuring
                        let contentView: UIView
                        let minimumHeight: CGFloat
                        switch tag {
                        case .before, .after:
                            guard let viewType = delegate.collectionView(collectionView, supplementaryViewTypeAt: indexPath.native, position: .init(tag: tag)) else {
                                continue
                            }
                            let supplementaryView = viewType.init(frame: .zero)
                            minimumHeight = delegate.collectionView(collectionView, minimumHeightForSupplementaryViewAt: indexPath.native)
                            delegate.collectionView(collectionView, configureSupplementaryView: supplementaryView, for: indexPath.native, position: .init(tag: tag))
                            contentView = supplementaryView
                        case .item:
                            let cellType = delegate.collectionView(collectionView, cellTypeAt: indexPath.native)
                            let cell = cellType.init(frame: .zero)
                            minimumHeight = delegate.collectionView(collectionView, minimumHeightForCellAt: indexPath.native)
                            delegate.collectionView(collectionView, configureCell: cell, for: indexPath.native)
                            contentView = cell.contentView
                        }

                        NSLayoutConstraint.activate([
                            { $0.priority = .defaultLow; return $0 }(contentView.heightAnchor.constraint(equalToConstant: minimumHeight)),
                            { $0.priority = .defaultHigh; return $0 }(contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight)),
                            ])

                        let maximumCellSize = CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
                        cellSize = contentView.systemLayoutSizeFitting(maximumCellSize,
                                                                       withHorizontalFittingPriority: .required,
                                                                       verticalFittingPriority: UILayoutPriority(1))
                    }

                    // Item alignment
                    let alignment: CollectionViewFillLayout.Alignment
                    switch tag {
                    case .before, .after:
                        alignment = delegate.collectionView(collectionView, alignmentForSupplementaryViewAt: indexPath.native)
                    case .item:
                        alignment = delegate.collectionView(collectionView, alignmentForCellAt: indexPath.native)
                    }

                    let layoutItem = CollectionViewFillLayout.Item(with: indexPath, height: cellSize.height, alignment: alignment)
                    layoutItems.append(layoutItem)
                }
            }
        }

        // Solve layout
        let bounds = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        let result = CollectionViewFillLayout.solve(with: layoutItems,
                                                    inside: bounds,
                                                    offset: collectionView.contentOffset.y,
                                                    clipOffset: invalidateEverything,
                                                    contentInsets: collectionView.adjustedContentInset)

        // Cache
        cachedBounds = collectionView.bounds
        cachedContentSize = result.contentSize
        invalidateCachedLayoutAttributes()

        for (index, positioning) in result.positionings.enumerated() {
            let indexPath = positioning.object
            let itemAttributes = UICollectionViewLayoutAttributes(taggedIndexPath: indexPath)
            itemAttributes.frame = positioning.frame
            itemAttributes.zIndex = positioning.alignment == .pinnedToBottom ? index + 1000 : index
            cachedLayoutAttributes[indexPath] = itemAttributes
        }

        // Reset state
        invalidateEverything = false

        // Configure collection view
        collectionView.isPrefetchingEnabled = false // Removing this or setting it to true -> Dragons (Invisible and/or unresponsive cells when bounds are changing)
        if automaticallyAdjustScrollIndicatorInsets {
            collectionView.scrollIndicatorInsets.bottom = result.stickyBottomHeight
        }
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        invalidateCachedLayoutAttributes()
        insertedDeletedOrMovedIndexPaths.removeAll()

        for updatedItem in updateItems {
            switch updatedItem.updateAction {
            case .insert:
                insertedDeletedOrMovedIndexPaths.insert(updatedItem.indexPathAfterUpdate!)
            case .delete:
                insertedDeletedOrMovedIndexPaths.insert(updatedItem.indexPathBeforeUpdate!)
            case .move:
                insertedDeletedOrMovedIndexPaths.insert(updatedItem.indexPathAfterUpdate!)
                insertedDeletedOrMovedIndexPaths.insert(updatedItem.indexPathBeforeUpdate!)
            case .reload:
                break
            default:
                break
            }
        }
    }


    // MARK: Invalidation

    func invalidateCellSizes() {
        invalidateEverything = true
        invalidateLayout()
    }

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
        let layoutAttributes = cachedLayoutAttributes[itemIndexPath.tagged(with: .item)]
        if insertedDeletedOrMovedIndexPaths.contains(itemIndexPath) {
            layoutAttributes?.alpha = 0
            insertedDeletedOrMovedIndexPaths.remove(itemIndexPath)
        }
        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cachedLayoutAttributes[itemIndexPath.tagged(with: .item)]
        if insertedDeletedOrMovedIndexPaths.contains(itemIndexPath) {
            layoutAttributes?.alpha = 0
            insertedDeletedOrMovedIndexPaths.remove(itemIndexPath)
        }
        return layoutAttributes
    }

    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cachedLayoutAttributes[elementIndexPath.tagged(with: CollectionViewFillLayout.TaggedIndexPath.Tag.init(rawValue: elementKind)!)]
        if insertedDeletedOrMovedIndexPaths.contains(elementIndexPath) {
            layoutAttributes?.alpha = 0
            insertedDeletedOrMovedIndexPaths.remove(elementIndexPath)
        }
        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cachedLayoutAttributes[elementIndexPath.tagged(with: CollectionViewFillLayout.TaggedIndexPath.Tag.init(rawValue: elementKind)!)]
        if insertedDeletedOrMovedIndexPaths.contains(elementIndexPath) {
            layoutAttributes?.alpha = 0
            insertedDeletedOrMovedIndexPaths.remove(elementIndexPath)
        }
        return layoutAttributes
    }
}


extension CollectionViewFillLayout {
    fileprivate struct TaggedIndexPath: Hashable {
        enum Tag: String, Hashable, CaseIterable {
            case before
            case item
            case after
        }

        let item: Int
        let section: Int
        let tag: Tag
        let native: IndexPath

        init(item: Int, section: Int, tag: Tag) {
            self.item = item
            self.section = section
            self.tag = tag
            self.native = IndexPath(item: item, section: section)
        }
    }

    enum SupplementaryViewPosition: String {
        case before
        case after

        fileprivate init(tag: TaggedIndexPath.Tag) {
            switch tag {
            case .after:
                self = .after
            default:
                self = .before
            }
        }
    }
}


private extension UICollectionViewLayoutAttributes {
    convenience init(taggedIndexPath: CollectionViewFillLayout.TaggedIndexPath) {
        switch taggedIndexPath.tag {
        case .before, .after:
            self.init(forSupplementaryViewOfKind: CollectionViewFillLayout.SupplementaryViewPosition(tag: taggedIndexPath.tag).rawValue, with: taggedIndexPath.native)
        case .item:
            self.init(forCellWith: taggedIndexPath.native)
        }
    }
}


private extension IndexPath {
    func tagged(with tag: CollectionViewFillLayout.TaggedIndexPath.Tag) -> CollectionViewFillLayout.TaggedIndexPath {
        return CollectionViewFillLayout.TaggedIndexPath.init(item: item, section: section, tag: tag)
    }
}
