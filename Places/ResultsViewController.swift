//
//  ResultsViewController.swift
//  Places
//
//  Created by Daval Cato on 8/15/21.
//

import UIKit
import CoreLocation

protocol ResultsViewControllerDelegate: AnyObject {
    // Single function 
    func didTapPlace(with coordinates: CLLocationCoordinate2D)
    
}

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ResultsViewControllerDelegate?
    
    // Tableview
    private let tableview: UITableView = {
        // Register cell
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    // API call
    private var places: [Place] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableview)
        view.backgroundColor = .clear
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    public func update(with places: [Place]) {
        self.tableview.isHidden = false
        self.places = places
        print(places.count)
        // Reload
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    // Get rid of results
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get rid of places
        tableView.isHidden = true
        
        let place = places[indexPath.row]
        // Convert this place into a coordinate
        GooglePlacesManager.shared.resolveLocation(
            for: place) { [weak self] result in
            switch result {
            case .success(let coordinate):
                // Call on the main thread
                DispatchQueue.main.async {
                    self?.delegate?.didTapPlace(with: coordinate)
                }
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
}
