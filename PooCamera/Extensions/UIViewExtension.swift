//
//  UIViewExtension.swift
//  PooCamera
//
//  Created by Wontai Ki on 3/22/25.
//  Copyright © 2025 KiWontai. All rights reserved.
//

import UIKit

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
