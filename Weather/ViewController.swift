//
//  ViewController.swift
//  Weather
//
//  Created by Alexey Baryshnikov on 26/05/2017.
//  Copyright © 2017 Alexey Baryshnikov. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var conditionLbl: UILabel!
    @IBOutlet weak var degreeLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var degree: Int!
    var condition: String!
    var imgURL: String!
    var isExist: Bool = true
    
    struct API {
        // API Request: https://api.darksky.net/forecast/[key]/[latitude],[longitude]
        
        private init() {}
        
        static let BaseURL = "https://api.darksky.net/forecast/"
        static let Token = "2f5cb9a96145515ba3b8f6ceaef13fff/"
    }
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchBar.delegate = self
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
//        guard let long = locationManager.location?.coordinate.longitude,
//            let lat = locationManager.location?.coordinate.latitude else { return }
        
        let coord = getCoordinates(city: cityLbl.text!)
        let lat = coord.0
        let long = coord.1
        
        let urlRequest = URLRequest(url: URL(string: "\(API.BaseURL)\(API.Token)\(lat),\(long)")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
               
                do {
                    let json = try JSONSerialization.jsonObject(with: data!,
                                                                options: .mutableContainers) as! [String : Any]
                    
                    if let currently = json["currently"] as? [String : Any] {
                        if let temp = currently["temperature"] as? Int {
                            self.degree = temp
                            print("temp OK")
                        }
                        if let condition = currently["summary"] as? String {
                            self.condition = condition
                            print("condition OK")
                        }
                        if let _ = json["error"] {
                            self.isExist = false
                        }
                        
                        DispatchQueue.main.async {
                            if self.isExist {
                                self.degreeLbl.text = self.degree.description
                                self.conditionLbl.text = self.condition
                            } else {
                                self.degreeLbl.isHidden = true
                                self.conditionLbl.isHidden = true
                                self.cityLbl.text = "No matching city found"
                                self.isExist = true
                            }
                        }
                    }

                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    
    func getCoordinates(city: String) -> (String, String) {
        var longitude = ""
        var latitude = ""
        CLGeocoder().geocodeAddressString(city) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location
                    let coordinate = location?.coordinate
                    guard let lat = coordinate?.latitude, let long = coordinate?.longitude else { return }
                    longitude = long.description
                    latitude = lat.description
                    print("geocoding OK")
                }
            } else {
                print(error!)
            }
        }
        return (latitude, longitude)
    }
    
    
}
