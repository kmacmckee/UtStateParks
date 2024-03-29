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
    
    @IBOutlet weak var hikingButton: UIButton!
    @IBOutlet weak var weatherTextView: UITextView!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var directionsLabel: UILabel!

    @IBOutlet weak var directionsIcon: UIButton!
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var parkImageView: UIImageView!
    
    
    let dataQueue = OperationQueue()
    
    var parkIndex = 0
    let forecast = ForecastClient()
    let parksAPI = ParksAPI()
    
    var weatherIconString: String? 
    var temperature: String?
    
    var parks: [Park]?
    var currentPark: Park? {
        didSet {
            loadParkData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        parkImageView.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        
        parkImageView.addGestureRecognizer(swipeRight)
        parkImageView.addGestureRecognizer(swipeLeft)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadParks()
    }
    
    
    func loadParks() {
        print("loadParks() started")
        DispatchQueue.main.async {
            print("startLoadAnimation")
            self.startLoadAnimation()
        }

        var components = URLComponents(string: Config.parksBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "stateCode", value: "Ut"),
            URLQueryItem(name: "api_key", value: Config.parksAPIKey)
        ]
        let requestURL = components.url!

        let fetchParksOp = FetchParksOp(requestURL: requestURL)

        let getFirstPark = BlockOperation {
            print("getting first park")
            self.parks = fetchParksOp.parks
            self.currentPark = fetchParksOp.parks?[0]
        }
        
        getFirstPark.addDependency(fetchParksOp)
        
        dataQueue.addOperation(fetchParksOp)
        print(dataQueue.operations)
        dataQueue.addOperation(getFirstPark)
        print(dataQueue.operations)
    }
    
    func loadParkData() {
        print("loadParkData() started")
        let coords = getCurrentParkCoord()
        print("Coords: \(coords)")
        let forecastOp = FetchForecastOp(lat: coords.lat, long: coords.long, forecast: forecast)
        
        let updateViewOp = BlockOperation {
            print("updateViewsOp started")
            guard let weather = forecastOp.weatherIconString else { return }
            self.temperature = "\(forecastOp.temperature!)℉"
            self.weatherAnimationView.animation = Animation.named(weather)
            self.weatherAnimationView.loopMode = .loop
            self.weatherAnimationView.play()
            
            self.updateViews()
        }
        
        updateViewOp.addDependency(forecastOp)
        
        dataQueue.addOperation(forecastOp)
        OperationQueue.main.addOperation(updateViewOp)
        
    }
    
    
    func updateViews() {
        
        animationView.stop()
        animationView.isHidden = true
        parkNameLabel.text = self.currentPark?.fullName
        
        
        let gradient = UIImage.gradientImageWithBounds(bounds: self.gradientImageView.bounds, colors: [UIColor.clear.cgColor, UIColor.white.cgColor])
        
        let parkImage = self.getParkImage()
    
        parkImageView.image = parkImage
        gradientImageView.image = gradient
        
        directionsLabel.text = "Directions:"
        directionsIcon.isHidden = false
        directionsTextView.text = self.currentPark?.directionsInfo
        
        
        weatherLabel.text = "Weather:"
        weatherTextView.text = self.currentPark?.weatherInfo
        
        
        temperatureLabel.text = self.temperature
        hikingButton.isHidden = false
        
    }
    
    
    func getCurrentParkCoord() -> (lat: Double, long: Double) {
        print("getting park coords")
        let coords = currentPark?.latLong.split(separator: ",")
        guard let latString = coords?.first,
            let longString = coords?.last else { return (lat: 0, long: 0) }
        
        let latStringFormatted = latString.filter("-0123456789.".contains)
        let lat = Double(latStringFormatted)
        
        let longStringFormatted = longString.filter("-0123456789.".contains)
        let long = Double(longStringFormatted)
        return (lat: lat!, long: long!)
    }
    
    
    
    func startLoadAnimation() {
        animationView.animation = Animation.named("loaderBlack")
        animationView.loopMode = .loop
        animationView.play()
    }
//    
//    func startWeatherAnimation() {
//        guard let weather = weatherIconString else { return }
//        weatherAnimationView.animation = Animation.named(weather)
//        weatherAnimationView.loopMode = .loop
//        weatherAnimationView.play()
//    }
    
    
    
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
    
//    func getParkWeather() {
//        let coords = currentPark?.latLong.split(separator: ",")
//        guard let latString = coords?.first,
//            let longString = coords?.last else { return }
//
//        let latStringFormatted = latString.filter("-0123456789.".contains)
//        let lat = Double(latStringFormatted)
//
//        let longStringFormatted = longString.filter("-0123456789.".contains)
//        let long = Double(longStringFormatted)
//
//        forecast.client.getForecast(latitude: lat!, longitude: long!) { (result) in
//            switch result {
//            case .success(let currentForecast, _):
//
//                self.weatherIconString = currentForecast.currently?.icon?.rawValue
//                self.temperature = "\(Int(currentForecast.currently?.apparentTemperature ?? 0))℉"
//                return
//
//
//            case .failure(let error):
//
//                NSLog("Error getting forecast: \(error)")
//                return
//            }
//        }
//
//
//    }
    
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            guard let parks = self.parks else { return }
            
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
