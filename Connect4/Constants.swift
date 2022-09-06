//
//  Constants.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 03/04/2022.
//

import Foundation
import UIKit
import CoreData


// Structure containing commonly used methods and variables
struct K {
    
    
    // MARK: - Segues
    
    // Variables related to segues and reusable tableview cells
    struct SeguesAndCells {
        static let toSecondary = "sw"
        static let playOptionCell = "cell"
        static let historicCell = "historyCell"
    }
    
    
    // MARK: - Board and Pieces
    
    // Variables and Methods related to the board and its pieces
    struct BoardAndPieces {
        
        // Array of the pieces colours
        static let pieceColours: [UIColor] = [.systemRed, .systemYellow, .systemBlue, .systemGreen, .systemPurple, .systemOrange]
        
        // Array of the emojis used for the demo mode
        static let demoEmojis = ["😎", "😊", "😟", "🗿", "💕", "😁", "🎶", "😀", "😇", "🤪", "🥸", "🥳", "😵‍💫", "🤠", "🤢", "🤮", "🥴"]
        
        // Function used to calculate the variables for the game board, pieces, etc.
        static func calculateBoardVariables(_ gameArea: CGRect) -> (gameHeight: CGFloat, gameWidth: CGFloat, columnWidth: CGFloat, pieceDiameter: CGFloat, dropVarience: CGFloat, dropYLocation: CGFloat, barrierColumnPoints: [CGFloat], xLocations: [CGFloat], yLocations: [CGFloat]) {
            
            // Calculate variables
            let gameHeight = gameArea.height
            let gameWidth = gameArea.width
            let columnWidth = (gameWidth/7)-1
            let pieceDiameter = columnWidth-1
            let dropVarience = (pieceDiameter/4)-1
            let dropYLocation = -gameArea.minY
            
            // Create variable arrays and set first item
            var barrierColumnPoints = [gameArea.minX]
            var xLocations: [CGFloat] = [1]
            var yLocations: [CGFloat] = [gameArea.height]
            
            // Calcualte remaining variables for the variable arrays
            for i in 1...7 {
                barrierColumnPoints.append(barrierColumnPoints[i-1]+columnWidth+1)
                xLocations.append(xLocations[i-1]+columnWidth+1)
                yLocations.append(yLocations[i-1]-pieceDiameter)
            }
            
            // As yLocations contians too many variables remove the superfluous entries
            yLocations.removeFirst()
            yLocations = yLocations.dropLast()
            
            // Return calcualted variables
            return (gameHeight: gameHeight, gameWidth: gameWidth, columnWidth: columnWidth, pieceDiameter: pieceDiameter, dropVarience: dropVarience, dropYLocation: dropYLocation, barrierColumnPoints: barrierColumnPoints, xLocations: xLocations, yLocations: yLocations)
            
        }
        
        static let bezierBoard = "gameBoard"
        
    }
    
    
    // MARK: - Data Persistence
    
    // Variables and Methods related to the data persistence
    struct Data {
        
        // Context veraible
        static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // User defaults variable
        static let defaults = UserDefaults.standard
        
        // Keys for User Defaults
        static let dataString = "dataString"
        static let musicString = "musicString"
        
        // Method to decode the save string and return both players colours, the array of piece positions, and a bool indicating who when first
        static func decodeSave(_ letDataString: String) -> (Bool, UIColor, UIColor, [[Int]]) {
            
            // Check that the passed array does not contain too little information and return default information
            if letDataString.count < 3 {
                return (true, .red, .yellow, [])
            }
            
            // Create a var version of the passed let information
            var dataString = letDataString
            
            // Create and populate bool variable, bassed on first character in the dataString.
            var botIsFirst = Bool()
            if dataString.removeFirst().wholeNumberValue! == 1 {
                botIsFirst = true
            } else {
                botIsFirst = false
            }
            
            // Create let variables for user and bot colours based on 2nd and 3rd elements of the string
            let playerColour: UIColor = BoardAndPieces.pieceColours[dataString.removeFirst().wholeNumberValue!]
            let botColour: UIColor = BoardAndPieces.pieceColours[dataString.removeFirst().wholeNumberValue!]
            
            // Create varaible for decoding the remaing items in the string
            var positions = [[Int]]()
            var current = [Int]()
            
            // Loop while the dataString still contains elements
            while dataString.count > 0 {
                
                // Empty current.
                current = []
                
                // Check for the 8 flag and enter it into the current array if found
                if dataString.first == "8" {
                    current.append(dataString.removeFirst().wholeNumberValue!)
                }
                
                // Add next two items to the current array, removing them from the dataString in the process
                for _ in 0...1 {
                    current.append(dataString.removeFirst().wholeNumberValue!)
                }
                
                // Append current to the final array
                positions.append(current)
            }
            
            // Return variables
            return (botIsFirst, playerColour, botColour, positions)
        }
        
    }
}
