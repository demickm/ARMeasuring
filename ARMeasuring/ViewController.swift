//
//  ViewController.swift
//  ARMeasuring
//
//  Created by Demick McMullin on 12/4/17.
//  Copyright © 2017 Demick McMullin. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    // Outlets
    
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    // Variables and Constants
    
    let configuration = ARWorldTrackingConfiguration()
    var startingPosition: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Basic Setup
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        
        // Tap Gesture Setup
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView,
              let currentFrame = sceneView.session.currentFrame else {return}
        if startingPosition != nil {
            startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.simdTransform = modifiedMatrix
        sceneView.scene.rootNode.addChildNode(sphere)
        startingPosition = sphere
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = self.startingPosition,
              let pointOfView = self.sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        let distanceTraveled = self.distance(x: xDistance, y: yDistance, z: zDistance)
        DispatchQueue.main.async {
            self.xLabel.text = "X: " + String(format: "%.2f", xDistance) + "m"
            self.yLabel.text = "Y: " + String(format: "%.2f", yDistance) + "m"
            self.zLabel.text = "Z: " + String(format: "%.2f", zDistance) + "m"
            self.distanceLabel.text = "Distance: " + String(format: "%.2f", distanceTraveled) + "m"
        }
    }
    
    func distance(x: Float, y: Float, z: Float) -> Float {
        
        return (sqrtf(x*x + y*y + z*z))
    }

}

