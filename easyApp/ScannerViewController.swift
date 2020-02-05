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
    var flashIsOn: Bool = false
    
    @IBOutlet weak var helpTextView: UITextView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var buttonBackground: UIViewX!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        
        ProvisionsManager(context: context!) // to comment
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        scanBarcode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        //Add Label and Button to camera view
        self.view.addSubview(helpTextView)
        self.view.addSubview(buttonBackground)
        self.view.addSubview(flashButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func flashButtonAction(_ sender: Any) {
        
        flashIsOn = !flashIsOn
        
        if flashIsOn{
            
            turnOnFlash(device: AVCaptureDevice.default(for: .video)!)
            
            if #available(iOS 13.0, *) {
                flashButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }else{
            
            turnOffFlash(device: AVCaptureDevice.default(for: .video)!)
            
            if #available(iOS 13.0, *) {
                flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func promptTextAlert(_ sender: Any) {
        
        let alert = UIAlertController(title: "Barcode eingeben", message: "Barcode eingeben", preferredStyle: .alert)
        alert.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
            
            self.findProvisionWithBarcode(code: alert.textFields![0].text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in }
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scanBarcode(){
        
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
        
        captureSession.startRunning()
    }
    
    func findProvisionWithBarcode(code: String) {
        
        self.barcode = code
        self.provision = searchForProvisionInCD(barcodeValue: code)
        
        if(self.provision == nil){
            
            let warningAlert = UIAlertController(title: "Warnung", message: "Produkt wurde nicht gefunden", preferredStyle: .alert)
            warningAlert.addAction(UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
                
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
            
            destinationVC.provision = self.provision
        }
    }
    
    func failed() {
        
        let alert = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        captureSession = nil
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            findProvisionWithBarcode(code: stringValue)
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
    
    func turnOnFlash(device: AVCaptureDevice) {
        guard device.hasTorch else { return }
        withDeviceLock(on: device) {
            try? $0.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
        }
    }
    
    func turnOffFlash(device: AVCaptureDevice) {
        guard device.hasTorch else { return }
        withDeviceLock(on: device) {
            $0.torchMode = .off
        }
    }
    
    // search provision in CoreData
    func searchForProvisionInCD(barcodeValue: String) -> Provision?{
        
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
