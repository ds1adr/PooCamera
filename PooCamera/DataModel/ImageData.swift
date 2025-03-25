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
class ImageData: Equatable {
    var emojiText : String!
    var image : UIImage!
    
    init(withEmoji emoji: String) {
        emojiText = emoji
        image = EmojiImage.textToImage(drawText: emojiText, withSize: CGSize(width: emoji.count > 1 ? 1000 : 500, height: 500))
    }
    
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        lhs.emojiText == rhs.emojiText
    }
}
