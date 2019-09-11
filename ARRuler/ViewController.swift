//
//  ViewController.swift
//  ARRuler
//
//  Created by Giulio Gola on 17/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // ADD debug options - shows dots as searching for planes
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Tells the delegate that there were touches on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If we already have two nodes (points), remove all and start from scratch
        if dotNodes.count == 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            textNode.removeFromParentNode()
            // Re-initialize array
            dotNodes = [SCNNode]()
        }
        // Check if touch was by mistake or not and extract touch location on screen (2D)
        if let touchLocation = touches.first?.location(in: sceneView) {
            // 2D -> 3D types: .featurePoint = looking for a point on a surface detected by ARKit, but not part of any planes.
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            // Take first result of hitTest and ddd a dot to the touchLocation 3D hitResult
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    // Add dot (3D sphere)
    func addDot(at hitResult: ARHitTestResult) {
        // Initialize a dot as a sphere
        let dotGeometry = SCNSphere(radius: 0.005)
        // Attach a material (i.e. color)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        // Create a node (AR object) and add geometry to the node
        let dotNode = SCNNode(geometry: dotGeometry)
        // Add position to the node coming from hitResult matrix
        dotNode.position = SCNVector3(
            CGFloat(hitResult.worldTransform.columns.3.x),
            CGFloat(hitResult.worldTransform.columns.3.y),
            CGFloat(hitResult.worldTransform.columns.3.z))
        // Add node to scene
        sceneView.scene.rootNode.addChildNode(dotNode)
        // Append to array
        dotNodes.append(dotNode)
        // Check if there are 2 dotNodes in the array
        if dotNodes.count == 2 {
            // Calculate distance
            calculate()
        }
    }

    // Calculate distance
    func calculate() {
        // Get start position = first node
        let start = dotNodes[0]
        // Get end position = second node
        let end = dotNodes[1]
        // Get distance
        let distance = sqrt(
            pow(Double(start.position.x - end.position.x), 2) +
            pow(Double(start.position.y - end.position.y), 2) +
            pow(Double(start.position.z - end.position.z), 2))
        // Print text on screen at the position of the second node
        updateText(text: "\(distance)", at: end.position)
    }
    
    // Update text
    func updateText(text: String, at position: SCNVector3) {
        // Create a text geometry (extrusionDepth = depth of the text - set by trial and error)
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        // If you only have one material attached to the geometry use .firstMaterial
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        // Create text node (AR object)
        textNode = SCNNode(geometry: textGeometry)
        // Give position (could use directly "position", but need to give little offset to .y so we separate the components)
        textNode.position = SCNVector3(position.x, position.y + 0.03, position.z)
        // Scale to 1% of its size
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        // Add text node into our scene
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
