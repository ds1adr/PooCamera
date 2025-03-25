//
//  PictureViewController.swift
//  PooCamera
//
//  Created by Wontai Ki on 1/2/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    var originalImage : UIImage?
    var faces: [CIFeature]?
    var isFresh: Bool = false
    
    var retakeHandler: (() -> Void)?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let img = originalImage {
            self.imageView.image = img;
        }
        
        popupView.layer.cornerRadius = 8
        popupView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPopup()
    }
    
//    func makeShareImage() -> UIImage? {
//        guard let image = originalImage else {
//            return nil
//        }
//        let imageSize = image.size;
//        //        UIGraphicsBeginImageContext(imageSize!);
//        //
//        //        //var x : CGFloat!
//        //        if (deviceInput.device.position == .front) {
//        //            let flip = UIImage(cgImage: (capturedImage?.cgImage)!, scale: (capturedImage?.scale)!, orientation: .leftMirrored)
//        //            flip.draw(in: CGRect(x: 0, y: 0, width: (self.capturedImage?.size.width)!, height: (self.capturedImage?.size.height)!))
//        //            //x = (capturedImage?.size.width)! * ((previewView.frame.size.width - imageViewPoo.frame.origin.x - imageViewPoo.frame.size.width) / previewView.frame.size.width)
//        //        }
//        //        else {
//        //            self.capturedImage?.draw(in: CGRect(x: 0, y: 0, width: (self.capturedImage?.size.width)!, height: (self.capturedImage?.size.height)!))
//        //            //x = (capturedImage?.size.width)! * (imageViewPoo.frame.origin.x / previewView.frame.size.width)
//        //        }
//        //        let x = (capturedImage?.size.width)! * (imageViewPoo.frame.origin.x / previewView.frame.size.width)
//        //        let y = (capturedImage?.size.height)! * (imageViewPoo.frame.origin.y / previewView.frame.size.height)
//        //        let w = (capturedImage?.size.width)! * (imageViewPoo.frame.size.width / previewView.frame.size.width)
//        //        let h = (capturedImage?.size.height)! * (imageViewPoo.frame.size.height / previewView.frame.size.height)
//        //        if (!self.imageViewPoo.isHidden) {
//        //            self.pooImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
//        //        }
//        //
//        //        let image = UIGraphicsGetImageFromCurrentImageContext()
//        //
//        //        UIGraphicsEndImageContext();
//        //        return image;
//        return nil
//    }

    private func checkPopup() {
        if isFresh {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.popupView.isHidden = false
            }
        }
    }

    @IBAction func useAction() {
        guard let originalImage else { return }
        PhotoAlbumManager.manager.save(image: originalImage) {
            PhotoAlbumManager.manager.fetchAssets()
        }
        popupView.isHidden = true
    }
    
    @IBAction func retakeAction() {
        popupView.isHidden = true
        navigationController?.popViewController(animated: false)
//        dismiss(animated: true) { [weak self] in
        self.retakeHandler?()
//        }
    }
    
    @IBAction func shareAction() {
        guard let originalImage else { return }
        let imageToShare = [originalImage]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true)
    }
}
