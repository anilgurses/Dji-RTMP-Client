//
//  ViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Anıl Gürses on 13.05.2018.
//  Copyright © 2018 DJI. All rights reserved.
//

import UIKit
import DJISDK
import VideoPreviewer
import AVFoundation
import HaishinKit

class ViewController: UIViewController, DJIVideoFeedListener, DJISDKManagerDelegate, DJICameraDelegate{
    
    
    @IBOutlet weak var connectBtn:UIButton!
    @IBOutlet weak var CameraView:UIView!
    @IBOutlet weak var url:UITextField!
    @IBOutlet weak var statusBar:UILabel!
    
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        DJISDKManager.registerApp(with: self)
        
        do {
            try session.setPreferredSampleRate(44_100)
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .allowBluetooth)
            try session.setMode(AVAudioSessionModeDefault)
            try session.setActive(true)
        } catch {
            statusBar.text = "Error while connecting to server"
        }        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let camera: DJICamera? = fetchCamera()
        if camera != nil {
            camera?.delegate = nil
        }
        resetVideoPreview()
    }

    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        VideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    func appRegisteredWithError(_ error: Error?) {
        
    }
    
    func setupVideoPreviewer() {
        
        VideoPreviewer.instance().setView(self.CameraView)
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        VideoPreviewer.instance().start()
    }
    func resetVideoPreview() {
        VideoPreviewer.instance().unSetView()
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
    
    func fetchCamera() -> DJICamera? {
        let product = DJISDKManager.product()
        
        if (product == nil) {
            return nil
        }
        
        if (product!.isKind(of: DJIAircraft.self)) {
            return (product as! DJIAircraft).camera
        } else if (product!.isKind(of: DJIHandheld.self)) {
            return (product as! DJIHandheld).camera
        }
        return nil
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        
        NSLog("Product Connected")
        
        if (product != nil) {
            let camera = self.fetchCamera()
            if (camera != nil) {
                camera!.delegate = self
            }
            self.setupVideoPreviewer()
        }
        

        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if(error != nil){
                NSLog("Login failed: %@" + String(describing: error))
            }
        }
        
    }
    
    func productDisconnected() {
        
        NSLog("Product Disconnected")
        
        let camera = self.fetchCamera()
        if((camera != nil) && (camera?.delegate?.isEqual(self))!){
            camera?.delegate = nil
        }
        self.resetVideoPreview()
    }

    @IBAction func connectBtn(_ sender: Any) {
        let strurl = url.text
        let rtmpConnection:RTMPConnection = RTMPConnection()
        let rtmpStream: RTMPStream = RTMPStream(connection: rtmpConnection)
        rtmpStream.attachScreen(ScreenCaptureSession(shared: UIApplication.shared))
        let lfView: LFView = LFView(frame: view.bounds)
        lfView.attachStream(rtmpStream)
        rtmpConnection.connect(strurl!)
        rtmpStream.publish("deneme")
        statusBar.text = "Connection is started"
    }
    
    

}
