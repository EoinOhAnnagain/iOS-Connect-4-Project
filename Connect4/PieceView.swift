//
//  DiscView.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 08/04/2022.
//

import UIKit

class PieceView: UIView {
    
    // Location variable with default value to be overridden
    var location: (row: Int, column: Int) = (8,8)
    
    // Create the view
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width / 2
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
    }
    
    // Error
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Collision
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
