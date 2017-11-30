//
//  ViewController.swift
//  Ex8_REDO_PA3
//
//  Created by Timothy M Shepard on 11/29/17.
//  Copyright © 2017 Timothy. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var botBar: UIView!
    @IBOutlet weak var leftBar: UIView!
    @IBOutlet weak var rightBar: UIView!
    
    //box
    @IBOutlet weak var box: UIView!
    
    let motionManager = CMMotionManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        motionManager.accelerometerUpdateInterval =  0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {(data, error) in
            if let myData = data
            {
                let x_acc = myData.acceleration.x
                let y_acc = myData.acceleration.y
                let z_acc = myData.acceleration.z
                
                if (x_acc > 1.5 || y_acc > 1.5 || z_acc > 1.5)
                {
                    self.box.backgroundColor = self.randomColor()
                }
            }
            else
            {
                print("Error starting accelerometer updates")
            }
        })
        
        // Do any additional setup after loading the view, typically from a nib.
        _ = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(changeBoxShape))
        doubleTap.numberOfTapsRequired = 2
        box.addGestureRecognizer(doubleTap)
        
        //Altimeter Not Working
        let altimeter = CMAltimeter()
        if CMAltimeter.isRelativeAltitudeAvailable()
        {
            print("Relative Altitude is available.")
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.current!, withHandler: { (altitudeData: CMAltitudeData?, error: Error?) in
                if let altData = altitudeData
                {
                    print("Relative Altitude Data: ", altData.relativeAltitude.floatValue)
                    //let alt = altData.relativeAltitude.floatValue
                    //self.view.backgroundColor = UIColor(displayP3Red: CGFloat(alt), green: CGFloat(alt), blue: CGFloat(alt), alpha: 1.0)
                }
                else
                { print("Error starting Altitude updates.") }
                })
        } else { print ("Relative Altitude Not available.") }
        
        // drag box
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        box.addGestureRecognizer(panGesture)
        
        // force touch does not work
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available
        {
            print("Force touch is available")
            let forceTouch = UITouch()
            if (forceTouch.force >= forceTouch.maximumPossibleForce/4)
            {
                self.changeBoxShape()
            }
        }
        else
        {
            print("Not compatible with Force Touch.")
        }
        
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    
    func randomColor() ->  UIColor
    {
        let r = CGFloat(arc4random_uniform(UInt32(255)))/255
        let g = CGFloat(arc4random_uniform(UInt32(255)))/255
        let b = CGFloat(arc4random_uniform(UInt32(255)))/255
        return UIColor(displayP3Red: r, green: g, blue: b, alpha: 1.0)
    }
    
    
    @objc func changeBoxShape()
    {
        if box.layer.cornerRadius == 0
        {
            box.layer.cornerRadius = box.frame.height / 2
        }
        else
        {
            box.layer.cornerRadius = 0
        }
    }
    
    
    @objc func updateData()
    {
        if let data = motionManager.accelerometerData
        {
            let newXPosition = box.center.x + CGFloat(data.acceleration.x * 15)
            let newLeftEdge = newXPosition - 50
            let newRightEdge = newXPosition + 50
            
            let newYPosition = box.center.y - CGFloat(data.acceleration.y * 15)
            let newTopEdge = newYPosition - 50
            let newBotEdge = newYPosition + 50
            
            
            let MAX_WIDTH = self.view.frame.width - 20
            let MAX_HEIGHT = self.view.frame.height - 20
            
            let blackColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            // top left corner
            if (newLeftEdge <= 20 && newTopEdge <= 20)
            {
                box.center.x = 70
                box.center.y = 70
                box.backgroundColor = blackColor
            }
            // top right corner
            else if (newRightEdge >= MAX_WIDTH && newTopEdge <= 20)
            {
                box.center.x = MAX_WIDTH - 50
                box.center.y = 70
                box.backgroundColor = blackColor
            }
            // lower left corner
            else if (newLeftEdge <= 20 && newBotEdge >= MAX_HEIGHT)
            {
                box.center.x = 70
                box.center.y = MAX_HEIGHT - 50
                box.backgroundColor = blackColor
            }
            // lower right corner
            else if (newRightEdge >= MAX_WIDTH && newBotEdge >= MAX_HEIGHT)
            {
                box.center.x = MAX_WIDTH - 50
                box.center.y = MAX_HEIGHT - 50
                box.backgroundColor = blackColor
            }
            // left edge
            else if (newLeftEdge <= 20)
            {
                box.center.x = 70
                box.center.y = newYPosition
                box.backgroundColor = leftBar.backgroundColor
            }
            // right edge
            else if (newRightEdge >= MAX_WIDTH)
            {
                box.center.x = MAX_WIDTH - 50
                box.center.y = newYPosition
                box.backgroundColor = rightBar.backgroundColor
            }
            // top edge
            else if (newTopEdge <= 20)
            {
                box.center.x = newXPosition
                box.center.y = 70
                box.backgroundColor = topBar.backgroundColor
            }
            // bot edge
            else if (newBotEdge >= MAX_HEIGHT)
            {
                box.center.x = newXPosition
                box.center.y = MAX_HEIGHT - 50
                box.backgroundColor = botBar.backgroundColor
            }
            // box is in middle somewhere
            else
            {
                box.center.x = newXPosition
                box.center.y = newYPosition
            }
        }
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


}

