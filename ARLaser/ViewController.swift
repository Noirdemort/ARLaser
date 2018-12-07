//
//  ViewController.swift
//  ARLaser
//
//  Created by Noirdemort on 07/11/18.
//  Copyright © 2018 Noirdemort. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodeArray = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodeArray.count >= 2 {
            for dot in dotNodeArray {
                    dot.removeFromParentNode()
            }
            dotNodeArray = [SCNNode]()
        }
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        guard let hitResult = results.first else {return}
        addDot(at: hitResult)
    }
    
    func addDot(at location: ARHitTestResult){
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        let node = SCNNode()
        node.geometry = sphere
        let position = location.worldTransform
        node.position = SCNVector3(position.columns.3.x, position.columns.3.y, position.columns.3.z)
        sceneView.scene.rootNode.addChildNode(node)
        dotNodeArray.append(node)
        
        if dotNodeArray.count > 1 {
            calculate()
        }
    }
    
    func calculate(){
        let start = dotNodeArray[0]
        let end = dotNodeArray[1]
        let euclidDistance = powf(powf(start.position.x - end.position.x,2) + powf(start.position.y - end.position.y,2) + powf(start.position.z - end.position.z,2) , 0.5)
        updateText(text: "\(euclidDistance)", atPosition: end.position)
    }

    func updateText(text: String, atPosition: SCNVector3){
        self.textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text , extrusionDepth: 0.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        self.textNode = SCNNode(geometry: textGeometry)
        self.textNode.position = SCNVector3(atPosition.x, atPosition.y + 0.01, atPosition.z)
        self.textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(self.textNode)
    }
}
