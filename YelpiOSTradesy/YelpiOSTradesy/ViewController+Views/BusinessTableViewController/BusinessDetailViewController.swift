//
//  BusinessViewController.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import UIKit

/*
 NOTE: This is a super quick and dirty detailVC - I wanted to do a stretch goal but kind of ran out of time but awkwardly had like 20 minutes left so I thought I'd try it but I don't think I can make it pretty, so if I had more time I'd clean it up a lot more like the first TVC 🥺
 */

class BusinessDetailViewController: UIViewController {
    
    // Dependency
    var business: Business?
    var imageFetcher: ImageFetchable = ImageManager()
    
    // UI
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let business = business {
            setupView(with: business)
        }
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(dismissGesture)
    }
    
    // MARK: - Actions
    
    @objc func viewTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Setup
    func setupView(with business: Business) {
        label.text = "\(business.location?.address1 ?? ""), \(business.location?.city ?? "") \(business.location?.state ?? ""), \(business.location?.zipCode ?? "")"
        imageFetcher.fetchImage(with: business.imageURLString ?? "") { [weak self] (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            case .failure(let error):
                // TODO: - Error Handling
                Logger().logEvent("Error: \(error)") // ew
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(systemName: "photo.fill")!
                }
            }
        }
    }
    
}
