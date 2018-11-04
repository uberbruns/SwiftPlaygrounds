//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UIViewController, CollectionViewDataSourceFillLayout, CollectionViewDelegateFillLayout, KeyboardLayoutGuideDelegate {

    // MARK - Content -

    enum Sections: Int, CaseIterable {
        case header
        case items
        case input
        case actions

        enum Actions: Int, CaseIterable {
            case remove
            case add
        }
    }

    static let text = "Sie sagen es kommt die Zeit in der Pole schmelzen, sich riesen Wassermassen über Küstenstädte wälzen."
    private var items = Array(repeating: ViewController.text, count: 3)
    private var textInput = ""


    // MARK - Properties -
    // MARK Layout

    private let layout = CollectionViewFillLayout()
    private let keyboardLayoutGuide = KeyboardLayoutGuide()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var focusedIndexPath: IndexPath?


    // MARK - View -
    // MARK Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardLayoutGuide.delegate = self
        view.addLayoutGuide(keyboardLayoutGuide)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .lightGray
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(InputCollectionViewCell.self, forCellWithReuseIdentifier: "input")
        collectionView.register(FlexibleCollectionView.self, forSupplementaryViewOfKind: CollectionViewFillLayout.SupplementaryViewPosition.before.rawValue, withReuseIdentifier: "flex")
        collectionView.register(FlexibleCollectionView.self, forSupplementaryViewOfKind: CollectionViewFillLayout.SupplementaryViewPosition.after.rawValue, withReuseIdentifier: "flex")

        let unsafeAreaTop = UIView()
        unsafeAreaTop.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        unsafeAreaTop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsafeAreaTop)

        let unsafeAreaBottom = UIView()
        unsafeAreaBottom.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        unsafeAreaBottom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsafeAreaBottom)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            keyboardLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardLayoutGuide.heightConstraint,

            unsafeAreaTop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            unsafeAreaTop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            unsafeAreaTop.topAnchor.constraint(equalTo: view.topAnchor),
            unsafeAreaTop.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            unsafeAreaBottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            unsafeAreaBottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            unsafeAreaBottom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            unsafeAreaBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }


    // MARK - Protocol Conformance -
    // MARK CollectionViewDataSourceFillLayout

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Sections.allCases.count
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Sections.allCases[section] {
        case .items:
            return items.count
        case .actions:
            return Sections.Actions.allCases.count
        default:
            return 1
        }
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch Sections.allCases[indexPath.section] {
        case .header, .actions, .items:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        case .input:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "input", for: indexPath)
        }
        self.collectionView(collectionView, configureCell: cell, for: indexPath)

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "flex", for: indexPath)
        self.collectionView(collectionView, configureSupplementaryView: view, for: indexPath, position: CollectionViewFillLayout.SupplementaryViewPosition(rawValue: kind)!)
        return view
    }


    func collectionView(_ collectionView: UICollectionView, cellTypeAt indexPath: IndexPath) -> UICollectionViewCell.Type {
        switch Sections.allCases[indexPath.section] {
        case .header, .actions, .items:
            return TextCollectionViewCell.self
        case .input:
            return InputCollectionViewCell.self
        }
    }


    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, for indexPath: IndexPath) {
        switch (cell, Sections.allCases[indexPath.section]) {
        case (let cell as TextCollectionViewCell, .actions):
            switch Sections.Actions.allCases[indexPath.row] {
            case .add:
                cell.titleLabel.text = "Add"
                cell.titleLabel.textColor = .black
                cell.titleLabel.textAlignment = .center
                cell.contentView.backgroundColor = .green
            case .remove:
                cell.titleLabel.text = "Remove"
                cell.titleLabel.textColor = .red
                cell.titleLabel.textAlignment = .center
                cell.contentView.backgroundColor = .lightGray
            }

        case (let cell as TextCollectionViewCell, .header):
            cell.titleLabel.text = "Header"
            cell.titleLabel.textColor = .white
            cell.titleLabel.textAlignment = .left
            cell.contentView.backgroundColor = .black

        case (let cell as TextCollectionViewCell, _):
            cell.titleLabel.text = items[indexPath.row]
            cell.titleLabel.textColor = .black
            cell.titleLabel.textAlignment = .left
            cell.contentView.backgroundColor = .yellow

        case (let cell as InputCollectionViewCell, _):
            cell.contentView.backgroundColor = .purple
            cell.textField.text = textInput
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldDidEdit), for: .allEditingEvents)

        default:
            break
        }
    }


    func collectionView(_ collectionView: UICollectionView, supplementaryViewTypeAt indexPath: IndexPath, position: CollectionViewFillLayout.SupplementaryViewPosition) -> UICollectionReusableView.Type? {
        switch (Sections.allCases[indexPath.section], indexPath.item, position, items.isEmpty) {
        case (.items, 0, .before, false),
             (.input, 0, .before, true),
             (.input, 0, .after, _):
            return FlexibleCollectionView.self
        default:
            return nil
        }
    }


    func collectionView(_ collectionView: UICollectionView, configureSupplementaryView view: UICollectionReusableView, for indexPath: IndexPath, position: CollectionViewFillLayout.SupplementaryViewPosition) {
        view.backgroundColor = .lightGray
    }


    // MARK: CollectionViewDelegateFillLayout

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Sections.allCases[indexPath.section] {
        case .actions:
            switch Sections.Actions.allCases[indexPath.row] {
            case .add:
                items.append(ViewController.text)
            case .remove:
                items.removeLast()
            }
            collectionView.reloadData()
        case .items:
            items[indexPath.row] += " " + ViewController.text
            let cell = collectionView.cellForItem(at: indexPath)!
            UIView.animate(withDuration: 0.2) {
                self.collectionView(collectionView, configureCell: cell, for: indexPath)
                self.layout.invalidateEverything = true
                self.layout.invalidateLayout()
                collectionView.setNeedsLayout()
                collectionView.layoutIfNeeded()
            }
        default:
            break
        }
    }


    func collectionView(_ collectionView: UICollectionView, alignmentForCellAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment {
        switch Sections.allCases[indexPath.section] {
        case .actions:
            return indexPath.item == 0 ? .default : .pinnedToBottom
        default:
            return .default
        }
    }


    func collectionView(_ collectionView: UICollectionView, minimumHeightForCellAt indexPath: IndexPath) -> CGFloat {
        switch Sections.allCases[indexPath.section] {
        case .items, .actions, .header:
            return 66
        default:
            return 44
        }
    }


    func collectionView(_ collectionView: UICollectionView, alignmentForSupplementaryViewAt indexPath: IndexPath) -> CollectionViewFillLayout.Alignment {
        return .flexible
    }


    func collectionView(_ collectionView: UICollectionView, minimumHeightForSupplementaryViewAt indexPath: IndexPath) -> CGFloat {
        return 12
    }


    // MARK: KeyboardLayoutGuideDelegate

    func keyboardLayoutGuide(_ keyboardLayoutGuide: KeyboardLayoutGuide, willChangeFrom heightBefore: CGFloat, to heightAfter: CGFloat, animated: Bool) { }

    func keyboardLayoutGuide(_ keyboardLayoutGuide: KeyboardLayoutGuide, isChangingFrom heightBefore: CGFloat, to heightAfter: CGFloat, animated: Bool) {
        if let focusedIndexPath = focusedIndexPath, heightAfter > 0 {
            collectionView.scrollToItem(at: focusedIndexPath, at: .centeredVertically, animated: false)
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
        }
    }
}



extension ViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        focusedIndexPath = collectionView.indexPath(forCellContaining: textField)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        focusedIndexPath = nil
        return true
    }

    @objc func textFieldDidEdit(_ textField: UITextField) {
        textInput = textField.text ?? ""
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



class FlexibleCollectionView: UICollectionReusableView { }



extension UICollectionView {
    func indexPath(forCellContaining view: UIView) -> IndexPath? {
        var superview = view
        while true {
            if let cell = superview as? UICollectionViewCell {
                return indexPath(for: cell)
            } else if let next = superview.superview {
                superview = next
            } else {
                return nil
            }
        }
    }
}
