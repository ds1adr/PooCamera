//
//  ImageManager.swift
//  CelCam2
//
//  Created by KiWontai on 12/28/16.
//  Copyright © 2016 KiWontai. All rights reserved.
//

import Foundation

/**
 @class ImageManager
 */
class ImageManager {
    static let shared : ImageManager = ImageManager();
    
    var imageList : [ImageData] = [ImageData]();
    var selectedIndex : Int = 0;
    
    init() {
        imageList.append(ImageData(withEmoji: "💩"))
        imageList.append(ImageData(withEmoji: "☀️"))
        imageList.append(ImageData(withEmoji: "🌤"))
        imageList.append(ImageData(withEmoji: "🌈"))
        imageList.append(ImageData(withEmoji: "🌧"))
        imageList.append(ImageData(withEmoji: "🌩"))
        imageList.append(ImageData(withEmoji: "❤️"))
        imageList.append(ImageData(withEmoji: "💕"))
        imageList.append(ImageData(withEmoji: "🎶"))
        imageList.append(ImageData(withEmoji: "🥶"))
        imageList.append(ImageData(withEmoji: "😂"))
        imageList.append(ImageData(withEmoji: "😍"))
        imageList.append(ImageData(withEmoji: "😊"))
        imageList.append(ImageData(withEmoji: "😭"))
        imageList.append(ImageData(withEmoji: "😳"))
        imageList.append(ImageData(withEmoji: "😅"))
    }
    
    func currentImageData() -> ImageData? {
        if (imageList.count > selectedIndex) {
            return imageList[selectedIndex];
        }
        return nil;
    }
}
