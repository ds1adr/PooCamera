//
//  ImageData.swift
//  CelCam2
//
//  Created by KiWontai on 12/28/16.
//  Copyright © 2016 KiWontai. All rights reserved.
//

import UIKit

/**
 @class ImageData
 */
class ImageData {
    var emojiText : String!
    var image : UIImage!
    
    init(withEmoji emoji: String) {
        emojiText = emoji
        image = EmojiImage.textToImage(drawText: emojiText, withSize: CGSize(width: 500, height: 500))
    }
}
