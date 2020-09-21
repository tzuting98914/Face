//
//  ARViewController.swift
//  AR
//
//  Created by MIS@NSYSU on 2020/9/17.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit
import ARKit
import Vision

@available(iOS 11.0, *)
class ARViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    let faceDetection = VNDetectFaceRectanglesRequest()
    let faceDetectionRequest = VNSequenceRequestHandler()
    var faceClassificationRequest: VNCoreMLRequest!
    var lastObservation : VNFaceObservation?
    
    var session = AVCaptureSession()
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        var previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()
    

    
}
