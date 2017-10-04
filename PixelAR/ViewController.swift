//
//  ViewController.swift
//  PixelAR
//
//  Created by Byfield, Jade on 9/22/17.
//  Copyright © 2017 Byfield, Jade. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO
import Photos

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var modeButton: UIButton!
    var anchors = [ARAnchor]()
    var planeHeight: CGFloat = 0.01
    var photoNode: SCNNode!
    var isSessionRunning = false
    var coverMaterial: SCNMaterial!
    var planeZPosition: Float?
    var wallHeight = 3.0
    var wallNode: SCNNode?
    let panRecognizer = UIPanGestureRecognizer()
    var translationY : CGFloat!
    var frameNode: SCNNode?
    var wallZPosition: Float?
    var degrees = Measurement(value: 1, unit: UnitAngle.degrees)
        .converted(to: .radians).value
    
    var currentAngle = Float(0.07)
    let wallPosition = SCNVector3(0, 0, -2.0)
    
    
    @IBOutlet weak var planeLengthTextView: UITextView!
    var touchMode: TouchMode?
    
    
    enum TouchMode{
        
        case ROTATION
        case TRANSLATION
    }
    
    func setTouchMode(mode: TouchMode){
        touchMode = mode
    }
    
    func getTouchMode() -> TouchMode{
        
        return touchMode!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        setTouchMode(mode: TouchMode.TRANSLATION)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.configuration?.isLightEstimationEnabled = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        panRecognizer.addTarget(self, action: #selector(pannedView))
        self.view.addGestureRecognizer(panRecognizer)
        
        let wallMaterial = SCNMaterial()
        wallMaterial.diffuse.contents = UIColor.cyan
        wallMaterial.transparency = 0.5
        wallMaterial.isDoubleSided = true
        
        let wallPlane = SCNBox(width: 1.0, height: CGFloat(wallHeight / 3), length: 0.01, chamferRadius: 0)
        wallNode = SCNNode()
        wallNode?.geometry = wallPlane
        wallNode?.geometry?.firstMaterial = wallMaterial
        wallNode?.physicsBody = SCNPhysicsBody.static()
        
        wallNode?.position = wallPosition
        wallZPosition = wallPosition.z
        
        placePictureFrame(wallPosition)
        sceneView.scene.rootNode.addChildNode(wallNode!)
        
        
    }
    
    
    // Called when the view is about to be displayed on the screen
    // Setup/configure additional views here
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Tell the session to automatically detect horizontal planes
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        isSessionRunning = true;
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func changeMode(_ sender: UIButton) {
        print("changeMode")
        
        if(touchMode == TouchMode.TRANSLATION){
            modeButton.setTitle("Mode: Rotation", for: UIControlState.normal)
            print("Touch mode now ROTATION")
            touchMode = TouchMode.ROTATION
        }else{
            modeButton.setTitle("Mode: Translation", for: UIControlState.normal)
            print("Touch mode now TRANSLATION")
            touchMode = TouchMode.TRANSLATION
            
        }
        
    }
    @IBAction func resetARSession(_ sender: Any) {
        print("Reset AR session!")
        
        /// Creates a new AR configuration to run on the `session`.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Remove all objects/planes in the current scene
        sceneView.scene.rootNode.enumerateChildNodes{ (node, stop) -> Void in
            node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        placePictureFrame(wallPosition)
        
        let wallMaterial = SCNMaterial()
        wallMaterial.diffuse.contents = UIColor.cyan
        wallMaterial.transparency = 0.5
        wallMaterial.isDoubleSided = true
        
        let wallPlane = SCNBox(width: 1.0, height: CGFloat(wallHeight / 3), length: 0.01, chamferRadius: 0)
        wallNode = SCNNode()
        wallNode?.geometry = wallPlane
        wallNode?.geometry?.firstMaterial = wallMaterial
        wallNode?.physicsBody = SCNPhysicsBody.static()
        
        wallNode?.position = wallPosition
        wallZPosition = wallPosition.z
        
        sceneView.scene.rootNode.addChildNode(wallNode!)
        
        
    }
    
    func placePictureFrame(_ position: SCNVector3){
        
        let scene = SCNScene(named: "art.scnassets/high_poly_frame.scn")!
        let mainScene = SCNScene()
        sceneView.scene = mainScene
        // MARK: Set up picture frame
        frameNode = scene.rootNode.childNode(withName: "frame", recursively: true)
        frameNode?.scale = SCNVector3(0.003, 0.003, 0.003)
        frameNode?.position = position
        frameNode?.pivot = SCNMatrix4MakeRotation(Float(CGFloat(Double.pi / 2)), 1, 0, 0)
        frameNode?.physicsBody = SCNPhysicsBody.static()
        frameNode?.castsShadow = true
        
        let woodMaterial = SCNMaterial()
        woodMaterial.diffuse.contents = UIImage(named: "art.scnassets/pine.jpg")
        frameNode?.geometry?.materials = [woodMaterial]
        woodMaterial.isDoubleSided = true
        woodMaterial.locksAmbientWithDiffuse = true
        
        
        // MARK: Set up photo to go inside of frame
        photoNode = SCNNode()
        photoNode.position = SCNVector3(x: position.x, y: position.y, z: (position.z) + 0.0123)
        photoNode.geometry = SCNBox(width: 0.28, height: 0.28, length: 0.00, chamferRadius: 0.0)
        photoNode.castsShadow = true
        
        coverMaterial = SCNMaterial()
        coverMaterial.diffuse.contents = UIImage(named: "bk")
        
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.white
        
        let materials = [coverMaterial, sideMaterial, sideMaterial, sideMaterial, sideMaterial, sideMaterial]
        photoNode.geometry?.materials = materials as! [SCNMaterial]
        
        let physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 0.003, height: 0.004, length: 0.001, chamferRadius: 0.0))
        )
        
        photoNode.physicsBody = physicsBody
        
        //Add spotlight to frame
        let light = SCNLight()
        light.type = .spot
        light.shadowMode = .forward
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.castsShadow = true
        let lightNode = SCNNode()
        lightNode.position = SCNVector3((frameNode?.position.x)! / 2,
                                        (frameNode?.position.y)! / 2 + 10,
                                        (frameNode?.position.z)! / 2)
        lightNode.look(at: (frameNode?.position)!)
        lightNode.light = light
        mainScene.rootNode.addChildNode(lightNode)
        
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        mainScene.rootNode.addChildNode(ambientLightNode)
        
        mainScene.rootNode.addChildNode(frameNode!)
        mainScene.rootNode.addChildNode(photoNode)
    }
    
    @objc
    func pannedView(sender: UIPanGestureRecognizer){
        print("Panned view!")
        
        let velocity = sender.velocity(in: self.view)
        let translation = sender.translation(in: self.view)
        print("Velocity -> " + String(describing: velocity))
        print("Translation -> " + String(describing: translation))
        
        let vertical = fabs(velocity.y) > fabs(velocity.x)
        
        let currentPosition = wallNode?.position
        print("Current Z position -> " + String(describing: currentPosition?.z))
        
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let y)
            where y < 0:
            if(touchMode == TouchMode.TRANSLATION){
                print("Pan UP!")
                let currentZ = currentPosition?.z
                
                self.wallNode?.position.z = currentZ! - 0.01
                self.frameNode?.position.z = currentZ! - 0.01
                self.photoNode?.position.z = ((self.frameNode?.position.z)! + 0.0123)
                
                
                print("Moving wall forward to " + String(describing: currentZ! - 0.01))
                
            }
            return
        case (true, _, let y)
            where y > 0:
            
            if(touchMode == TouchMode.TRANSLATION){
                print("Pan DOWN!")
                let currentZ = currentPosition?.z
                
                self.wallNode?.position.z = currentZ! + 0.01
                self.frameNode?.position.z = currentZ! + 0.01
                self.photoNode?.position.z = ((self.frameNode?.position.z)! + 0.0123)
                
                print("Moving wall backward to " + String(describing: currentZ! + 0.01))
            }
            
            
            return
        case (false, let x, _)
            where x > 0:
            
            if(touchMode == TouchMode.ROTATION){
                print("Pan RIGHT!")
                
                //getting the CGpoint at the end of the pan
                let translation = sender.translation(in: sender.view!)
                //creating a new angle in radians from the x value
                var newAngle = (Float)(translation.x)*(Float)(Double.pi)/180.0
                //current angle is an instance variable so i am adding the newAngle to the newAngle to it
                newAngle += currentAngle
                
                // Make the rotation
                wallNode?.transform = SCNMatrix4MakeRotation(newAngle, 0.0, 1.0, 0.0)
                //getting the end angle of the swipe put into the instance variable
                if(sender.state == UIGestureRecognizerState.ended) {
                    currentAngle = newAngle
                }
                print("Wall rotation -> " + String(describing: self.wallNode?.rotation))
            }
            return
        case (false, let x, _)
            where x < 0:
            
            if(touchMode == TouchMode.ROTATION){
                print("Pan LEFT!")
                
                //getting the CGpoint at the end of the pan
                let translation = sender.translation(in: sender.view!)
                //creating a new angle in radians from the x value
                var newAngle = (Float)(translation.x)*(Float)(Double.pi)/180.0
                //current angle is an instance variable so i am adding the newAngle to the newAngle to it
                newAngle -= currentAngle
                
                // Make the rotation
                wallNode?.transform = SCNMatrix4MakeRotation(newAngle, 0.0, 1.0, 0.0)
                
                //getting the end angle of the swipe put into the instance variable
                if(sender.state == UIGestureRecognizerState.ended) {
                    currentAngle = newAngle
                }
                print("Wall rotation -> " + String(describing: self.wallNode?.rotation))
            }
            return
            
        default: print("<#T##items: Any...##Any#>")
        }
        
        
        
        
        
        //        switch(velocity.y > 0){
        //
        //        case true:
        //            print("Pan UP!")
        //
        //            let currentZ = currentPosition?.z
        //
        //
        //            self.wallNode?.position.z = currentZ! + 0.01
        //            self.frameNode?.position.z = currentZ! + 0.01
        //            self.photoNode?.position.z = ((self.frameNode?.position.z)! + 0.0123)
        //
        //            print("Moving wall backward to " + String(describing: currentZ! + 0.01))
        //
        //
        //            break
        //        case false:
        //            print("Pan DOWN!")
        //            let currentZ = currentPosition?.z
        //
        //            self.photoNode?.position.z = ((self.frameNode?.position.z)! + 0.0123)
        //            self.wallNode?.position.z = currentZ! - 0.01
        //            self.frameNode?.position.z = currentZ! - 0.01
        //
        //            print("Moving wall forward to " + String(describing: currentZ! - 0.01))
        //
        //            break
        //        }
        //
        
        
        
    }
    
    
    
    
    // Allow the user to select a new photo from their gallery
    @IBAction func loadNewPhoto(_ sender: UIButton) {
        print("Load new photo button selected!")
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.popover
            //self.present(imagePicker, animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
    // Set the selected photo as the material for our frame model
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        coverMaterial.diffuse.contents = image
        dismiss(animated: true, completion: nil)
    }
    
    func setupLighting(){
        
        // Add spot light
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.spotInnerAngle = 45
        spotLight.spotOuterAngle = 45
        
        let spotlightNode = SCNNode()
        spotlightNode.light = spotLight
        spotlightNode.position = SCNVector3(x: 0.0, y: 0.0, z: -0.03)
        
        // By default the stop light points directly down the negative
        // z-axis, we want to shine it down so rotate 90deg around the
        // x-axis to point it down
        spotlightNode.eulerAngles = SCNVector3Make(Float(-Double.pi / 2), 0, 0)
        
        
        // Add ambient light
        let ambientLight = SCNLight()
        ambientLight.type = SCNLight.LightType.ambient
        ambientLight.spotInnerAngle = 45
        ambientLight.spotOuterAngle = 45
        
        let ambientlightNode = SCNNode()
        ambientlightNode.light = ambientLight
        ambientlightNode.position = SCNVector3(x: 0.0, y: 0.0, z: -0.03)
        
        
        sceneView.scene.rootNode.addChildNode(ambientlightNode)
        sceneView.scene.rootNode.addChildNode(spotlightNode)
        
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    /*
     Called when a SceneKit node's properties have been
     updated to match the current state of its corresponding anchor.
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            
            // Check if we've previously recognized this plane
            if anchors.contains(planeAnchor) {
                if node.childNodes.count > 0 {
                    let planeNode = node.childNodes.first!
                    planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
                    
                    // Update the plane's geometry to reflect the new data received from its anchor
                    if let plane = planeNode.geometry as? SCNBox {
                        plane.width = CGFloat(planeAnchor.extent.x)
                        plane.length = CGFloat(planeAnchor.extent.z)
                        plane.height = planeHeight
                        planeZPosition = planeAnchor.extent.z
                        
                        DispatchQueue.main.async {
                            self.planeLengthTextView.sizeToFit()
                            self.planeLengthTextView.text = "Plane Length: " + String(describing: plane.length)
                        }
                        
                    }
                }
            }
        }
    }
    
    // Called when enough feature points have been collected and a horizontal plane has been detected
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node:  SCNNode?
        if let planeAnchor = anchor as? ARPlaneAnchor {
            node = SCNNode()
            let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
            let gridMaterial  = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "trongrid")
            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.geometry?.materials = [gridMaterial]
            planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
            
            node?.addChildNode(planeNode)
            anchors.append(planeAnchor)
            
            
        } else {
            // haven't encountered this scenario yet
            print("not plane anchor \(anchor)")
        }
        return node
    }
    
    
    
    // Called when user taps anywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan()")
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        //
        //
        //        if touch.view != resetButton {
        //        selectExistinPlane(location: location)
        //        print("Screen was touched!, Not an AR Reset")
        //        //if(!isWallVisible!){
        //       let hitResults =  sceneView.hitTest(location, types: .featurePoint)
        //        print("Hit test results count -> " + String(describing: hitResults.count))
        //        if hitResults.count > 0 {
        //            print("Found hit test position!")
        //            let result: ARHitTestResult = hitResults.first!
        //
        //            for hit in hitResults{
        //                print("Hit result length -> " + String(describing: hit.distance))
        //            }
        //
        //            let wallMaterial = SCNMaterial()
        //            wallMaterial.diffuse.contents = UIColor.cyan
        //            wallMaterial.transparency = 0.5
        //            wallMaterial.isDoubleSided = true
        //
        //            let wallPlane = SCNBox(width: 1.8, height: CGFloat(wallHeight), length: 0.01, chamferRadius: 0)
        //            wallNode = SCNNode()
        //            wallNode?.geometry = wallPlane
        //            wallNode?.geometry?.firstMaterial = wallMaterial
        //            wallNode?.physicsBody = SCNPhysicsBody.static()
        //
        //            let planeAnchor = result.anchor as? ARPlaneAnchor
        //            print("Place wall at -> " + String(describing: planeAnchor?.extent.z))
        //            print("Plane Hit at -> " + String(describing: result.distance))
        //
        //            let wallPosition = SCNVector3(0, 0, Float(-result.distance))
        //            wallNode?.position = wallPosition
        //            wallZPosition = wallPosition.z
        //
        //            placePictureFrame(wallPosition)
        //            sceneView.scene.rootNode.addChildNode(wallNode!)
        //            isWallVisible = true
        
        //    }
        //        }
        //    }
    }
    
    func selectExistinPlane(location: CGPoint) {
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if hitResults.count > 0 {
            let result: ARHitTestResult = hitResults.first!
            if let planeAnchor = result.anchor as? ARPlaneAnchor {
                for var index in 0...anchors.count - 1 {
                    if anchors[index].identifier != planeAnchor.identifier {
                        sceneView.node(for: anchors[index])?.removeFromParentNode()
                        print("Plane anchor extent -> " + String(describing: planeAnchor.extent.z))
                    }
                    index += 1
                }
                anchors = [planeAnchor]
            }
        }
    }
    
    
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
