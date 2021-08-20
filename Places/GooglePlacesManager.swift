//
//  GooglePlacesManager.swift
//  Places
//
//  Created by Daval Cato on 8/15/21.
//

import Foundation
import GooglePlaces
import CoreLocationUI
import CoreLocation

// Create model
struct Place {
    let name: String
    let identifier: String
    
}

final class GooglePlacesManager {
    // Shared instance as a singleton
    static let shared = GooglePlacesManager()
    
    // Getting the client
    private let client = GMSPlacesClient.shared()
    
    // privatize the init
    private init() {}
    
    // Custom error enum
    enum PlacesError: Error {
        case failedToFind
        case failedToGetCoordinates
        
    }
    
    // Built auto prediction feature
    public func findPlaces(
        query: String,
        completion: @escaping (Result<[Place], Error>) -> Void
    
    ) {
        // Basis of Geocode
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        
        client.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: nil
            // optional array of predictions
        ) { results, error in
            guard let results = results, error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return
            }
            // Use results to create array of place models
            let places: [Place] = results.compactMap({
                Place(
                    name: $0.attributedFullText.string,
                    identifier: $0.placeID
                )
            })
            // Call completion helder
            completion(.success(places))
        }
    }
    // Add function
    public func resolveLocation(
        for place: Place,
        completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void
    
    ) {
        client.fetchPlace(
            fromPlaceID: place.identifier,
            placeFields: .coordinate,
            sessionToken: nil
        ) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                completion(.failure(PlacesError.failedToGetCoordinates))
                return
            }
            // Create core location coordinate
            let coordinate = CLLocationCoordinate2D(
                latitude: googlePlace.coordinate.latitude,
                longitude: googlePlace.coordinate.longitude
            )
            completion(.success(coordinate))
        }
    }
}











