//
//  NewMatchCollectionViewCell.swift
//  LetsMeet
//
//  Created by David Kababyan on 17/07/2020.
//

import UIKit

class NewMatchCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        
        hideActivityIndicator()
    }
    
    
    func setupCell(avatarLink: String) {
        
        showActivityIndicator()
        
        self.avatarImageView.image = UIImage(named: "avatar")
        
        FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            self.hideActivityIndicator()
            self.avatarImageView.image = avatarImage?.circleMasked
        }
    }
    
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    
    
}
