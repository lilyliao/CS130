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
    
    var event : KinveyEventData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBarcode()
        if (KCSUser.active()) != nil {
            print("user is active")
        } else {
            print("user is not active")
        }
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
    
    
    func userCheckIn(student_id : String, event : KinveyEventData ) {
        let collection = KCSCollection.user()
        let userStore = KCSAppdataStore(collection: collection, options: nil)!
        var alert = UIAlertController()
        
        userStore.query(
            withQuery: KCSQuery(onField: "UID", withExactMatchForValue: student_id as NSString),
            withCompletionBlock: { usersOrNil, errorOrNil in
                if errorOrNil != nil {
                    //An error happened, just log for now
                    print("An error occurred on fetch: \(errorOrNil)");
                } else {
                    if let user = usersOrNil?.first as? KCSUser {
                        let attendee_name = user.getValueForAttribute("name") as! String
                        let collection = KCSCollection(from: "Event", of: KinveyEventData.self)
                        let dataStore = KCSAppdataStore(collection: collection, options: nil)!
                        dataStore.save(
                            event,
                            withCompletionBlock: { objectsOrNil, errorOrNil in
                                if let objectsOrNil = objectsOrNil?.first as? KinveyEventData {
                                    //save was successful
                                    alert = UIAlertController(title: attendee_name, message: "check in", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: {
                                        self.session.startRunning()
                                        
                                    })

                                    
                                } else if let errorOrNil = errorOrNil as? NSError {
                                    //save failed
                                    print("Save failed, with error: \(errorOrNil.localizedFailureReason)")
                                }
                        },
                            withProgressBlock: nil
                        )
                    } else {
                        alert = UIAlertController(title: "User Not found", message: "Download the App and register", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: {
                            self.session.startRunning()
                            
                        })
                    }
                }
        },
            withProgressBlock: nil
        )
    }

    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRect.zero
        
        var barCodeObject : AVMetadataObject!
        
        var detectionString : String!
        
        var student_id : String!
        
        
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
                    
                    if(detectionString != nil) {
                        print(detectionString)
//                        student_id = (detectionString as NSString).substring(with: NSMakeRange(0, 9))
                        student_id = String(detectionString.characters.dropLast())
                        if(student_id != nil) {
                            self.session.stopRunning()
                            
                            event.attendee_id = student_id
                            self.userCheckIn(student_id: student_id!, event: event!)
                        
                            
                        }

                    }
                    self.highlightView.frame = highlightViewRect
                    self.view.bringSubview(toFront: self.highlightView)
                    break
                }
            }
        }
    }
    
        
        
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
