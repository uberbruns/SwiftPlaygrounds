//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, CollectionViewFillLayoutDelegate {

    enum Sections: CaseIterable {
        case flexibleTop
        case items
        case flexibleBottom
        case actions

        enum Actions: CaseIterable {
            case add
            case remove
        }
    }

    private var numberOfItems = 5
    private let layout = CollectionViewFillLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .lightGray
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(FlexibleCollectionViewCell.self, forCellWithReuseIdentifier: "flex")

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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Sections.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Sections.allCases[section] {
        case .items:
            return numberOfItems
        case .actions:
            return Sections.Actions.allCases.count
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch Sections.allCases[indexPath.section] {
        case .flexibleTop, .flexibleBottom:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flex", for: indexPath)
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
        self.collectionView(collectionView, configureCell: cell, forItemAt: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, alignmentForItemAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment {
        switch Sections.allCases[indexPath.section] {
        case .flexibleTop, .flexibleBottom:
            return .flexible
        case .actions:
            return .stickyBottom
        default:
            return .default
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellTypeForItemAt indexPath: IndexPath) -> UICollectionViewCell.Type {
        switch Sections.allCases[indexPath.section] {
        case .flexibleTop, .flexibleBottom:
            return FlexibleCollectionViewCell.self
        default:
            return TextCollectionViewCell.self
        }
    }

    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch (cell, Sections.allCases[indexPath.section]) {
        case (let cell as FlexibleCollectionViewCell, .flexibleTop), (let cell as FlexibleCollectionViewCell, .flexibleBottom):
            cell.contentView.backgroundColor = .lightGray

        case (let cell as TextCollectionViewCell, .actions):
            switch Sections.Actions.allCases[indexPath.row] {
            case .add:
                cell.titleLabel.text = "Add"
                cell.contentView.backgroundColor = .green
            case .remove:
                cell.titleLabel.text = "Remove"
                cell.contentView.backgroundColor = .red
            }

        case (let cell as TextCollectionViewCell, _):
            cell.titleLabel.text = "Sie sagen es kommt die Zeit in der Pole schmelzen, sich riesen Wassermassen über Küstenstädte wälzen."
            cell.contentView.backgroundColor = .yellow

        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Sections.allCases[indexPath.section] {
        case .actions:
            switch Sections.Actions.allCases[indexPath.row] {
            case .add:
                numberOfItems += 1
            case .remove:
                numberOfItems -= 1
            }
            collectionView.reloadData()
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, minimumHeightForItemAt indexPath: IndexPath) -> CGFloat {
        switch Sections.allCases[indexPath.section] {
        case .flexibleTop, .flexibleBottom:
            return 0
        default:
            return 66
        }
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
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
        ])
    }
}


class FlexibleCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
