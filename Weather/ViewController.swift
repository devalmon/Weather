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
    @IBOutlet weak var summaryLbl: UILabel!
    
    var degree: Int!
    var condition: String!
    var imgURL: String!
    var city: String!
    var summary: String!
    var isExist: Bool = true
    
    
    //    MARK: - API
    
    struct API {
        // API Request: https://api.darksky.net/forecast/[key]/[latitude],[longitude]
        
        private init() {}
        
        static let baseURL = "https://api.darksky.net/forecast/"
        static let token = "2f5cb9a96145515ba3b8f6ceaef13fff/"
    }
    
    
    var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
    }
    
    //    MARK: - Process handler
    
    private func processHandler(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) -> (latitude: String, longitude: String) {
        var lat = ""
        var long = ""
        if let error = error {
            print("Unable to forward geocode address (\(error))")
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            if let location = location {
                let coordinate = location.coordinate
                lat = coordinate.latitude.description
                long = coordinate.longitude.description
            } else {
                print("No location found")
            }
        }
        return (lat, long)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let address = searchBar.text else { return }
        
        var longitude = ""
        var latitude = ""
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            let address = self.processHandler(withPlacemarks: placemarks, error: error)
            longitude = address.1
            latitude = address.0
            
            
            let urlRequest = URLRequest(url: URL(string: "\(API.baseURL)\(API.token)\(latitude),\(longitude)")!)
            print("\(urlRequest)")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                if error != nil { return }
                
                do {
                                            print("Going to parse data")
                    let json = try JSONSerialization.jsonObject(with: data!,
                                                                options: .mutableContainers) as! [String : AnyObject]
                    
                    if let currently = json["currently"] as? [String : AnyObject] {
                        if let temp = currently["temperature"] as? Int {
                            self?.degree = (temp - 32)*5/9
                                                            print("temp OK")
                        }
                        if let condition = currently["summary"] as? String {
                            self?.condition = condition
                                                            print("condition OK")
                        }
                        if let city = json["timezone"] as? String {
                            self?.city = city
                                                            print("Timezone OK")
                        }
                        if let _ = json["error"] {
                            self?.isExist = false
                        }
                        if let daily = json["daily"] as? [String : AnyObject] {
                            if let summary = daily["summary"] as? String {
                                self?.summary = summary
                            }
                        }
                        
                        DispatchQueue.main.async {
                                                            print("Trying to update UI")
                                                            print("\(self?.city ?? "default value for city")")
                            if (self?.isExist)! {
                                
//                                self?.degreeLbl.text = ("\(self?.degree.description ?? "°")")
                                self?.conditionLbl.text = self?.condition
                                self?.cityLbl.text = self?.city
                                self?.summaryLbl.text = self?.summary
//                                                                    self?.imgView.downloadImage(from: (self?.imgURL)!)
                                self?.degreeLbl.isHidden = false
                                self?.conditionLbl.isHidden = false
                                self?.cityLbl.isHidden = false
                                self?.summaryLbl.isHidden = false
                            } else {
                                self?.degreeLbl.isHidden = true
                                self?.conditionLbl.isHidden = true
                                self?.cityLbl.isHidden = true
                                self?.summaryLbl.isHidden = false
                                self?.isExist = true
                            }
                        }
                    }
                    
                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
            task.resume()
        }
    }
}




extension UIImageView {
    
    func downloadImage(from url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
