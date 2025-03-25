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
    var defaultEmojis = "💩 ☀️ 🌤 🌈 🌧 🌩 ❤️ 💕 🎶 🥶 😂 😍 😊 😭 😳 😅"
    
    init() {
        makeImageList()
    }
    
    func currentImageData() -> ImageData? {
        if (imageList.count > selectedIndex) {
            return imageList[selectedIndex];
        }
        return nil;
    }
    
    func makeImageList() {
        imageList.removeAll()
        
        addUserEmojis()
        
        addDefaultEmojis()
    }
    
    func addUserEmojis() {
        guard let userEmojis = UserDefaults.standard.string(forKey: "userEmojis") else { return }
        let array = userEmojis.components(separatedBy: " ")
        array.forEach { str in
            let imageData = ImageData(withEmoji: str)
            if !str.isEmpty, !imageList.contains(imageData) {
                imageList.append(imageData)
            }
        }
    }
    
    func addDefaultEmojis() {
        let array = defaultEmojis.components(separatedBy: " ")
        array.forEach { str in
            let imageData = ImageData(withEmoji: str)
            if !imageList.contains(imageData) {
                imageList.append(imageData)
            }
        }
    }
}
