//
//  ParkSelectionViewController.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/10/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import UIKit
import Lottie
import MapKit

class ParkSelectionViewController: UIViewController {

    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherAnimationView: AnimationView!
    
    @IBOutlet weak var weatherTextView: UITextView!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var directionsLabel: UILabel!

    @IBOutlet weak var directionsIcon: UIButton!
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var parkImageView: UIImageView!
    
    var parkIndex = 0
    let forecast = ForecastClient()
    let parksAPI = ParksAPI()
    
    var weatherIconString: String? 
    var temperature: String?
    
    var currentPark: Park? {
        didSet {
            updateViews()
            print(currentPark?.latLong)
        }
    }
    
    var parks: [Park]? {
        didSet {
            updateViews()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadParks()
        
        parkImageView.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        parkImageView.addGestureRecognizer(swipeRight)
        
        parkImageView.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        parkImageView.addGestureRecognizer(swipeLeft)
        
        
    }
    
    
    func loadParks() {
        startLoadAnimation()
        
        parksAPI.getParks { (parks, error) in
            if let error = error {
                NSLog("Error getting parks: \(error)")
                return
            }
            if let parks = parks {
                self.parks = parks
                self.currentPark = parks.first
            } else {
                NSLog("No parks returned from fetch")
                return
            }
        }
    }
    
    
    
    
    
    func updateViews() {
        
        let parkImage = getParkImage()
        getParkWeather()
        
        DispatchQueue.main.async {
            
            self.animationView.stop()
            self.animationView.isHidden = true
            self.parkNameLabel.text = self.currentPark?.fullName
            
            
            
            let gradient = UIImage.gradientImageWithBounds(bounds: self.gradientImageView.bounds, colors: [UIColor.clear.cgColor, UIColor.white.cgColor])
        
            self.parkImageView.image = parkImage
            self.gradientImageView.image = gradient
            
            self.directionsLabel.text = "Directions:"
            self.directionsIcon.isHidden = false
            self.directionsTextView.text = self.currentPark?.directionsInfo
            
            
            self.weatherLabel.text = "Weather:"
            self.weatherTextView.text = self.currentPark?.weatherInfo
            
            self.startWeatherAnimation()
            self.temperatureLabel.text = self.temperature
        }
    }
    
    
    
    func startLoadAnimation() {
        animationView.animation = Animation.named("loaderBlack")
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func startWeatherAnimation() {
        guard let weather = weatherIconString else { return }
        weatherAnimationView.animation = Animation.named(weather)
        weatherAnimationView.loopMode = .loop
        weatherAnimationView.play()
    }
    
    
    
    func getParkImage() -> UIImage {
        switch (currentPark?.fullName) {
        case "Arches National Park":
            return UIImage(named: "DelicateArch")!
        case "Bryce Canyon National Park":
            return UIImage(named: "BryceCanyon")!
        case "Canyonlands National Park":
            return UIImage(named: "WhiteRimRoad-Canyonlands")!
        case "Capitol Reef National Park":
            return UIImage(named: "CapitolReef")!
        case "Cedar Breaks National Monument":
            return UIImage(named: "CedarBreaks")!
        case "Golden Spike National Historical Park":
            return UIImage(named: "GoldenSpike")!
        case "Natural Bridges National Monument":
            return UIImage(named: "NaturalBridges")!
        case "Rainbow Bridge National Monument":
            return UIImage(named: "RainbowBridge")!
        case "Timpanogos Cave National Monument":
            return UIImage(named: "TimpanogosCave")!
        case "Zion National Park":
            return UIImage(named: "AngelsLandingZion")!
            
        default:
            return UIImage(named: "DelicateArch")!
        }
    }
    
    func getParkWeather() {
        let coords = currentPark?.latLong.split(separator: ",")
        guard let latString = coords?.first,
            let longString = coords?.last else { return }
        
        let latStringFormatted = latString.filter("0123456789.".contains)
        let lat = Double(latStringFormatted)
        
        let longStringFormatted = longString.filter("0123456789.".contains)
        let long = Double(longStringFormatted)
        
        
        
        forecast.client.getForecast(latitude: lat!, longitude: long!) { (result) in
            switch result {
            case .success(let currentForecast, _):
                
                self.weatherIconString = currentForecast.currently?.icon?.rawValue
                self.temperature = "\(Int(currentForecast.currently?.apparentTemperature ?? 0))℉"
                
                return
                
                
            case .failure(let error):
                
                NSLog("Error getting forecast: \(error)")
                return
            }
        }
        
        
    }
    
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            guard let parks = parks else { return }
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                if parkIndex == parks.count - 1 {
                    parkIndex = 0
                } else {
                    parkIndex += 1
                }
                self.currentPark = parks[parkIndex]
                
                
            case UISwipeGestureRecognizer.Direction.right:
                if parkIndex == 0 {
                    parkIndex = parks.count - 1
                } else {
                    parkIndex -= 1
                }
                self.currentPark = parks[parkIndex]
                
            default:
                break
                
            }
            
        }
    }
    
    
    @IBAction func directionsIconTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "http://maps.apple.com/")!, options: [:], completionHandler: nil)
        
        let coords = currentPark?.latLong.split(separator: ",")
        guard let latString = coords?.first,
            let longString = coords?.last else { return }
        
        let latStringFormatted = latString.filter("-0123456789.".contains)
        let lat = Double(latStringFormatted)
        
        let longStringFormatted = longString.filter("-0123456789.".contains)
        let long = Double(longStringFormatted)
    
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(lat!, long!)
        print(coordinates)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = currentPark?.fullName
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
