//
//  UIView+Image.swift
//  InstaGRD
//
//  Created by José DEGUIGNE on 08/09/2021.
//

import UIKit

// This UIView extension will permit to convert our MainView to an image file
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
