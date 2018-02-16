import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    var source: SCNAudioSource? = nil
    
    @IBOutlet private weak var arView: ARSCNView! {
        didSet {
            let rec = UITapGestureRecognizer(target: self, action: #selector(didTap))
            arView.addGestureRecognizer(rec)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let conf = ARWorldTrackingConfiguration()
        conf.planeDetection = [.horizontal/*, .vertical*/] // iOS 11.3
        
        arView.session.run(conf, options: [])

        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        arView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    @objc func didTap(_ rec: UITapGestureRecognizer) {
        let pt = rec.location(in: arView)
        let res = arView.hitTest(pt, options: [.boundingBoxOnly: true]).flatMap { $0.node }
        for node in res {
            node.removeFromParentNode()
        }
        if !res.isEmpty, let src = source {
            arView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: src))
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let scene = SCNScene(named: "art.scnassets/pacman.scn")
        
        for daeNode in (scene?.rootNode.childNodes)! {
            let copiedNode = SCNNode(geometry: daeNode.geometry)
            
            copiedNode.position = SCNVector3(
                planeAnchor.center.x/* + copiedNode.position.x*/,
                planeAnchor.center.y/* + copiedNode.position.y*/ + 1.0,
                planeAnchor.center.z/* + copiedNode.position.z*/)
            copiedNode.scale = SCNVector3(0.2, 0.2, 0.2)
            
            node.addChildNode(copiedNode)
            //arView.scene.rootNode.addChildNode(daeNode)
        }
        
        print(planeAnchor.center)

//        let sphere = SCNSphere(radius: 0.05)
//        let sphereNode = SCNNode(geometry: sphere)
//        let sphereNode2 = SCNNode(geometry: sphere)
//        sphereNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
//        sphereNode2.position = SCNVector3((planeAnchor.center.x + 0.1), planeAnchor.center.y, planeAnchor.center.z)
//        node.addChildNode(sphereNode)
//        node.addChildNode(sphereNode2)
    }
}

