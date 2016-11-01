//
//  ViewController.swift
//  Club_Connect
//
//  Created by Li-Wei Tseng on 10/23/16.
//  Copyright © 2016 Li-Wei Tseng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let session         : AVCaptureSession = AVCaptureSession()
    
    var previewLayer    : AVCaptureVideoPreviewLayer!
    
    var highlightView   : UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBarcode()
    }
    /**
        Initialize iPhone camera and prepare to scan for barcode
     **/
    func initializeBarcode () {
        self.highlightView.autoresizingMask = [UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleBottomMargin]
        
        // Select the color for the completed scan reticle
        self.highlightView.layer.borderColor = UIColor.green.cgColor
        self.highlightView.layer.borderWidth = 3
        
        // Add it to our controller's view as a subview.
        self.view.addSubview(self.highlightView)
        
        
        // this is the camera
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input : AVCaptureDeviceInput? = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch  {
            print(error)
        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session) //layerWithSession(session) as AVCaptureVideoPreviewLayer
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        // Start the scanner. You'll have to end it yourself later.
        session.startRunning()

    }
    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRect.zero
        
        var barCodeObject : AVMetadataObject!
        
        var detectionString : String!
        
        
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeAztecCode
        ]
        
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            
            for barcodeType in barCodeTypes {
                
                if (metadata as AnyObject).type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    
                    highlightViewRect = barCodeObject.bounds
                    
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    print(detectionString)
                    if(detectionString != nil) {
                        self.session.stopRunning()
                        
                        var alert = UIAlertController()
                        
                        //                        let headers = [
                        //                            "X-Mashape-Key": "jY0bEhHCBpmsh8j1mpA5p11tCJGyp1tok3Zjsn4ubbvNNp5Jt3",
                        //                            "Accept": "application/json"
                        //                        ]
                        //                        let url = "https://nutritionix-api.p.mashape.com/v1_1/item?upc=" + detectionString
                        // BAD PRACTICE: turned off NSAppTransportSecurity by following the instruction http://stackoverflow.com/questions/32755674/ios9-getting-error-an-ssl-error-has-occurred-and-a-secure-connection-to-the-ser
                        //                        Alamofire.request(.GET, url, headers: headers)
                        //                            .responseJSON { response in
                        //                                if let JSON = response.result.value {
                        //
                        //                                    if let optional_error_code = JSON.value(forKey: "error_code") {
                        //                                        let error_code = optional_error_code as! String
                        //                                        if error_code == "item_not_found" {
                        //                                            print("not found")
                        //                                            alert = UIAlertController(title: "Item Not found", message: "Only support U.S. food products: Item ID or UPC was invalid", preferredStyle: UIAlertControllerStyle.alert)
                        //                                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        //                                            self.present(alert, animated: true, completion: {
                        //                                                self.session.startRunning()
                        //
                        //                                            })
                        //                                        }
                        //                                    } else {
                        //                                        self.nutrition = JSON
                        //                                        //                                        if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                        //                                        //
                        //                                        //                                            print(Array(jsonResult.keys)[0])
                        //                                        //                                            print(Array(jsonResult.values)[0])
                        //                                        //                                        }
                        //                                        super.performSegue(withIdentifier: "nutritionSegue", sender: self)
                        //                                        self.session.startRunning()
                        //                                    }
                        //
                        //
                        //
                        //                                }
                        //                        }
                        //
                        self.highlightView.frame = highlightViewRect
                        self.view.bringSubview(toFront: self.highlightView)
                        break
                    }
                    
                }
            }
        }
        
        
        
        
        
        func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
    }
}
