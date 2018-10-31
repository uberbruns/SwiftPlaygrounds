//
//  ViewController.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, CollectionViewFillLayoutDelegate, KeyboardLayoutGuideDelegate {

    enum Sections: Int, CaseIterable {
        case header
        case flexibleTop
        case items
        case input
        case flexibleBottom
        case actions

        enum Actions: Int, CaseIterable {
            case remove
            case add
        }
    }

    private var numberOfItems = 3
    private var text = ""
    private let layout = CollectionViewFillLayout()
    private let keyboardLayoutGuide = KeyboardLayoutGuide()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var focusedIndexPath: IndexPath?

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
        collectionView.register(FlexibleCollectionViewCell.self, forCellWithReuseIdentifier: "flex")
        collectionView.register(InputCollectionViewCell.self, forCellWithReuseIdentifier: "input")

        let unsafeAreaTop = UIView()
        unsafeAreaTop.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        unsafeAreaTop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsafeAreaTop)

        let unsafeAreaBottom = UIView()
        unsafeAreaBottom.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        unsafeAreaBottom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsafeAreaBottom)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            keyboardLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardLayoutGuide.heightConstraint,

            unsafeAreaTop.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            unsafeAreaTop.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            unsafeAreaTop.topAnchor.constraint(equalTo: view.topAnchor),
            unsafeAreaTop.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            unsafeAreaBottom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            unsafeAreaBottom.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            unsafeAreaBottom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            unsafeAreaBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        case .header, .actions, .items:
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
            return indexPath.item == 0 ? .default : .stickyBottom
        default:
            return .default
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellTypeForItemAt indexPath: IndexPath) -> UICollectionViewCell.Type {
        switch Sections.allCases[indexPath.section] {
        case .flexibleTop, .flexibleBottom:
            return FlexibleCollectionViewCell.self
        case .header, .actions, .items:
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
                cell.titleLabel.textColor = .black
                cell.contentView.backgroundColor = .green
            case .remove:
                cell.titleLabel.text = "Remove"
                cell.titleLabel.textColor = .white
                cell.contentView.backgroundColor = .red
            }

        case (let cell as TextCollectionViewCell, .header):
            cell.titleLabel.text = "Header"
            cell.titleLabel.textColor = .white
            cell.contentView.backgroundColor = .black

        case (let cell as TextCollectionViewCell, _):
            cell.titleLabel.text = "Sie sagen es kommt die Zeit in der Pole schmelzen, sich riesen Wassermassen über Küstenstädte wälzen."
            cell.titleLabel.textColor = .black
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

    // MARK: KeyboardLayoutGuideDelegate

    func keyboardLayoutGuide(_ keyboardLayoutGuide: KeyboardLayoutGuide, willChangeFrom heightBefore: CGFloat, to heightAfter: CGFloat, animated: Bool) {
    }

    func keyboardLayoutGuide(_ keyboardLayoutGuide: KeyboardLayoutGuide, isChangingFrom heightBefore: CGFloat, to heightAfter: CGFloat, animated: Bool) {
        let preferredContentOffsetY: CGFloat
        if let focusedIndexPath = focusedIndexPath, let cell = collectionView.cellForItem(at: focusedIndexPath), heightAfter > 0 {
            preferredContentOffsetY = cell.center.y + (collectionView.bounds.height / 2)
        } else {
            preferredContentOffsetY = collectionView.contentOffset.y
        }
        collectionView.setPreferredContentOffset(.init(x: 0, y: preferredContentOffsetY))
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
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

    func setPreferredContentOffset(_ preferredContentOffset: CGPoint) {
        let newContentOffset: CGPoint
        let minContentOffsetY = -safeAreaInsets.top
        let maxContentOffsetY = contentSize.height - bounds.height - safeAreaInsets.bottom
        newContentOffset = CGPoint(x: 0, y: max(minContentOffsetY, min(maxContentOffsetY, preferredContentOffset.y)))
        if newContentOffset != contentOffset {
            contentOffset = newContentOffset
        }
    }
}
