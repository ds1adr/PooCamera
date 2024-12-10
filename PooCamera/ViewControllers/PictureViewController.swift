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
    
    @IBOutlet weak var imageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let img = originalImage {
            self.imageView.image = img;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeShareImage() -> UIImage? {
        guard let image = originalImage else {
            return nil
        }
        let imageSize = image.size;
        //        UIGraphicsBeginImageContext(imageSize!);
        //
        //        //var x : CGFloat!
        //        if (deviceInput.device.position == .front) {
        //            let flip = UIImage(cgImage: (capturedImage?.cgImage)!, scale: (capturedImage?.scale)!, orientation: .leftMirrored)
        //            flip.draw(in: CGRect(x: 0, y: 0, width: (self.capturedImage?.size.width)!, height: (self.capturedImage?.size.height)!))
        //            //x = (capturedImage?.size.width)! * ((previewView.frame.size.width - imageViewPoo.frame.origin.x - imageViewPoo.frame.size.width) / previewView.frame.size.width)
        //        }
        //        else {
        //            self.capturedImage?.draw(in: CGRect(x: 0, y: 0, width: (self.capturedImage?.size.width)!, height: (self.capturedImage?.size.height)!))
        //            //x = (capturedImage?.size.width)! * (imageViewPoo.frame.origin.x / previewView.frame.size.width)
        //        }
        //        let x = (capturedImage?.size.width)! * (imageViewPoo.frame.origin.x / previewView.frame.size.width)
        //        let y = (capturedImage?.size.height)! * (imageViewPoo.frame.origin.y / previewView.frame.size.height)
        //        let w = (capturedImage?.size.width)! * (imageViewPoo.frame.size.width / previewView.frame.size.width)
        //        let h = (capturedImage?.size.height)! * (imageViewPoo.frame.size.height / previewView.frame.size.height)
        //        if (!self.imageViewPoo.isHidden) {
        //            self.pooImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
        //        }
        //
        //        let image = UIGraphicsGetImageFromCurrentImageContext()
        //
        //        UIGraphicsEndImageContext();
        //        return image;
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
