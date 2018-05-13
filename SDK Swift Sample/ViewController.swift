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

class ViewController: UIViewController, DJIVideoFeedListener, DJISDKManagerDelegate, DJICameraDelegate{
    
    
    @IBOutlet weak var connectBtn:UIButton!
    @IBOutlet weak var CameraView:UIView!
    @IBOutlet weak var url:UITextField!
    @IBOutlet weak var statusBar:UILabel!
    
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do {
            try session.setPreferredSampleRate(44_100)
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .allowBluetooth)
            try session.setMode(AVAudioSessionModeDefault)
            try session.setActive(true)
        } catch {
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

    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        VideoPreviewer.instance().push(UInt8(videoData.bytes), length: Int(videoData.length))
        //push(UInt8(videoData.bytes), length: Int(videoData.length))
    }
    
    func appRegisteredWithError(_ error: Error?) {
        
    }
    
    func setupVideoPreviewer() {
        VideoPreviewer.instance().setView(CameraView)
        let product: DJIBaseProduct? = DJISDKManager.product()
        if product?.model == DJIAircraftModelNameA3 || product?.model == DJIAircraftModelNameN3 || product?.model == DJIAircraftModelNameMatrice600 || product?.model == DJIAircraftModelNameMatrice600Pro {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        VideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        VideoPreviewer.instance().unSetView()
        let product: DJIBaseProduct? = DJISDKManager.product()
        if product?.model == DJIAircraftModelNameA3 || product?.model == DJIAircraftModelNameN3 || product?.model == DJIAircraftModelNameMatrice600 || product?.model == DJIAircraftModelNameMatrice600Pro {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
    
    func fetchCamera() -> DJICamera? {
        if !(DJISDKManager.product() != nil) {
            return nil
        }
        if (DJISDKManager.product() is DJIAircraft) {
            return (DJISDKManager.product() as? DJIAircraft)?.camera
        } else if (DJISDKManager.product() is DJIHandheld) {
            return (DJISDKManager.product() as? DJIHandheld)?.camera
        }
        return nil
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if product != nil {
            product?.delegate = self as? DJIBaseProductDelegate
            let camera: DJICamera? = fetchCamera()
            if camera != nil {
                camera?.delegate = self
            }
            setupVideoPreviewer()
        }
    }
    

    @IBAction func connectBtn(_ sender: Any) {
        
    }
    
    

}
