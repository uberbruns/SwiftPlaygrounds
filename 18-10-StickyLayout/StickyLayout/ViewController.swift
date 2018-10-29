//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, CollectionViewFillLayoutDelegate {

    enum Sections: Int, CaseIterable {
        case flexibleTop
        case items
        case input
        case flexibleBottom
        case actions

        enum Actions: Int, CaseIterable {
            case add
            case remove
        }
    }

    private var numberOfItems = 5
    private var text = ""
    private let layout = CollectionViewFillLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboardLayoutGuide = KeyboardLayoutGuide()
        view.addLayoutGuide(keyboardLayoutGuide)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .darkGray
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(FlexibleCollectionViewCell.self, forCellWithReuseIdentifier: "flex")
        collectionView.register(InputCollectionViewCell.self, forCellWithReuseIdentifier: "input")

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            keyboardLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardLayoutGuide.heightConstraint
        ])
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
        case .actions, .items:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        case .input:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "input", for: indexPath)
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
        case .actions, .items:
            return TextCollectionViewCell.self
        case .input:
            return InputCollectionViewCell.self
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

        case (let cell as InputCollectionViewCell, _):
            cell.contentView.backgroundColor = .purple
            cell.textField.text = text
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldDidEdit), for: .allEditingEvents)

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
            return 12
        default:
            return 66
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Fixes a bug where some cells are not visible after the collection bounds change
        cell.layer.isHidden = false
    }
}


extension ViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: Sections.input.rawValue), at: .top, animated: true)
//        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func textFieldDidEdit(_ textField: UITextField) {
        text = textField.text ?? ""
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


class InputCollectionViewCell: UICollectionViewCell {

    let textField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHidden: Bool {
        didSet {

        }
    }

    func setupViews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        contentView.addSubview(textField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 32),
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
