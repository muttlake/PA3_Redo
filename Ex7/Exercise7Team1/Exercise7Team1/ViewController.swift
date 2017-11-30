//
//  ViewController.swift
//  Exercise7Team1
//
//  Created by ubicomp3 on 11/9/17.
//  Copyright © 2017 CPL. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var img: UIImageView!
    
    var picker = UIImagePickerController()
    
    @objc func galleryButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Image", message: "Select an Option", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let camOption = UIAlertAction(title: "Open Camera", style: .default) { (_: UIAlertAction) in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)
        }
        let galleryOption = UIAlertAction(title: "Open Gallery", style: .default) { (_: UIAlertAction) in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(camOption)
        alert.addAction(galleryOption)
        
        present(alert, animated: true, completion: nil)
    }
    
    var originalImage: UIImage?
    
    @objc func notifyButton(_ sender: Any) {
       let notif = UNMutableNotificationContent()
        notif.title = "Hello Notifications"
        notif.body = "This is my first time sending a notification"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let req = UNNotificationRequest(identifier: "notif1", content: notif, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
        
    }
    
    
    @IBOutlet weak var radius: UISlider!
    
    @IBOutlet weak var angle: UISlider!
    
    
    let filterDict = ["Blur" : "CIGaussianBlur", "Sepia": "CISepiaTone", "Noir": "CIPhotoEffectNoir", "Original":"Original", "Vintage":"CIPhotoEffectInstant"]
    
    @IBAction func filterButton(_ sender: UISegmentedControl) {
        filterImage(image: self.img, filterName: filterDict[sender.titleForSegment(at: sender.selectedSegmentIndex)!] ?? "CISepiaTone")
        
    }
    
    func filterImage(image: UIImageView, filterName: String) {
        guard let image = originalImage, let cgimg = image.cgImage else {
            print("myImageView doesn't have an image")
            return
        }
        radius.isHidden = true
        angle.isHidden = true
        
        if filterName == "Original" {
            img?.image = originalImage
            return
        }
        
        //Use Graphics card
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let filter = CIFilter(name: filterName)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if filterName == "CIGaussianBlur" {
            radius.isHidden = false
            angle.isHidden = false
            filter?.setValue(8, forKey: kCIInputRadiusKey)
        }
        
        //filter?.setValue(0.5, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let output = context.createCGImage(sepiaOutput, from: sepiaOutput.extent)
            let result = UIImage(cgImage: output!)
            img?.image = result
            
         
        } else {
            print("Image filtering failed.")
        }
        
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        
        let imageData = UIImagePNGRepresentation(img.image!)
        let compresedImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compresedImage!, nil, nil, nil)
        
        let alert = UIAlertController(title: "Saved", message: "Your image has been saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //application.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "notify"), style: .done, target: self, action: #selector(notifyButton(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gallery"), style: .done, target: self, action: #selector(galleryButton(_:)))
        
        
        picker.delegate = self
        originalImage = (img?.image)!
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in
            
        })
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            img.image = image
            originalImage = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}

