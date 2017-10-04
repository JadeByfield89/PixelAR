//
//  PictureFrame.swift
//  PixelAR
//
//  Created by Byfield, Jade on 9/23/17.
//  Copyright © 2017 Byfield, Jade. All rights reserved.
//

import UIKit
import ARKit

class PictureFrame: SCNNode {
    
    func loadModel(){
        guard let virtualObjectScene = SCNScene(named: "art.scnassets/high_poly_frame.dae") else{
            print("Could not load 3D asset!")
            return
        }
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes{
            wrapperNode.addChildNode(child)
        }
        
        
        
        self.addChildNode(wrapperNode)

}
    
}
