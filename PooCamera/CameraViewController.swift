//
//  ViewController.swift
//  PooCamera
//
//  Created by KiWontai on 1/2/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate : AnyObject {
    func take(withImage image: UIImage)
    func cancel()
}

class CameraViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate {
    
    enum Constants {
        static let maxImageFaceDetection = 10
    }

//    @IBOutlet weak var previewView : PreviewView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var previewImageView : UIImageView!
    @IBOutlet weak var buttonTake : UIButton!
    @IBOutlet weak var buttonChangeImage : UIButton!
    
    var imageViewEmotions : [UIImageView] = [UIImageView]()
    
    weak var delegate: CameraViewControllerDelegate?
    
    var camImage: UIImage?
    
    var videoOutput : AVCaptureVideoDataOutput = AVCaptureVideoDataOutput();
    
    var session : AVCaptureSession!
    var frontDevice : AVCaptureDevice?
    var backDevice : AVCaptureDevice?
    
    var deviceInput : AVCaptureDeviceInput!
    

    var pooImage : UIImage!
    
    var count : Int = 0;
    
    let lock = NSLock()
    
    //var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initAndMakeImageSet()
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted : Bool) in
            if (granted) {
                self.initCameraOverlay();
                DispatchQueue.global().async {
                    self.session.startRunning()
                }
            }
            else {
                let alert = UIAlertController(title: "Permission Error", message: "You should give me a permission for camera to use this app.", preferredStyle: .alert);
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil);
                alert.addAction(okAction);
                
                self.present(alert, animated: true, completion: nil);
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        //self.perform(#selector(captureImage), with: nil, afterDelay: 1.0);
        if (self.session != nil && !self.session.isRunning) {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.session.stopRunning();
        super.viewDidAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if (segue.identifier == "PictureModalSegue") {
            let vc = segue.destination as! PictureViewController;
            vc.isFresh = true
            //vc.shareImage = makeShareImage()
        }
    }
    
//    func makePooImage() -> UIImage? {
//        UIGraphicsBeginImageContext(CGSize(width: 600, height: 600));
//        
//        let pooString = "💩" as NSString;
//        pooString.draw(in: CGRect(x: 0, y:0, width: 600, height : 600), withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 560)])
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext();
//        return image;
//    }
    
    func initAndMakeImageSet() {
        guard let pooImage = ImageManager.shared.currentImageData()?.image else { return }
        self.pooImage = pooImage
        imageViewEmotions.forEach { imageView in
            imageView.removeFromSuperview()
        }
        self.imageViewEmotions.removeAll()
        
        
        for _ in 0 ..< Constants.maxImageFaceDetection {
            let iv = UIImageView(image: self.pooImage)
            self.containerView.addSubview(iv)
            iv.isHidden = true;
            self.imageViewEmotions.append(iv)
        }
    }

    func initCameraOverlay() {
        session = AVCaptureSession();
        
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720;
        //self.previewView.session = session;
        
        //previewView.layer.masksToBounds = true;
        //previewView.bringSubview(toFront: imageViewPoo);
        //imageViewPoo.translatesAutoresizingMaskIntoConstraints = false;
        
        // Add Camera Input
        let descoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInWideAngleCamera, .builtInDualCamera, .builtInTripleCamera], mediaType: AVMediaType.video, position: .unspecified);
        let devices = descoverySession.devices
        for device in devices {
            if (device.position == .back) {
                self.backDevice = device;
            }
            if (device.position == .front) {
                // Do something
                self.frontDevice = device
                do {
                    deviceInput = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(deviceInput) {
                        session.addInput(deviceInput)
                    }
                }
                catch {
                    
                }
            }
        }
        
        //previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

    }
    
    // MARK: AVCaptureVideoOutput
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let camCIImage : CIImage = cameraImage.oriented(forExifOrientation: 6);
        
        self.camImage = UIImage(ciImage: camCIImage)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.previewImageView.image = self.camImage;
        }
        
        self.detectFace()
    }
    
    func detectFace() {
        guard let image = self.camImage else {
            return
        }
            
        DispatchQueue.global().async {
            if self.lock.try() {
                
                let imageHeight = image.size.height;
                
                //let opts = [CIDetectorImageOrientation : NSNumber(value: 7)]
                if let faces = FaceDetector.detectFace(withImage: image) {
                    DispatchQueue.main.async { [unowned self] in
                        var currentImageIndex = 0
                        
                        for feature in faces {
                            if let face = feature as? CIFaceFeature,
                             (face.hasLeftEyePosition  && face.hasRightEyePosition) {
                                
                                let mag = self.previewImageView.frame.size.width / image.size.width;

                                let lp = imageHeight - face.leftEyePosition.y;
                                let rp = imageHeight - face.rightEyePosition.y;
                                let distance = 2*abs(face.rightEyePosition.x - face.leftEyePosition.x)*mag
                                let center = CGPoint(x: (face.leftEyePosition.x + face.rightEyePosition.x)*mag/2.0, y: (lp + rp)*mag/2.0 )
                                
                                let iv = self.imageViewEmotions[currentImageIndex]
                                
                                iv.frame = CGRect(x: center.x - distance/2.0, y: center.y - distance*1.2 , width: distance, height: distance);
                                iv.isHidden = false;
                                
                            }
                            
                            currentImageIndex += 1
                            if currentImageIndex >= Constants.maxImageFaceDetection {
                                break
                            }
                        }
                        if currentImageIndex < Constants.maxImageFaceDetection {
                            for i in currentImageIndex ..< Constants.maxImageFaceDetection {
                                imageViewEmotions[i].isHidden = true
                            }
                        }
                    }
                    
                }
                self.lock.unlock()
            }
        }

    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
//        if let metadataObject = metadataObjects.first {
//            guard let faceObject = metadataObject as? AVMetadataFaceObject else {
//                print("no");
//                return;
//            }
//
//            //print("faceObject : \(faceObject.bounds)")
//
//            if let transformedObject = previewView.videoPreviewLayer.transformedMetadataObject(for: faceObject) {
//                let rect = transformedObject.bounds;
//
//                DispatchQueue.main.async { [unowned self] in
//                    self.imageViewPoo.frame = CGRect(x: rect.origin.x, y: rect.origin.y - rect.size.width, width: rect.size.width, height: rect.size.width);
//                    self.imageViewPoo.isHidden = false;
//                }
//            }
//        }
//        else {
//            self.imageViewPoo.isHidden = true;
//        }
//    }
    
    @IBAction func changeCameraButtonClicked(button : UIButton) {
        button.isEnabled = false;
        let currentPosition = deviceInput.device.position;
        
        switch currentPosition {
        case .front:
            guard let backDevice else { return }
            do {
                session.removeInput(deviceInput);
                deviceInput = try AVCaptureDeviceInput(device: (backDevice))
                
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                }
            }
            catch {
                
            }
        case .back:
            guard let frontDevice else { return }
            do {
                session.removeInput(deviceInput);
                deviceInput = try AVCaptureDeviceInput(device: frontDevice)
                
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                }
            }
            catch {
                
            }
        default:
            break;
        }
        button.isEnabled = true;
    }
    
    @IBAction func closeButtonClicked(button: UIButton) {
        if let d = self.delegate {
            d.cancel()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takeButtonClicked(button : UIButton) {
        let image = containerView.asImage()
        
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.take(withImage: image)
        }
    }
    
    func updateIcon() {
        initAndMakeImageSet()
    }
    
    @IBAction func imageSelectButtonClicked(_ button : UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil);
        let collectionViewController = sb.instantiateViewController(withIdentifier: "ImageSelectCollectionViewController") as! ImageSelectCollectionViewController;
        collectionViewController.cameraViewController = self;
        collectionViewController.modalPresentationStyle = .popover;
        collectionViewController.preferredContentSize = CGSize(width: 240, height: 400)
        
        let popOverController = collectionViewController.popoverPresentationController;
        popOverController?.delegate = self;
        popOverController?.sourceView = self.view;
        popOverController?.sourceRect = button.frame;
        
        self.present(collectionViewController, animated: true, completion: nil);
    }
    
}

extension CameraViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none;
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true;
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("t");
    }
}

