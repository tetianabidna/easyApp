//
//  ScannerViewController.swift
//  easyApp
//
//  Created by ksali001 on 12.12.19.
//  Copyright © 2019 tbidn001. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var barcode: String = ""
    var provision: Provision?
    
    @IBOutlet weak var helpTextView: UITextView!
   
    @IBOutlet weak var flashButton: UIButton!
    
    var flashIsOn: Bool = false
    
    @IBAction func flashButtonAction(_ sender: Any) {
        
        
       flashIsOn = !flashIsOn
        print(flashIsOn)
        if flashIsOn{
            turnOnTorch(device: AVCaptureDevice.default(for: .video)!)
            if #available(iOS 13.0, *) {
                flashButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            
        }else{
            turnOffTorch(device: AVCaptureDevice.default(for: .video)!)
            if #available(iOS 13.0, *) {
                flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    @IBOutlet weak var buttonBackground: UIViewX!
    
    @IBAction func promptText(_ sender: Any) {
        let ac = UIAlertController(title: "Barcode eingeben", message: "Barcode eingeben", preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            
            self.found(code: ac.textFields![0].text!)
           
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        }
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        
        present(ac, animated: true, completion: nil)
    }
    
   override func viewDidLoad() {
        super.viewDidLoad()

        
        context = appDelegate?.persistentContainer.viewContext
        
    
ProvisionsManager(context: context!)
    
    
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        scane()
        
    }
    
    func scane(){
        
        print("scane")
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        //Add Label and Button to camera view
        
        self.view.addSubview(helpTextView)
        self.view.addSubview(buttonBackground)
        self.view.addSubview(flashButton)
       
        
        

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func withDeviceLock(on device: AVCaptureDevice, block: (AVCaptureDevice) -> Void) {
        do {
            try device.lockForConfiguration()
            block(device)
            device.unlockForConfiguration()
        } catch {
            // can't acquire lock
        }
    }
    
    func turnOnTorch(device: AVCaptureDevice) {
        guard device.hasTorch else { return }
        withDeviceLock(on: device) {
            try? $0.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
        }
    }
    
    func turnOffTorch(device: AVCaptureDevice) {
        guard device.hasTorch else { return }
        withDeviceLock(on: device) {
            $0.torchMode = .off
        }
    }

    func found(code: String) {
        print(code)
        
        self.barcode = code
        self.provision = searchForElementInDB(barcodeValue: code)
        
        if(self.provision == nil){
            
            
            let warningAlert = UIAlertController(title: "", message: "Not found", preferredStyle: .alert)
            warningAlert.addAction(UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
                print("ok")
                self.captureSession.stopRunning()
                self.captureSession.startRunning()
            })
            DispatchQueue.main.async {
                self.present(warningAlert, animated: true, completion: nil)
            }
            
        }else{
            performSegue(withIdentifier: "resultScreenSegue", sender: self)
        }
    }

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if(segue.identifier == "resultScreenSegue"){
        
        // Create a new variable to store the instance of PlayerTableViewController
        let destinationVC = segue.destination as! ResultViewController
        
        destinationVC.barcodeValue = self.barcode
        destinationVC.provision = self.provision
        
    }
    }

    /*
    override var prefersStatusBarHidden: Bool {
        return true
    }
 */

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
     
    
    // DB
      // search one element in DB
      func searchForElementInDB(barcodeValue: String) -> Provision?{
    
          var result: Provision?
         
          
          do {
              let fetchRequest : NSFetchRequest<Provision> = Provision.fetchRequest()
              fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcodeValue)
              
              let fetchedResults = try context!.fetch(fetchRequest)
              
              if (fetchedResults.count > 1){
                  print("More than one Element has the same barcode :( ")
              }
              
              result = fetchedResults.first
          }
          catch {
              print ("fetch task failed", error)
          }
          
          
          return result
      }
        
}

