//
//  BackgroundView.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 07/04/2022.
//

// Code addapted from https://stackoverflow.com/questions/31853859/radial-gradient-background-in-swift


import UIKit

class BackgroundView: UIView {

    // Create a lazy variable for the backgrounds gradient
    private lazy var gradientLayer: CAGradientLayer = {
        
        // Create gradient layer
        let gradient = CAGradientLayer()
        
        // Set gradient's settings
        gradient.type = .radial
        gradient.colors = [UIColor.purple.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        // Add gradient as sublayer
        layer.addSublayer(gradient)
        
        // Return the gradient
        return gradient
        
    }()
    
    // Set the gradient to the bounds of the frame
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
