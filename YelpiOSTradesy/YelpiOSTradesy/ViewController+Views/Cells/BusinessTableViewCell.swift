//
//  BusinessTableViewCell.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import UIKit

protocol BusinessTableViewCellDelegate: class {
    func callButtonTapped(number: String)
}

class BusinessTableViewCell: UITableViewCell {
    
    // Dependency
    var business: Business! {
        didSet {
            setupView()
        }
    }
    
    // UI Elements
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    // Delegate
    weak var delegate: BusinessTableViewCellDelegate?
    
    // MARK: - Initalization
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Setup
    private func setupView() {
        nameLabel.text = business.name
        priceLabel.text = "Price: " + String(repeating: "💵", count: Int(business.price?.count ?? 0))
        ratingLabel.text = String(repeating: "⭐️", count: Int(business.rating ?? 0))
        callButton.setTitle(business.displayPhone ?? "871-CASH-NOW", for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func callButtonTapped(_ sender: Any) {
        print("Tapped")
        delegate?.callButtonTapped(number: business.phoneNumber ?? "871-CASH-NOW")
    }
        
    // Reset
    override func prepareForReuse() {
        businessImageView.image = UIImage(systemName: "photo.fill")
        super.prepareForReuse()
    }
}
