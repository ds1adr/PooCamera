//
//  EmojiImage.swift
//  PooCamera
//
//  Created by KiWontai on 9/4/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit

class EmojiImage {

    class func textToImage(drawText text: String, withSize size: CGSize) -> UIImage {
        let textColor = UIColor.white
        let imgSize = size.width * 0.9
        let marginSize = size.width * 0.1
        let textFont = UIFont(name: "Helvetica Bold", size: imgSize)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let textFontAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: textColor,
            ]
        
        let rect = CGRect(origin: CGPoint(x: marginSize/2.0, y: marginSize/2.0), size: size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
