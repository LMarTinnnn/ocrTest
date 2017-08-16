//
//  ViewController.swift
//  CustomCamera
//
//  Created by 刘勇博 on 2017/8/13.
//  Copyright © 2017年 Magicarp. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    //model
    var torchOn = false {
        didSet {
            torchIndicator?.text = torchOn ? "ON" : "OFF"
        }
    }
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice? {
        // change camera
        didSet {
            if captureSession.inputs.count != 0 {
                do {
                    let newInput = try AVCaptureDeviceInput(device: currentCamera!)
                    captureSession.removeInput(captureSession.inputs[0])
                    captureSession.addInput(newInput)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureVideoDataOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var photoGot: UIImage?
    
    func setUpSession(){
        //set up the quality of the session
        captureSession.sessionPreset = .photo
    }
    func setUpDevice(){
        //find the cameras
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else {
                frontCamera = device
            }
        }
        //set default camera to backCamera
        currentCamera = backCamera
    }
    
    func setUpInputOutput(){
        do {
            //got the input from the device
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            
            captureSession.addInput(captureDeviceInput)
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setUpPreviewLayer(){
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //set the preview layer's gravity
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //set the preview layer's orentation to portrait
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.bounds
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let photoData = photo.fileDataRepresentation() {
            photoGot = UIImage(data: photoData)
        }
        performSegue(withIdentifier: "showPhotoSegue", sender: nil)
        if torchOn { tuggleTorch(UIButton())}
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first! as UITouch
        let screenSize = self.view.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: self.view).y / screenSize.height, y: 1.0 - touchPoint.location(in: self.view).x / screenSize.width)
        
        if let device = currentCamera {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .continuousAutoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .continuousAutoExposure
                }
                device.unlockForConfiguration()
                
            } catch {
                print("error")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoSegue" {
            if let previewVC = segue.destination as? ShowPhotoViewController {
                previewVC.photoToShow = self.photoGot
            }
        }
    }
    
    //vc
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSession()
        setUpDevice()
        setUpInputOutput()
        setUpPreviewLayer()
        startRunningCaptureSession()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.size.height/2
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        let photoSetting = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: photoSetting, delegate: self)
        //performSegue(withIdentifier: "showPhotoSegue", sender: nil)
    }
    
    @IBAction func changeCamera(_ sender: UIButton) {
        if currentCamera == backCamera {
            currentCamera = frontCamera
            torchOn = false
        } else {
            currentCamera = backCamera
        }
    }
    
    @IBAction func tuggleTorch(_ sender: UIButton) {
        if currentCamera!.hasTorch {
            torchOn = !torchOn
            do {
                try currentCamera?.lockForConfiguration()
                
                if torchOn {
                    currentCamera?.torchMode = .on
                } else {
                    currentCamera?.torchMode = .off
                }
                
                currentCamera?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    //view
    
    @IBOutlet weak var torchIndicator: UILabel?
    @IBOutlet weak var takePhotoButton: UIButton!

    
}

