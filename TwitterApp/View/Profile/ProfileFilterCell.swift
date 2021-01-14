//
//  ProfileFilterCell.swift
//  TwitterApp
//
//  Created by Sergey on 12/21/20.
//

import UIKit

class ProfileFilterCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var option: ProfileFilterOptions? {
        didSet {
            titleLabel.text = option?.description
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? UIColor.twitterBlue : UIColor.lightGray
        }
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Position of the titleLabel
        titleLabel.center(inView: self)
    }
    
    //MARK: - Selectors
    
    
    //MARK: - Helpers
    
    ///Sets Initial UI
    private func configureUI() {
        backgroundColor = .white
        addAsASubview()
    }
    
    ///Adds subview
    private func addAsASubview() {
        addSubview(titleLabel)
    }
    
}
