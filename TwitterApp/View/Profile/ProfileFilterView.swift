//
//  ProfileFilterView.swift
//  TwitterApp
//
//  Created by Sergey on 12/21/20.
//

import UIKit

private let reuseIdentifier = "ProfileFilterCell"

protocol ProfileFilterViewDelegate: class {
    func filterView(_ view: ProfileFilterView, didSelect indexPath: Int)
    
}

class ProfileFilterView: UIView {
    
    //MARK: - Properties
    
    weak var delegate: ProfileFilterViewDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    
    //MARK: - Lifycycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Position of the collection view
        collectionView.addConstraintsToFillView(self)
        //Postion of the underlineView
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, width: frame.size.width / 3, height: 2)
    }
    
    //MARK: - Selectors
    
    
    //MARK: - Helpers
    
    
    ///Sets Initial UI
    private func configureUI() {
        backgroundColor = .orange
        //Register a cell
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //Adding subviews
        addAsASubview()
        //the initial selected value
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .left)
    }
    
    ///Adds subviews
    private func addAsASubview() {
        addSubview(collectionView)
        addSubview(underlineView)
    }
    
}

//MARK: - UICollectionViewDelegate and UICollectionViewDataSource Implementation

extension ProfileFilterView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileFilterOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileFilterCell
        let option = ProfileFilterOptions(rawValue: indexPath.row)
        cell.option = option
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.filterView(self, didSelect: indexPath.row)
        let cell = collectionView.cellForItem(at: indexPath)
        let xPosition = cell?.frame.origin.x ?? 0
        UIView.animate(withDuration: 0.3, animations: {
            self.underlineView.frame.origin.x = xPosition
        })
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = CGFloat(ProfileFilterOptions.allCases.count)
        return CGSize(width: frame.size.width / count, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
}
