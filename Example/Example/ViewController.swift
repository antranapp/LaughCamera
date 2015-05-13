//
//  UnlockPatternViewController.swift
//  SmilingAlarmClock
//
//  Created by Tran Le on 29/04/15.
//  Copyright (c) 2015 TBA. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, FastttCameraDelegate {
    
    var fastCamera = FastttCamera()

    @IBOutlet var smileProgressView: RoundProgressView!
    @IBOutlet var leftBlinkProgressView: RoundProgressView!
    @IBOutlet var rightBlinkProgressView: RoundProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fastCamera.delegate = self
        self.fastCamera.willMoveToParentViewController(self)
        self.fastCamera.beginAppearanceTransition(true, animated: false)
        self.addChildViewController(self.fastCamera)
        self.view.insertSubview(self.fastCamera.view, belowSubview: smileProgressView)
        self.fastCamera.didMoveToParentViewController(self)
        self.fastCamera.endAppearanceTransition()
        
        self.fastCamera.view.frame = self.view.frame
        
        if (FastttCamera .isCameraDeviceAvailable(FastttCameraDevice.Front)) {
            self.fastCamera.cameraDevice = FastttCameraDevice.Front
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        //stopSmileDetection()
    }
    
    // MARK: DSFacialDetectorDelegate
    func cameraController(cameraController: FastttCameraInterface!, didRegisterFacialGestureOfType facialGestureType: FCGestureType) {
        switch (facialGestureType) {
        case FCGestureType.Smile:
            println("Found smile")
            break
        case FCGestureType.LeftBlink:
            println("Found left blink")
            break
        case FCGestureType.RightBlink:
            println("Found right blink")
            break
        default:
            break
        }
    }
    
    func cameraController(cameraController: FastttCameraInterface!, didUpdateFacialGestureProgress progress: Float, forType facialGestureType: FCGestureType) {
        if let progressView = getProgressViewForGestureType(facialGestureType) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                progressView.progress = progress
            })
        }
    }
    
    
    // MARK: Private

    func getProgressViewForGestureType(gestureType: FCGestureType) -> RoundProgressView? {
        if (gestureType == FCGestureType.LeftBlink) { // FrontCamera is mirroed -> LeftBlink ---> rightProgressView
            return self.rightBlinkProgressView
        }
        
        if (gestureType == FCGestureType.RightBlink) { // FrontCamera is mirroed -> RightBlink ---> leftProgressView
            return self.leftBlinkProgressView
        }
        
        if (gestureType == FCGestureType.Smile) {
            return self.smileProgressView
        }
        
        return nil;
    }
}
