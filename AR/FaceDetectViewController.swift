//
//  FaceDetectViewController.swift
//  AR
//
//  Created by MIS@NSYSU on 2020/9/17.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit
import AVKit
import Vision
import ARKit
import CoreML
import SceneKit

@available(iOS 11.0, *)
class FaceDetectViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ARSessionDelegate {
    @IBOutlet weak var sView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sView.delegate = self
        sView.showsStatistics = true
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        sView.session.pause()
        
    }
    
}
@available(iOS 11.0, *)
extension FaceDetectViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        let node = SCNNode(geometry: faceGeometry)
        
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        let text = SCNText(string: "", extrusionDepth: 2)
        let font = UIFont(name: "Avenir-Heavy", size: 18)
        text.font = font
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        text.materials = [material]
        text.firstMaterial?.isDoubleSided = true
        
        let textNode = SCNNode(geometry: faceGeometry)
        textNode.position = SCNVector3(-0.1, -0.01, -0.5)
        print(textNode.position)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        
        textNode.geometry = text
        
        guard let model = try? VNCoreMLModel(for: TheModel().model) else {
            fatalError("Unable to load model")
        }
        
        let coreMlRequest = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }
            
            DispatchQueue.main.async {[weak self] in
                print(topResult.identifier)
                if topResult.identifier != "Unknown" {
                    text.string = topResult.identifier
                    self!.sView.scene.rootNode.addChildNode(textNode)
                    self!.sView.autoenablesDefaultLighting = true
                }
            }
        }
        
        guard let pixelBuffer = self.sView.session.currentFrame?.capturedImage else { return }
        
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([coreMlRequest])
            } catch {
                print(error)
            }
        }
    }
    
}
