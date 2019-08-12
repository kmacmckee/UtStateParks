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

    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var parkImageView: UIImageView!
    
    let parksAPI = ParksAPI()
    
    var parks: [Park]? {
        didSet {
            updateViews()
        }
    }
    var currentPark: Park?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadParks()
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
            } else {
                NSLog("No parks returned from fetch")
                return
            }
            
        }
        
    }
    
    func updateViews() {
        guard let parks = parks else { return }
        
        print(parks.map({ $0.fullName }))
        
        self.currentPark = parks.first
        
        
        DispatchQueue.main.async {
            self.animationView.stop()
            self.animationView.isHidden = true
            self.parkNameLabel.text = self.currentPark?.fullName
            let image = UIImage(named: "DelicateArch")
            let gradient = UIImage.gradientImageWithBounds(bounds: self.gradientImageView.bounds, colors: [UIColor.clear.cgColor, UIColor.white.cgColor])
        
            self.parkImageView.image = image
            self.gradientImageView.image = gradient
            
            
        }
    }
    
    
    
    func startLoadAnimation() {
        animationView.animation = Animation.named("loaderBlack")
        animationView.loopMode = .loop
        animationView.play()
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
