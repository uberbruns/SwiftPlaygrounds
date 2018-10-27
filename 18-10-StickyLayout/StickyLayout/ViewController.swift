//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class CollectionViewFillLayout: UICollectionViewLayout {

    var attributes = [UICollectionViewLayoutAttributes]()
    var contentSize = CGSize.zero

    override func prepare() {
        guard let collectionView = collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)

        let numbers = 0..<numberOfItems

        let items = numbers.lazy.map { (number: Int) -> FillLayout.Item<IndexPath> in
            let indexPath = IndexPath(item: number, section: 0)
            let alignment: FillLayout.Alignment
            if let delegate = collectionView.delegate as? CollectionViewFillLayoutDelegate {
                alignment = delegate.collectionView(collectionView, alignmentForItemAt: indexPath)
            } else {
                alignment = .top
            }
            return FillLayout.Item(with: indexPath, height: 88, alignment: alignment)
        }

        let result = FillLayout.solve(with: items, inside: collectionView.bounds, offset: collectionView.contentOffset.y)
        contentSize = result.contentSize

        attributes = result.positionings.map { positioning in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: positioning.object)
            attributes.frame = positioning.frame
            attributes.zIndex = positioning.alignment == .bottom ? 1 : 0
            return attributes
        }
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $0.frame.intersects(rect) }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


protocol CollectionViewFillLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> FillLayout.Alignment
}


class ViewController: UIViewController, UICollectionViewDataSource, CollectionViewFillLayoutDelegate {

    private let layout = CollectionViewFillLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .red
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.backgroundColor = .blue
        case 1:
            cell.backgroundColor = .yellow
        case 2:
            cell.backgroundColor = .purple
        case 3:
            cell.backgroundColor = .black
        case 4:
            cell.backgroundColor = .green
        default:
            cell.backgroundColor = .orange
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> FillLayout.Alignment {
        switch indexPath.row {
        case 2:
            return .flexible
        case 3:
            return .bottom
        case 4:
            return .bottom
        default:
            return .top
        }
    }
}

