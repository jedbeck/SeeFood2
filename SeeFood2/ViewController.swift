//
//  ViewController.swift
//  SeeFood2
//
//  Created by Jason Becker on 5/19/19.
//  Copyright © 2019 Jason Becker. All rights reserved.
//

import UIKit
import VisualRecognition
import SVProgressHUD
import Social


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    let apiKey = "YOUR APP KEY"
    let version = "2019-05-19"
    
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        shareButton.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        cameraButton.isEnabled = false
        
        SVProgressHUD.show()
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            let imageData = image.jpegData(compressionQuality: 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imagesFile: fileURL) { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("hotdog"){
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")
                    }
                }
            }
            
            
        }
        else {
            print("there was an error picking the image")
        }
        
    }


    @IBAction func camerButtonPressed(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title)")
            vc?.add(UIImage(named: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
            
        }
        else {
            self.navigationItem.title = "Please Login to Twitter"
        }
        
    }
}

