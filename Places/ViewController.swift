//
//  ViewController.swift
//  Places
//
//  Created by Daval Cato on 8/14/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchResultsUpdating {
    
    
    // Create a map
    let mapView = MKMapView()
    
    // Adding a search controller
    let searchVC = UISearchController(searchResultsController: ResultsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add subview
        title = "Maps"
        view.addSubview(mapView)
        // SeaarchBar a background color
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        
        // Conform to protocol
        searchVC.searchResultsUpdater = self
        
        navigationItem.searchController = searchVC
        
    }
    // Override
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Add frame
        mapView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width,
            height: view.frame.size.height - view.safeAreaInsets.top
        )
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Get the query text out of search controller
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
        let resultsVC = searchController.searchResultsController as? ResultsViewController else {
                  return
        }
        // update UI
        resultsVC.delegate = self
        
        // Call API
        GooglePlacesManager.shared.findPlaces(
            query: query) { result in
            switch result {
            case .success(let places):
                // On the main thread pass into the results controller
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
}

extension ViewController: ResultsViewControllerDelegate {
    // Single function
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        // Remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotation(annotations)
        
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.2,
                    longitudeDelta: 0.2
                )),
            animated: true)
        
    }
    
}

