//
//  ViewController.swift
//  Exercise8Team1
//
//  Created by ubicomp3 on 11/16/17.
//  Copyright © 2017 CPL. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var motionManager = CMMotionManager()
    
    @IBOutlet weak var red: UIView!
    
    @IBOutlet weak var topBorder: UIView!
    
    @IBOutlet weak var bottomBorder: UIView!
    
    @IBOutlet weak var leftBorder: UIView!
    
    @IBOutlet weak var rightBorder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(view.frame.height / 2)
        print(view.frame.width / 2)
        red.layer.masksToBounds = true
        
        let altimeter = CMAltimeter()
        if CMAltimeter.isRelativeAltitudeAvailable() {
            print("ready")
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (data: CMAltitudeData?, err: Error?) in
                
                if err != nil {
                    
                }
                else
                {
                    let altitude = data!.relativeAltitude.floatValue
                    let pressure = data!.pressure.floatValue
                    
                    print("Altitude:", altitude)
                }
                print(data!)
            })
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        _ = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, err) in
                if let data = data {
                    if data.acceleration.x > 1 {
                        self.view.backgroundColor = self.randomizeColor()
                    }
                    
                }
            })
        }
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(changeShape))
        doubleTap.numberOfTapsRequired = 2
        
        red.addGestureRecognizer(doubleTap)
        
        
        
        
    }
    
    func randomizeColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(UInt32(255)))/255, green: CGFloat(arc4random_uniform(UInt32(255)))/255, blue: CGFloat(arc4random_uniform(UInt32(255)))/255, alpha: 0.5)
    }
    
    
    @objc func changeShape() {
        self.red.layer.cornerRadius = self.red.layer.cornerRadius == self.red.frame.height / 2 ? 0 : self.red.frame.height / 2;
        print(red.frame.height)
        print(red.layer.cornerRadius)
    }

    @objc func updateData() {
        if let data = motionManager.accelerometerData {
            let newXPositon = self.red.center.x + CGFloat(data.acceleration.x * 20)
            let newYPositon = self.red.center.y + CGFloat(data.acceleration.y * -20)
            

            if (newXPositon <= 80) {
                red.center.x = 80
                red.backgroundColor = leftBorder.backgroundColor
                if red.center.y == 80 || red.center.y == view.frame.height - 80 {
                    red.backgroundColor = UIColor.black
                }
                return
            } else if (newXPositon >= self.view.frame.width - 80) {
                red.center.x = self.view.frame.width - 80
                red.backgroundColor = rightBorder.backgroundColor
                if red.center.y == 80 || red.center.y == view.frame.height - 80 {
                    red.backgroundColor = UIColor.black
                }
                return
            }
            
            if (newYPositon <= 80) {
                red.center.y = 80
                red.backgroundColor = topBorder.backgroundColor
                return
            }
            if (newYPositon >= self.view.frame.height - 80) {
                red.center.y = self.view.frame.height - 80
                red.backgroundColor = bottomBorder.backgroundColor
                return
            }

            
            self.red.center.x += CGFloat(data.acceleration.x * 20)
            self.red.center.y += CGFloat(data.acceleration.y * -20)


        }
    }


}

//        if let gyroData = motionManager.gyroData {
////            print("X: ", gyroData.rotationRate.x)
////            print("Y: ", gyroData.rotationRate.y)
////            print("Z: ", gyroData.rotationRate.z)
//        }
