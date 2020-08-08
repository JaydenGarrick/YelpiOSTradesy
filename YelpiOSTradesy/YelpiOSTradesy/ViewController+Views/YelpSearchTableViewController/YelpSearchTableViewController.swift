//
//  YelpSearchTableViewController.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import UIKit

// MARK: - View Protocol
protocol BusinessResultable {
    func reload()
    func presentError(_ message: String)
    func navigateToDetailViewController(with business: Business)
}

final class YelpSearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    var presenter: YelpSearchPresenter!
    
    // Constants
    enum Constants {
        static let cellName = "BusinessTableViewCell"
        static let detailViewController = "BusinessDetailViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup() {
        // Search Controller
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Businesses"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        
        // Presenter
        presenter = YelpSearchPresenter(self)
        presenter.locationManager.requestLocation()
        
        // TableView Cell Registration
        tableView.register(UINib(nibName: Constants.cellName, bundle: nil), forCellReuseIdentifier: Constants.cellName)
    }
}

// TableViewDelegate & TableViewDataSource
extension YelpSearchTableViewController {
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return EmptySearchHeaderView.instanceFromNib()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return presenter.shouldHaveHeader ? 100 : 0
    }
    
    // Reusable Cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellName) as? BusinessTableViewCell else {
            fatalError("Unable to deque BusinessTableViewCell")
        }
        // TODO: - Move some of this business logic to presenter
        let business = presenter.businessFor(indexPath)
        cell.business = business
        presenter.getImageFor(business) { (image) in
            DispatchQueue.main.async {
                cell.businessImageView.image = image
            }
        }
        cell.delegate = presenter
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
}

// MARK: - UISearchBarDelegate
extension YelpSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.search(with:searchBar.text ?? "")
    }
}

// MARK: - BusinessResultable
extension YelpSearchTableViewController: BusinessResultable {
    /*
     Note: Typically I would use a coordinator but I'm last minute yolo'ing this detail VC
     */
    func navigateToDetailViewController(with business: Business) {
        guard let businessDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: Constants.detailViewController) as? BusinessDetailViewController else {
            // TODO: - Actually do something here
            return
        }
        businessDetailViewController.business = business
        present(businessDetailViewController, animated: true)
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func presentError(_ message: String) {
        let alertController = UIAlertController(title: "Please Try Again", message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Search Businesses"
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] (_) in
            guard let textField = alertController.textFields?.first else {
                return
            }
            self?.presenter.search(with: textField.text ?? "")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

