//
//  ParkSelectionViewController.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/10/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import UIKit
import Lottie

class ParkSelectionViewController: UIViewController {

    
    @IBOutlet weak var weatherTextView: UITextView!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var directionsIcon: UIImageView!
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var parkImageView: UIImageView!
    
    var currentPark: Park? {
        didSet {
            updateViews()
        }
    }
    var parkIndex = 0
    let parksAPI = ParksAPI()
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
//        guard let parks = parks else { return }
        
//        print(parks.map({ $0.fullName }))

//        self.currentPark = parks.first
        
        let parkImage = getParkImage()
        
        
        DispatchQueue.main.async {
            
            self.animationView.stop()
            self.animationView.isHidden = true
            self.parkNameLabel.text = self.currentPark?.fullName
            
            
            
            let gradient = UIImage.gradientImageWithBounds(bounds: self.gradientImageView.bounds, colors: [UIColor.clear.cgColor, UIColor.white.cgColor])
        
            self.parkImageView.image = parkImage
            self.gradientImageView.image = gradient
            
            self.directionsIcon.image = UIImage(named: "iosMapsIcon")
            self.directionsTextView.text = self.currentPark?.directionsInfo
            
            self.weatherLabel.text = "Weather:"
            self.weatherTextView.text = self.currentPark?.weatherInfo
            
            
            
        }
    }
    
    
    
    func startLoadAnimation() {
        animationView.animation = Animation.named("loaderBlack")
        animationView.loopMode = .loop
        animationView.play()
        
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
