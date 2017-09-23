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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var scene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.session.configuration?.isLightEstimationEnabled = true
        
        let photoNode = SCNNode()
        photoNode.position = SCNVector3(x: 0.0, y: 0.0, z: -0.03)
        photoNode.geometry = SCNBox(width: 0.005, height: 0.006, length: 0.001, chamferRadius: 0.0)
        photoNode.castsShadow = true
        
        let coverMaterial = SCNMaterial()
        coverMaterial.diffuse.contents = UIImage(named: "skyline")
        
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.white
        
        let materials = [coverMaterial, sideMaterial, sideMaterial, sideMaterial, sideMaterial, sideMaterial]
        photoNode.geometry?.materials = materials
        photoNode.physicsBody = SCNPhysicsBody.static()
        
        
        setupCamera()
        setupLighting()
        
        scene = sceneView.scene
        
      
        scene.rootNode.addChildNode(photoNode)
        
        
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
        
        let scene = sceneView.scene
        scene.rootNode.addChildNode(ambientlightNode)
        scene.rootNode.addChildNode(spotlightNode)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    /*func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        return node
    }*/
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        print("renderer()")
        
        let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate!
        print("Light estimate -> " + lightEstimate.debugDescription)
        
        if(lightEstimate == nil){
            return
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
