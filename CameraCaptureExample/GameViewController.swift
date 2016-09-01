//
//  GameViewController.swift
//  CameraCaptureExample
//
//  Copyright (c) 2016 NybbleGames. All rights reserved.
//

import AVFoundation
import UIKit
import QuartzCore
import SceneKit

let USE_FRONT_CAMERA = true
let USE_LAYER_AS_MATERIAL = true

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))

        let cubeGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(0.0, -2.0, 0.0)

        scene.rootNode.addChildNode(cubeNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        let videoPreviewLayer = self.videoPreviewLayer()
        guard let layer = videoPreviewLayer else {
            return
        }

        if USE_LAYER_AS_MATERIAL {
            cubeGeometry.firstMaterial?.diffuse.contents = layer
        } else {
            scnView.layer.addSublayer(layer)
        }
    }

    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }

    func videoPreviewLayer() -> CALayer? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)

        var camera:AVCaptureDevice?

        for device in devices {
            guard let captureDevice = device as? AVCaptureDevice else { continue }

            if USE_FRONT_CAMERA {
                if captureDevice.position == AVCaptureDevicePosition.Front {
                    camera = captureDevice
                }
            } else {
                if captureDevice.position == AVCaptureDevicePosition.Back {
                    camera = captureDevice
                }
            }
        }

        guard let cam = camera else { return nil }

        var videoInput:AVCaptureDeviceInput?
        do {
            videoInput = try AVCaptureDeviceInput(device: cam)
        } catch {
            // TODO*: More error information
            return nil
        }

        // Set up sessions and connections
        let captureSession = AVCaptureSession()
        captureSession.addInput(videoInput)
        captureSession.sessionPreset = AVCaptureSessionPreset640x480

        let textureSize:CGFloat = 256.0;
        let cameraPreview:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreview.frame = CGRectMake(0, 0, textureSize, textureSize)
        cameraPreview.backgroundColor = UIColor.orangeColor().CGColor

        captureSession.startRunning()

        return cameraPreview
    }


    override func shouldAutorotate() -> Bool {
        return true
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
