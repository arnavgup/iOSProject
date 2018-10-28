//
//  ViewController.swift
//  Attendify
//
//  Created by George Yao on 10/28/18.
//  Copyright © 2018 CMU IS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration() // Configurations allow us for debug info
  
    // gorillalogic.com/blog/how-to-build-a-face-recognition-app-in-ios-using-coreml-and-turi-create-part-1/

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
  
      var sampleCounter = 0
      let requiredSamples = 25
      var faceImages = [UIImage]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // WolrdOrigin is location of device at starttime, and featurepoints are features detected by camera
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
      
        // Run the session with the above config
        self.sceneView.session.run(configuration)
      
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
  
  
    func configureAVSession() {
      //use the front camera if need to track the user face, and the back camera when tracking other's people face
      guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                        for: AVMediaType.video,
                                                        position: isIdentifiyngPeople ? .back : .front) else {
                                                          preconditionFailure("A Camera is needed to start the AV session")
      }
      
      guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
        preconditionFailure("unable to get input from AVDevice")
      }
      
      let output = AVCaptureVideoDataOutput()
      output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
      output.alwaysDiscardsLateVideoFrames = true
      
      session.beginConfiguration()
      
      if session.canAddInput(deviceInput) {
        session.addInput(deviceInput)
      }
      if session.canAddOutput(output) {
        session.addOutput(output)
      }
      
      session.commitConfiguration()
      
      let queue = DispatchQueue(label: "output.queue")
      output.setSampleBufferDelegate(self, queue: queue)
      
      session.startRunning()
    }
  
    func configurePreviewLayer() {
      if let layer = self.previewLayer {
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
      }
    }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
      let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        as? [String: Any] else  {
          return
    }
    let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: attachments )
    let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImageOrientation.leftMirrored.rawValue))
    
    detectFace(on: ciImageWithOrientation)
  }

  
  
  

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
