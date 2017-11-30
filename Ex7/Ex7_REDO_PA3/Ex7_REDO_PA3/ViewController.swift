//
//  ViewController.swift
//  Ex7_REDO_PA3
//
//  Created by Timothy M Shepard on 11/29/17.
//  Copyright © 2017 Timothy. All rights reserved.
//

import UIKit
import CoreImage
import UserNotifications


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var mainImage: UIImageView!
    var originalImage = UIImage(named: "flower")
    
   
    @IBAction func filterSegmentedControl(_ sender: UISegmentedControl)
    {
        
        let filterType = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        
        guard let image = originalImage, let cgimg = image.cgImage else {
            print("myImageView doesn't have an image")
            return
        }
        
        //Use Graphics card
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)

        let coreImage = CIImage(cgImage: cgimg)
        
        // Original Image
        if filterType == "Original"
        {
            BlurSliderOutlet.isHidden = true
            mainImage.image = originalImage
        }
        // Noir
        else if filterType == "Noir"
        {
            BlurSliderOutlet.isHidden = true
            let filter = CIFilter(name: "CIPhotoEffectNoir")
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            
            if let outputCIImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            {
                let output = context.createCGImage(outputCIImage, from: outputCIImage.extent)
                let result = UIImage(cgImage: output!)
                mainImage?.image = result
            } else { print("Noir filter failed.") }
        }
        // Blur
        else if filterType == "Blur"
        {
            BlurSliderOutlet.isHidden = false
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            filter?.setValue(10, forKey: kCIInputRadiusKey)

            if let outputCIImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            {
                let output = context.createCGImage(outputCIImage, from: outputCIImage.extent)
                let result = UIImage(cgImage: output!)
                mainImage?.image = result
            } else { print("Blur filter failed.") }
        }
        // Blur
        else if filterType == "Sepia"
        {
            BlurSliderOutlet.isHidden = true
            let filter = CIFilter(name: "CISepiaTone")
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            filter?.setValue(1.0, forKey: kCIInputIntensityKey)
            
            if let outputCIImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            {
                let output = context.createCGImage(outputCIImage, from: outputCIImage.extent)
                let result = UIImage(cgImage: output!)
                mainImage?.image = result
            } else { print("Sepia filter failed.") }
        }
        // Vintage
        else
        {
            BlurSliderOutlet.isHidden = true
            let filter = CIFilter(name: "CIPhotoEffectInstant")
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            
            if let outputCIImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            {
                let output = context.createCGImage(outputCIImage, from: outputCIImage.extent)
                let result = UIImage(cgImage: output!)
                mainImage?.image = result
            } else { print("Vintage filter failed.") }
        }
    }

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BlurSliderOutlet.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "notify"), style: .done, target: self, action: #selector(notifyButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gallery"), style: .done, target: self, action: #selector(galleryButton))
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in
            
        })
    }
    
    @objc func notifyButton()
    {
        let content = UNMutableNotificationContent()
        content.title = "Hello Notifications"
        content.body = "This is my first time sending a notification."
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Timer Request Done", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // This allows notifications to come up when app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    
    @IBOutlet weak var BlurSliderOutlet: UISlider!
    
    @IBAction func BlurSlider(_ sender: UISlider)
    {
        guard let image = originalImage, let cgimg = image.cgImage else {
            print("myImageView doesn't have an image")
            return
        }
        
        //Use Graphics card
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        let value = BlurSliderOutlet.value
        let filterRadius = value*100
        
        filter?.setValue(filterRadius, forKey: kCIInputRadiusKey)
        
        if let outputCIImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage
        {
            let output = context.createCGImage(outputCIImage, from: outputCIImage.extent)
            let result = UIImage(cgImage: output!)
            mainImage?.image = result
        } else { print("Blur filter failed.") }
    }
    
    @objc func galleryButton()
    {
        let galleryAlert = UIAlertController(title: "Load Image", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Open Camera", style: .default, handler: { action in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self.imagePicker, animated: true, completion:
                    {
                        
                })
            }
            
        })
        
        let galleryAction = UIAlertAction(title: "Open Gallery", style: .default, handler: { action in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
            {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(self.imagePicker, animated: true, completion:
                {
                    
                })
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        galleryAlert.addAction(cameraAction)
        galleryAlert.addAction(galleryAction)
        galleryAlert.addAction(cancelAction)
        
        self.present(galleryAlert, animated: true, completion: nil)
    }

    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            mainImage.image = image
            originalImage = image
        }
        else
        {
            print("Error picking image.")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SaveImageButton(_ sender: Any)
    {
        guard let image = mainImage.image else {
            print("mainImage doesn't have an image.")
            return
        }
        
        let imageData = UIImagePNGRepresentation(image)
        let compressedImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        
        let alert = UIAlertController(title: "Saved", message: "Your image has been saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

