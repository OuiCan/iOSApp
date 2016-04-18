//
//  TesseractViewController.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 3/22/16.
//  Copyright © 2016 mac. All rights reserved.

//
import UIKit
import Foundation

class TesseractViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!

    var recieptDelegate: reportScannedRecieptDelegate? = nil
    var activityIndicator:UIActivityIndicatorView!
    var originalTopMargin:CGFloat!
    var recognizedUPC = [String]()
    var correctedUPC = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation Color
        //navigationController!.navigationBar.barTintColor = UIColor(red: 12.0/255.0, green: 200.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //originalTopMargin = topMarginConstraint.constant
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        view.endEditing(true)
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Reciept",
            message: nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func performImageRecognition(image: UIImage) -> String {
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        return tesseract.recognizedText
    }
    
    
    func parseRecognizedTextForUPC(recognizedText: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "[0-9]{12}", options: [])
            let nsString = recognizedText as NSString
            let results = regex.matchesInString(recognizedText, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    
     // Activity Indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }

}


extension TesseractViewController: UIImagePickerControllerDelegate{
    
    func addCheckbit( upc: String) -> String{
        let upcIntArray = upc.characters.flatMap{Int(String($0))}
        var checkSum = 0
        
        
        for index in 0...(upcIntArray.count-1) {
            let digit = upcIntArray[index]
            
            if index%2 == 0 {
                checkSum = checkSum + digit
            }
            else{
                checkSum = checkSum + (3*digit)
            }
        }
        
        let checkDigit = String((10 - (checkSum%10))%10)
        
        return upc + checkDigit
        
    }
    
    func addCheckbitToArray(recognizedUPC: [String]) -> [String]{
        var result = [String]()
        for upc in recognizedUPC{
            let correctedUPC = addCheckbit(upc)
            result.append(correctedUPC)
        }
        return result
    }
    
    @IBAction func uploadToInventory(sender: AnyObject) {
        //Only call if button is pushed
        if (self.recieptDelegate != nil) {
            self.recieptDelegate!.uploadReceipt(self.correctedUPC)
            self.textView.text = "Uploading UPCs to server..."
        }
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 3840)
            
            addActivityIndicator()
            
            dismissViewControllerAnimated(true, completion: {
                
                let recognizedText = self.performImageRecognition(scaledImage)
                self.recognizedUPC = self.parseRecognizedTextForUPC(recognizedText)
                self.correctedUPC = self.addCheckbitToArray(self.recognizedUPC)
                print(self.correctedUPC)
                
                //Display UPC in text box
                self.textView.text = ""
                
                
                if self.recognizedUPC.count == 0 {
                    self.textView.text = "No UPC Found. Please Try Again."
                }
                
                else {
                    for upc in self.correctedUPC {
                        self.textView.text = self.textView.text + upc + "\n"
                    }
                }
                
                self.removeActivityIndicator()
            })
            
            
    }
}
