//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, CollectionViewFillLayoutDelegate {

    private let layout = CollectionViewFillLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    var numberOfItems = 5

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
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        self.collectionView(collectionView, configureCell: cell, forItemAt: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment {
        switch indexPath.row {
        case 0:
            return .flexible
        case numberOfItems-3:
            return .flexible
        case numberOfItems-2:
            return .stickyBottom
        case numberOfItems-1:
            return .stickyBottom
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
            cell.contentView.backgroundColor = .white
        case numberOfItems-3:
            cell.contentView.backgroundColor = .white
        case numberOfItems-2:
            cell.contentView.backgroundColor = .lightGray
        case numberOfItems-1:
            cell.contentView.backgroundColor = .darkGray
        default:
            cell.contentView.backgroundColor = .yellow
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == numberOfItems-1 {
            numberOfItems -= 1
        } else {
            numberOfItems += 1
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
