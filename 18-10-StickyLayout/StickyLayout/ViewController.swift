//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class CollectionViewFillLayout: UICollectionViewLayout {

    private var cachedLayoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedContentSize = CGSize.zero
    private var cachedBounds = CGRect.zero

    override func prepare() {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? CollectionViewFillLayoutDelegate else { return }

        if collectionView.bounds.size != cachedBounds.size {
            invalidateCachedAttributes()
        }

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let itemRange = 0..<numberOfItems
        let items = itemRange.lazy.map { (number: Int) -> FillLayout.Item<IndexPath> in
            let indexPath = IndexPath(item: number, section: 0)

            // Item Alignment
            let alignment = delegate.collectionView(collectionView, alignmentForItemAt: indexPath)

            // Item Size
            let cellSize: CGSize
            if let itemAttributes = self.cachedLayoutAttributes[indexPath] {
                cellSize = itemAttributes.frame.size
            } else {
                // Getting cell size be configuring
                let cellType = delegate.collectionView(collectionView, cellTypeForItemAt: indexPath)
                let cell = cellType.init(frame: CGRect.zero)
                delegate.collectionView(collectionView, configureCell: cell, forItemAt: indexPath)
                let maximumCellSize = CGSize(width: collectionView.bounds.width, height: .greatestFiniteMagnitude)
                cellSize = cell.contentView.systemLayoutSizeFitting(maximumCellSize,
                                                                    withHorizontalFittingPriority: .required,
                                                                    verticalFittingPriority: UILayoutPriority(1))
            }

            return FillLayout.Item(with: indexPath, height: cellSize.height, alignment: alignment)
        }

        // Solve layout
        let bounds = collectionView.bounds
        let result = FillLayout.solve(with: items, inside: bounds, offset: collectionView.contentOffset.y, safeArea: collectionView.safeAreaInsets)
        cachedContentSize = result.contentSize

        // Build layout attributes
        invalidateCachedAttributes()
        for positioning in result.positionings {
            let indexPath = positioning.object
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.frame = positioning.frame
            itemAttributes.zIndex = positioning.alignment == .stickyBottom ? 1 : 0
            cachedLayoutAttributes[indexPath] = itemAttributes
        }

        // Cache
        cachedBounds = collectionView.bounds

        // Configure collection view
        collectionView.scrollIndicatorInsets.bottom = result.stickyBottomHeight
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        invalidateCachedAttributes()
        super.prepare(forCollectionViewUpdates: updateItems)
    }


    override var collectionViewContentSize: CGSize {
        return cachedContentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedLayoutAttributes.values.filter { $0.frame.intersects(rect) }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if context.invalidateEverything {
            invalidateCachedAttributes()
        }
    }

    private func invalidateCachedAttributes() {
        cachedLayoutAttributes.removeAll(keepingCapacity: true)
    }
}


protocol CollectionViewFillLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellTypeForItemAt indexPath: IndexPath) -> UICollectionViewCell.Type
    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> FillLayout.Alignment
}


class ViewController: UIViewController, UICollectionViewDataSource, CollectionViewFillLayoutDelegate {

    private let layout = CollectionViewFillLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    var i = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .red
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])

    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return i
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        self.collectionView(collectionView, configureCell: cell, forItemAt: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> FillLayout.Alignment {
        switch indexPath.row {
        case 0:
            return .stickyBottom
        case 1:
            return .stickyBottom
        case 2:
            return .flexible
        case i-1:
            return .flexible
        default:
            return .default
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellTypeForItemAt indexPath: IndexPath) -> UICollectionViewCell.Type {
        return TextCollectionViewCell.self
    }

    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cell {
        case let cell as TextCollectionViewCell:
            cell.titleLabel.text = "Sie sagen es kommt die Zeit in der Pole schmelzen, sich riesen Wassermassen über Küstenstädte wälzen."
        default:
            break
        }

        switch indexPath.row {
        case 0:
            cell.contentView.backgroundColor = .darkGray
        case 1:
            cell.contentView.backgroundColor = .black
        case 2:
            cell.contentView.backgroundColor = .lightGray
        case i-1:
            cell.contentView.backgroundColor = .lightGray
        default:
            cell.contentView.backgroundColor = .yellow
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            i -= 1
        } else {
            i += 1
        }
        collectionView.reloadData()
    }
}


class TextCollectionViewCell: UICollectionViewCell {

    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])
    }
}

