//
//  ViewController.swift
//  KirakiraSample
//
//  Created by Gaurav Jindal on 11/16/17.
//  Copyright © 2017 Gaurav Jindal. All rights reserved.
//

import UIKit
import Twinkle
import MobileCoreServices
import ARKit
import SceneKit
import Photos

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{//},ARSCNViewDelegate {
    let cameraController:UIImagePickerController = UIImagePickerController()
    var isFirstTime:Bool = true
    var nodes: [SphereNode] = []
    var overlayView:UIView = UIView()
    var twinkleView: UIView = UIView()
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        return view
    }()
    
    //2
    lazy var infoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sceneView.delegate = self
        self.view.backgroundColor = UIColor.black
//         self.view.addSubview(sceneView)
//        self.view.addSubview(infoLabel)
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        tapRecognizer.numberOfTapsRequired = 1
//        sceneView.addGestureRecognizer(tapRecognizer)
        
        // using the UIView extension
//        self.twinkleView = UIView(frame: CGRect(x: 0, y: 100, width: 150, height: 50))
//        self.twinkleView.backgroundColor = UIColor.red
//        self.view.addSubview(self.twinkleView)
//        self.view.twinkle()
//
//        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(twinkleViewWithAnimation), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //4
//        sceneView.frame = view.bounds
//         infoLabel.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //5
//        let configuration = ARWorldTrackingConfiguration()
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTime == true {
            isFirstTime = false
            _ = startCameraFromViewController(viewController: self, withDelegate: self )
        }

    }
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = true
        cameraController.delegate = delegate
        
        overlayView.removeFromSuperview()
        
        
        overlayView = UIView(frame: CGRect(x: 0, y: cameraController.view.frame.origin.y+50, width: cameraController.view.frame.size.width, height: cameraController.view.frame.size.height-110))
        overlayView.backgroundColor = UIColor.clear.withAlphaComponent(0.3)
        overlayView.backgroundColor = UIColor.clear
        overlayView.layer.isOpaque = false
        overlayView.isOpaque = false
        
        Twinkle.twinkle(overlayView)
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(twinkleViewWithAnimation), userInfo: nil, repeats: true)

//        UIView* overlayView = [[UIView alloc] initWithFrame:picker.view.frame];
//        // letting png transparency be
//        overlayView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yourimagename.png"]];
//        [overlayView.layer setOpaque:NO];
//        overlayView.opaque = NO;
        cameraController.isEditing = false
        cameraController.showsCameraControls = true;
        cameraController.cameraOverlayView = overlayView;
        
        self.present(cameraController, animated: true, completion: nil)
        return true
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Gesture handlers
    @objc func handleTap(sender: UITapGestureRecognizer) {
        return;
        //2
        let tapLocation = sender.location(in: sceneView)
        //3
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            //4
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            //5
            let sphere = SphereNode(position: position)
            //6
            sceneView.scene.rootNode.addChildNode(sphere)
            let lastNode = nodes.last
            nodes.append(sphere)
            if lastNode != nil {
                //7
                let distance = lastNode!.position.distance(to: sphere.position)
                infoLabel.text = String(format: "Distance: %.2f meters", distance)
            }
        }
 
    }
        
    func twinkleViewWithAnimation()  {
//        Twinkle.twinkle(self.view)
        Twinkle.twinkle(overlayView)

    }
    
    //wait
    // MARK: ARSCNViewDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        //5
        var status = "Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            status = "Not available"
        case ARCamera.TrackingState.limited(_):
            status = "Analyzing..."
        case ARCamera.TrackingState.normal:
            status = "Ready"
        }
        infoLabel.text = status
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        // Handle a movie capture
        if mediaType == kUTTypeMovie {
            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
                picker.dismiss(animated: true) {
                    _ = self.startCameraFromViewController(viewController: self, withDelegate: self )
                }
                //                        dismiss(animated: true, completion: nil)
                
                return;
                PHPhotoLibrary.requestAuthorization({ (authStatus:PHAuthorizationStatus) in
                     // User has not yet made a choice with regards to this application
                   
                    if authStatus == PHAuthorizationStatus.authorized{
                                                
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: info[UIImagePickerControllerMediaURL] as! URL)
                        }) { saved, error in
                            if saved {
                                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            else{
                                let alertController = UIAlertController(title: "There was an error saving this video", message: nil, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    else if authStatus == PHAuthorizationStatus.notDetermined{
                        let alertController = UIAlertController(title: "Please check your device settings", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if authStatus == PHAuthorizationStatus.restricted{
                        let alertController = UIAlertController(title: "Please check your device settings", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
                
                
                //                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(RecordVideoViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
//        picker.dismiss(animated: true) {
//            _ = self.startCameraFromViewController(viewController: self, withDelegate: self )
//        }
//        dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            _ = self.startCameraFromViewController(viewController: self, withDelegate: self )
        }
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        print("updateAtTime")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("updateAtTime")

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        print("didRenderScene scene: SCNScene, atTime")
        print(scene.lightingEnvironment)
//        print(scene.reflec)

    }
}



extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}

