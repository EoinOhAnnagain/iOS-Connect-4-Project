//
//  BezierPathView.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 07/04/2022.
//

import UIKit

class BezierPathView: UIView {
    
    // Array of paths
    private var bezierPaths = [String: UIBezierPath]()
    
    // Array of piece locations and player colours for use when used by historic tableview cells
    private var pieceLocations: [[Int]] = []
    private var firstColour = UIColor()
    private var secondColour = UIColor()

    // Function to layout the bezierpaths. Optional arguements are used bepending one what the paths are being drawn for
    func setPath(gameWidth: CGFloat, gameHeight: CGFloat, columnWidth: CGFloat, gameBoard: CGRect, pieceDiameter: CGFloat, addPiece: Bool = false, piecesToAdd: [[Int]] = [], letFirstColour: UIColor = .clear, letSecondColour: UIColor = .clear) {
        
        // let arguements are assigned to variables so they can be altered
        pieceLocations = piecesToAdd
        firstColour = letFirstColour
        secondColour = letSecondColour
        
        // Create path with linewidth
        let path = UIBezierPath()
        let lineWidth = 1

        // Draw spaces in the board for each of the locations (six rows, seven columns)
        for i in 1...6 {
            for j in 0...6 {
                
                // Draw circle based on passed parameters
                let circlePath = UIBezierPath(roundedRect: CGRect(x: 1.5+((columnWidth+1)*CGFloat(j)), y: gameBoard.maxY-pieceDiameter*CGFloat(i), width: pieceDiameter-1, height: pieceDiameter-1), cornerRadius: (pieceDiameter)/2)
                
                // Add circle to array with the name of its location and append it to the path
                bezierPaths["\(i)\(j+1)"] = circlePath
                path.append(circlePath)
            }
        }
        
        // Even odd rule is set to be used to fill the path
        path.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.opacity = 0
        
        // Set path to the gameboards size
        path.move(to: CGPoint(x: gameBoard.minX, y: gameBoard.minY))
        path.addLine(to: CGPoint(x: gameBoard.maxX, y: gameBoard.minY))
        path.addLine(to: CGPoint(x: gameBoard.maxX, y: gameBoard.maxY))
        path.addLine(to: CGPoint(x: gameBoard.minX, y: gameBoard.maxY))
        path.addLine(to: CGPoint(x: gameBoard.minX, y: gameBoard.minY))
        
        // Set linewidth and join style
        path.lineWidth = CGFloat(lineWidth)
        path.lineJoinStyle = .round
        
        // Close the path and add it to the bezier path array
        path.close()
        bezierPaths[K.BoardAndPieces.bezierBoard] = path
        
        // Set view to apply the path by invoking draw
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        // For each item in the bezierPath array set the fill to clear
        for (_, path) in bezierPaths {
            UIColor.clear.setFill()
            path.fill()
        }
        
        // Create bool to track which piece colour is being placed. Toggled after every piece
        var oddPiece = true
        
        // For each piece that was passed in
        for piece in pieceLocations {
            
            // Create location var
            var locations = String()
            
            // Check if the piece contains the 8 flag and set its colour to white and add to the location var
            if piece[0] == 8 {
                locations = "\(piece[1])\(piece[2])"
                UIColor.white.setFill()
                oddPiece.toggle()
                
            // If the flag is not present set to locations and apply the appropiate fill colour
            } else {
                locations = "\(piece[0])\(piece[1])"
                if oddPiece {
                    firstColour.setFill()
                } else {
                    secondColour.setFill()
                }
                oddPiece.toggle()
            }
            
            // Apply the fill to the piece from the bezierPaths array
            let usedPiece = bezierPaths[locations]
            usedPiece?.fill()
        }
        
        // Set the gameboard fill
        let gameBoard = bezierPaths[K.BoardAndPieces.bezierBoard]
        UIColor.black.setFill()
        gameBoard?.fill()
    }
}
