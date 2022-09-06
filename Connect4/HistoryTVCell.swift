//
//  HistoryTVCell.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 11/04/2022.
//

import UIKit

class HistoryTVCell: UITableViewCell {

    // Outlets for the reusable cell
    @IBOutlet weak var gameBoard: BezierPathView!
    @IBOutlet weak var firstPlayerLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    
    // Variables used to pass information into the cell
    var piecesArray = [[Int]]()
    var saveString = String()
    var firstColour = UIColor()
    var secondColour = UIColor()
    
    // Redraw if being reused
    override func prepareForReuse() {
        setNeedsDisplay()
    }
    
    // Override the draw function
    // Board variables generated here as frame size not set preceeding this point, eg. during awakeFromNib
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Create variable holding all the board variables such as height, width, etc.
        let boardVariables = K.BoardAndPieces.calculateBoardVariables(gameBoard.frame)
        
        // Use variable to draw the game board and pieces from historic games
        gameBoard.setPath(gameWidth: boardVariables.gameWidth, gameHeight: boardVariables.gameHeight, columnWidth: boardVariables.columnWidth, gameBoard: gameBoard.bounds, pieceDiameter: boardVariables.pieceDiameter, addPiece: true, piecesToAdd: piecesArray, letFirstColour: firstColour, letSecondColour: secondColour)
    
    }
}
