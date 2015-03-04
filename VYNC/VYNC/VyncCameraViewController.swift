//
//  VyncCameraViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 1/27/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class VyncCameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, VyncCameraPlaybackLayerDelegate {
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice!
    var selfieCaptureDevice : AVCaptureDevice!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var captureMovieFileOutput: AVCaptureMovieFileOutput? = nil;
    var videoConnection : AVCaptureConnection!
    var vync : Vync!
    var rotating = false
    var playerLayerView : VyncCameraPlaybackLayer!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCamera()
//        let flash = NSString(
        flashButton.setTitle("\u{e002}", forState: .Normal)
        flipCameraButton.setTitle("\u{e005}", forState: .Normal)
        recordButton.setTitle("\u{e000}", forState: .Normal)
        let backToVyncView = UIScreenEdgePanGestureRecognizer(target: self, action: "dismissCamera:")
        backToVyncView.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(backToVyncView)
        
        if captureDevice != nil {
            beginSession()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    func setupCamera(){
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if device.hasMediaType(AVMediaTypeVideo) {
                // Finally check the position and confirm we've got the back camera
                if device.position == AVCaptureDevicePosition.Back  {
                    captureDevice = device as? AVCaptureDevice
                }
                if device.position == AVCaptureDevicePosition.Front {
                    selfieCaptureDevice = device as? AVCaptureDevice
                }
            }
        }
        captureSession.sessionPreset = AVCaptureSessionPresetMedium
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        captureMovieFileOutput?.maxRecordedDuration = CMTimeMakeWithSeconds(6, 600)
        captureSession.addOutput(captureMovieFileOutput)
        videoConnection = captureMovieFileOutput?.connectionWithMediaType(AVMediaTypeVideo)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func autoFlash(sender: AnyObject) {
        // Set only the torch since flash is for still photos
        if captureDevice.torchAvailable {
            if captureDevice.torchMode.hashValue == 0 {
                captureDevice.lockForConfiguration(nil)
                captureDevice.torchMode = AVCaptureTorchMode.Auto
                flashButton.setTitle("\u{e003}", forState: .Normal)
                captureDevice.unlockForConfiguration()
            } else {
                captureDevice.lockForConfiguration(nil)
                captureDevice.torchMode = AVCaptureTorchMode.Off
                flashButton.setTitle("\u{e002}", forState: .Normal)
                captureDevice.unlockForConfiguration()
            }
        }
    }
    
    @IBAction func flipCamera(sender: AnyObject) {
        println("flipping camera")
        captureSession.beginConfiguration()
        if let currentCamera = captureSession.inputs.last as? AVCaptureDeviceInput {
            if currentCamera.device.position == AVCaptureDevicePosition.Back {
                captureSession.removeInput(captureSession.inputs.last as AVCaptureInput)
                captureSession.addInput(AVCaptureDeviceInput(device: selfieCaptureDevice, error: nil))
                flashButton.hidden = true
            } else {
                captureSession.removeInput(captureSession.inputs.last as AVCaptureInput)
                captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: nil))
                flashButton.hidden = false
            }
        }
        captureSession.commitConfiguration()
    }
    
    func beginSession() {
        var err : NSError? = nil
        // Set up audio input
        let audioCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
        let audioInput = AVCaptureDeviceInput.deviceInputWithDevice(audioCaptureDevice[0] as AVCaptureDevice, error: nil)  as AVCaptureInput
        captureSession.addInput(audioInput)
        // Add existing video input
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))

        let tap = UITapGestureRecognizer(target:self, action:"onTap:")
        self.view.addGestureRecognizer(tap)
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = UIScreen.mainScreen().bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(previewLayer, atIndex: 0)
        captureSession.startRunning()
    }
    
    @IBAction func startRecording(sender: AnyObject) {
        println("startRecording")
        let fileUrl = NSURL.fileURLWithPath(pathToFile) as NSURL!
        captureMovieFileOutput!.startRecordingToOutputFileURL(fileUrl, recordingDelegate: self)
        rotating = true
        rotateOnce()
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        println("endRecording")
        rotating = false
        captureMovieFileOutput?.stopRecording()
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!,
        didStartRecordingToOutputFileAtURL fileURL: NSURL!,
        fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!,
        didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!,
        fromConnections connections: [AnyObject]!,
        error: NSError!) {
            println("playing back video")
            playerLayerView = VyncCameraPlaybackLayer.loadFromNib() as VyncCameraPlaybackLayer
            playerLayerView.videoList = [outputFileURL, outputFileURL]
            playerLayerView.playbackDelegate = self
            playerLayerView.playVideos()
            self.view.addSubview(playerLayerView)
    }
    
    
    @IBAction func dismissCamera(sender: AnyObject) {
        if let gesture = sender as? UIScreenEdgePanGestureRecognizer {
            if gesture.state == .Ended {
                transitionToRootView()
            }
        } else {
                transitionToRootView()
        }
    }
    
    func transitionToRootView(){
        if self.playerLayerView != nil {
            self.playerLayerView.removeFromSuperview()
            // This is necessary because if there is still
            // a pointer to the playerLayer, it won't deinit
            self.playerLayerView = nil
        }
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RootNavigationController") as UINavigationController
        presentViewController(vc, animated: false, completion: {})
    }
    
    func onTap (tap: UITapGestureRecognizer){
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusPointOfInterest = tap.locationInView(self.view)
            device.exposurePointOfInterest = tap.locationInView(self.view)
            device.unlockForConfiguration()
        }
    }
    // Playback Delegate Methods
    func retakeVideo(view:VyncCameraPlaybackLayer) {
        self.playerLayerView = nil
        view.removeFromSuperview()
        
    }
    
    func acceptVideo(view:VyncCameraPlaybackLayer) {
        view.removeFromSuperview()
        self.playerLayerView = nil
        if (self.vync != nil) {
            let contactsNav = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsNav") as UINavigationController
            // Instantiate contacts to set its replyToId property
            let contacts = contactsNav.viewControllers[0] as ContactsViewController
            contacts.replyToId = vync.replyToId()
            self.presentViewController(contactsNav, animated: false, completion: nil)
        } else {
            let title = self.storyboard?.instantiateViewControllerWithIdentifier("TitleNav") as UINavigationController
            self.presentViewController(title, animated: false, completion: nil)
        }
    }
    
    func rotateOnce() {
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .CurveLinear,
            animations: {self.recordButton.transform = CGAffineTransformRotate(self.recordButton.transform, 3.1415926)},
            completion: {finished in self.rotateAgain()})
    }
    
    func rotateAgain() {
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .CurveLinear,
            animations: {self.recordButton.transform = CGAffineTransformRotate(self.recordButton.transform, 3.1415926)},
            completion: {finished in if self.rotating { self.rotateOnce() }})
    }

}

