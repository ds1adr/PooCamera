//
//  FaceDetector.swift
//  PooCamera
//
//  Created by Won Tai Ki on 9/10/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit
import AVFoundation

class FaceDetector {
    
    static func detectFace(withImage image: UIImage) -> [CIFeature]? {
        var ciImage = image.ciImage
        if ciImage == nil {
            ciImage = CIImage(image: image)
        }
        if ciImage == nil {
            return nil
        }
        
        let option = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: option)
        
        //let opts = [CIDetectorImageOrientation : NSNumber(value: 7)]
        return detector?.features(in: ciImage!)
    }
    
}
