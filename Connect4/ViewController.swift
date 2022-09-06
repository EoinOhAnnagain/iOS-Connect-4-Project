//
//  ViewController.swift
//  Connect4
//
//  Created by COMP47390 on 20/01/2022.
//  Copyright © 2020 COMP47390. All rights reserved.
//

import UIKit
import Alpha0Connect4
import CoreLocation


class ViewController: UIViewController {
    
    
    // MARK: - Outlets
    
    // Tap and swipe outlets
    @IBOutlet var tapGameArea: UITapGestureRecognizer!
    @IBOutlet var tapFlashArea: UITapGestureRecognizer!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet var otherSwipteGesture: UISwipeGestureRecognizer!
    
    // New game button and label outlets
    @IBOutlet var colourButtons: [UIButton]!
    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet var positionButtons: [UIButton]!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    // History button outlet
    @IBOutlet weak var repeatButton: UIButton!
    
    // View Outlets
    @IBOutlet weak var gameAreaView: UIView!
    @IBOutlet weak var boardView: BezierPathView!
    
    
    // MARK: - Game Variables
    
    // Variables for setting up and managing the game board and pieces. These can be depreciated in favour of boardVariables.<name> used in calculateGameVariables() but would require a large refactor and testing as they are used in a lot of places. Removing them causes a crash that needs to be looked into
    var gameHeight = CGFloat()
    var gameWidth = CGFloat()
    var columnWidth = CGFloat()
    var pieceDiameter = CGFloat()
    var dropVarience = CGFloat()
    var dropYLocation = CGFloat()
    var xLocations = [CGFloat]()
    var yLocations = [CGFloat]()
    var barrierColumnPoints = [CGFloat]()
    
    // Array of game pieces
    var pieces = [PieceView]()
    
    // User and bot variables
    var userColour: UIColor = .red
    var botColour: UIColor = .yellow
    var playersTurn: Bool = true
    
    // Animation behaviour variables
    private var gravity = UIGravityBehavior()
    private var collider = UICollisionBehavior()
    private var animator: UIDynamicAnimator?
    
    // Bool used to track if a move is the first in a game for the music player
    var isFirstMove = true
    
    // Var to label pieces with their position number
    var pieceNumber = 1
    
    // Game mode bools
    var demoMode = true
    var newGame = false
    var currentGame = false
    var historicGame = false
    var dontAnimate = false
    
    
    // MARK: - Data Tracking Variables
    
    // Data persistence strings
    var dataString = String()
    var musicString = String()
    var botIsFirstString = String()
    var playerColourString = String()
    var botColourString = String()
    
    // String of moved for use in historicMode
    var historicGameString = String()
    
    // Array of the moves made in a game
    var movesArray = [(row: Int, column: Int)]()
    
    // Variables used for core data
    var botWon = Bool()
    var userWon = Bool()
    var firstColour = Int16()
    var secondColour = Int16()
    var lastUsedColour = UIColor()
    
    
    // MARK: - Misc Variables
    
    // Variable for input passed from master VC and actions to take when set
    var passedInput = String() {
        didSet {
            if passedInput == "New Game" {
                demoMode = false
                newGame = true
                currentGame = false
                historicGame = false
                dataString = ""
                musicString = ""
            } else if passedInput == "Current Game" {
                demoMode = false
                newGame = false
                currentGame = true
                historicGame = false
                dataString = K.Data.defaults.object(forKey: K.Data.dataString) as! String
            } else {
                demoMode = false
                newGame = false
                currentGame = false
                historicGame = true
                historicGameString = "\(passedInput)"
            }
        }
    }
    
    // Timer variable
    var timer = Timer()
    
    // Variables used by Alpha0C4. These are set to the same value for each game to reduce potential issues as other variables are used eg. Alpha0C4 can only manage two colours, not six.
    private var botColor: GameSession.DiscColor = .yellow
    private var isBotFirst: Bool = false
    
    // Game session variable
    private var gameSession = GameSession()

    
    // MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides and disable variable items as none of them will be used in all modes. They will be reinabled depending on the mode in use.
        
        // Hide repeat button
        repeatButton.alpha = 0
        
        // Round colour buttons and hide all buttons
        roundColourButtons()
        hideAllButtonsAndLabels()
        
        // Disable taps and swipes
        tapGameArea.isEnabled = false
        tapFlashArea.isEnabled = false
        swipeGesture.isEnabled = false
        otherSwipteGesture.isEnabled = false
        
        // Set up the animator behaviours
        animator = UIDynamicAnimator(referenceView: view)
        animator?.addBehavior(gravity)
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Now that the game board has its final size calulate the variables for the game.
        setGameArea()

        // Actions to take depending on the game mode
        if newGame {
            // Clear saved dataString to clear any current games and show the first set of buttons
            K.Data.defaults.set("", forKey: K.Data.dataString)
            showPositionButtons()
        } else if demoMode {
            // Call function to initiate demo mode
            demoModeActive()
        } else if historicGame {
            // Call function to display a previous game
            historicModeActive()
        } else if currentGame {
            // Call function to resume a game
            currentModeActive()
        }
    }
    
    
    // MARK: - Game Mode Managers
    
    // Method to initiate demo mode
    private func demoModeActive() {
        
        // Remove all colision behaviour so pieces just fall
        animator?.removeBehavior(collider)
        
        // Create variable to track number of pieces dropped
        var i = 0
        
        // Start timer. Interval is random each time the app is launched
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(.random(in: 0.01...1)), repeats: true, block: { [self] _ in
            
            // Create a piece and drop it at a random X position in a range based on the boards width
            self.createPiece(xPosition: CGFloat.random(in: 0-(pieceDiameter/2)...(gameWidth)-(pieceDiameter/2)), colour: K.BoardAndPieces.pieceColours[Int.random(in: 0...5)])
            
            // Once 100 pieces have been dropped remove the oldest with each run of the timer
            if i == 1000 {
                pieces.removeFirst().removeFromSuperview()
            } else {
                i += 1
            }
        })
    }
    
    // Method to initiate a current game
    private func currentModeActive() {
        
        // Deactivate animations while placing previous peices
        dontAnimate = true
        // Set to false for the music player
        isFirstMove = false
        
        // Play the resuming audio
        Music.playMusic("Current")
        
        // Set the saved music string to msuciString variable
        musicString = K.Data.defaults.object(forKey: K.Data.musicString)! as! String
        
        // Decode the dataString from the previous game
        let decodedData = K.Data.decodeSave(dataString)
        
        // Isolate the first three characters and use them to set variables for saving in the future
        var dataPrefix = dataString.prefix(3)
        botIsFirstString = "\(dataPrefix.removeFirst())"
        playerColourString = "\(dataPrefix.removeFirst())"
        botColourString = "\(dataPrefix)"
        
        // Set the user and bot colour from the decoded data
        userColour = decodedData.1
        botColour = decodedData.2
        
        // Set variables based on decoded data
        if decodedData.0 {
            playersTurn = false
            isBotFirst = true
        } else {
            playersTurn = true
            isBotFirst = false
        }
        
        // If the bot was first set variables for core data to use later appropiatly
        if isBotFirst {
            firstColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: botColour)!)
            secondColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: userColour)!)
        } else {
            firstColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: userColour)!)
            secondColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: botColour)!)
        }
        
        // Create initialMoves array and populate it and the movesArray appropiatly
        var initialMoves: [(row: Int, column: Int)] = []
        for previousMove in decodedData.3 {
            initialMoves.append((row: previousMove[0], column: previousMove[1]))
            movesArray.append((row: previousMove[0], column: previousMove[1]))
        }
        
        // Check that there are moves to use as a crash can occure if an empty string gets through
        if !(decodedData.3.isEmpty) {
            // For each item in the decoded data's saved moves place a piece in its location using %2 and isBotFirst to determine the colour to use
            for i in 0..<decodedData.3.count {
                if i%2 == 0 {
                    if self.isBotFirst {
                        self.createPiece(xPosition: self.xLocations[decodedData.3[i][1]-1],
                                         colour: self.botColour,
                                         location: (row: decodedData.3[i][0], column: decodedData.3[i][1]),
                                         yPosition: yLocations[decodedData.3[i][0]-1])
                    } else {
                    self.createPiece(xPosition: self.xLocations[decodedData.3[i][1]-1],
                                     colour: self.userColour,
                                     location: (row: decodedData.3[i][0], column: decodedData.3[i][1]),
                                     yPosition: yLocations[decodedData.3[i][0]-1])
                    }
                } else {
                    if self.isBotFirst {
                        self.createPiece(xPosition: self.xLocations[decodedData.3[i][1]-1],
                                         colour: self.userColour,
                                         location: (row: decodedData.3[i][0], column: decodedData.3[i][1]),
                                         yPosition: yLocations[decodedData.3[i][0]-1])
                    } else {
                        self.createPiece(xPosition: self.xLocations[decodedData.3[i][1]-1],
                                         colour: self.botColour,
                                         location: (row: decodedData.3[i][0], column: decodedData.3[i][1]),
                                         yPosition: yLocations[decodedData.3[i][0]-1])
                        
                    }
                }
                
                // Toggle players turn so it is on the correct bool when the game reusmes fully
                self.playersTurn.toggle()
                
            }
        }
        
        // Allow animations again and start the new game session with the initial moves after 1.35 second (decided as the colour flash will line up with the final note in the played music)
        dontAnimate = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
            self.newGameSession(initialMoves)
        }
    }
    
    // Method to initiate a historic game
    private func historicModeActive() {
        
        // Ensure that game area interaction is disabled
        tapGameArea.isEnabled = false
        
        // Decode the historic data
        let decodedData = K.Data.decodeSave(historicGameString)
        
        // Set user and bot colours based on decoded data
        if decodedData.0 {
            userColour = decodedData.2
            botColour = decodedData.1
        } else {
            userColour = decodedData.1
            botColour = decodedData.2
        }
        
        // Isolate the array of piece locations
        var positionsData = decodedData.3
        
        // Bool to tell createPiece method if the piece needs to be white
        var isWhite = false
        
        // New string containing note to play as it will be emptied as pieces are dropped and the origional will be needed in the case the user wants to see the game again
        var playingString = musicString
        
        // Create counter and initiate timer
        var i = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                
            // Remove and play the first note from the string
            Music.playMusic(Music.musicNotes[playingString.removeFirst().wholeNumberValue!])
                
            // If the first int in the current position is 8 remove it and toggle isWhite
            if positionsData[i][0] == 8 {
                positionsData[i].removeFirst()
                isWhite.toggle()
            }
            
            // Place the apropiatly coloured piece
            if i%2 == 1 {
                self.createPiece(xPosition: self.xLocations[positionsData[i][1]-1], colour: self.botColour, isWhite: isWhite)
            } else {
                self.createPiece(xPosition: self.xLocations[positionsData[i][1]-1], colour: self.userColour, isWhite: isWhite)
            }
            
            // Toggle isWhite if it was toggled this timer
            if isWhite {
                isWhite.toggle()
            }
            
            // Increment counter and invalidate timer if we have reached the end of the timer
            i += 1
            if i == positionsData.count {
                self.timer.invalidate()
                // Animate appearence of the repeateButton
                UIView.animate(withDuration: 2) {
                    self.repeatButton.alpha = 1
                }
            }
        })
    }
    

// MARK: - New Game Button Methods
    
    // Method to round the colour buttons so they look like pieces
    private func roundColourButtons() {
        // Round all buttons and set tint/backgound colour. i used to access correct element in pieceColours array
        var i = 0
        for button in colourButtons {
            button.layer.cornerRadius = button.bounds.size.width / 2
            button.clipsToBounds = true
            button.tintColor = K.BoardAndPieces.pieceColours[i]
            button.backgroundColor = K.BoardAndPieces.pieceColours[i]
            i += 1
        }
    }
    
    // Method to hide all buttons and labels
    private func hideAllButtonsAndLabels() {
        // Hide all colour buttons
        for button in colourButtons {
            button.alpha = 0
        }
        // Hide all posiiton buttons
        for button in positionButtons {
            button.alpha = 0
        }
        // Hide all labels
        positionLabel.alpha = 0
        colourLabel.alpha = 0
        resultLabel.alpha = 0
    }
    
    // Method to show the buttons so user can pick if they go first or second. This is basically the start of a new game from the master VC, swipe, or previous game ending
    private func showPositionButtons() {
        
        // Remove any pieces in the superview and pieces array
        for piece in pieces {
            piece.removeFromSuperview()
        }
        pieces.removeAll()
        
        // If the result label is on display hide it with animation
        if resultLabel.alpha == 1 {
            UIView.animate(withDuration: 1) {
                self.resultLabel.alpha = 0
            }
        }

        // Show all position buttons with animation
        for button in positionButtons {
            UIView.animate(withDuration: 1) {
                button.alpha = 1
            }
        }
        
        // Show position label with animation
        UIView.animate(withDuration: 1) {
            self.positionLabel.alpha = 1
        }
    }
    
    // Method to hide position buttons and label, and show colour buttons and lable
    private func showColourButtons() {
        
        // Hide the position buttons with animation
        for button in positionButtons {
            UIView.animate(withDuration: 1) {
                button.alpha = 0
            }
        }
        
        // Hide and show the relevent text labels with animations
        UIView.animate(withDuration: 1) {
            self.positionLabel.alpha = 0
            self.colourLabel.alpha = 1
        }
        
        // Show the colour buttons with animation
        for button in colourButtons {
            UIView.animate(withDuration: 1) {
                button.alpha = 1
            }
        }
    }
    
    // Method to hide the colour buttons and label
    private func hideColourButtons() {
        
        // Hide the colour buttons with animation
        for button in colourButtons {
            UIView.animate(withDuration: 0) {
                button.alpha = 0
            }
        }
        
        // Hide the colour label
        UIView.animate(withDuration: 0) {
            self.colourLabel.alpha = 0
        }
    }
    
    
// MARK: - Misc
    
    // Start game session with random bot parameter
    private func newGameSession(_ initialMoves: [(Int, Int)] = []) {
        
        // Flash the piece locations in the user colour
        flashColour(userColour)
        
        // Enable user interaction
        tapFlashArea.isEnabled = true
        swipeGesture.isEnabled = true
        otherSwipteGesture.isEnabled = true
        
        // Start a new gameSession
        self.gameSession.startGame(delegate: self, botPlays: self.botColor, first: self.isBotFirst, initialPositions: initialMoves)
    }
    
    // Method to assign game variables
    private func setGameArea() {
 
        // Call method to calcualte game variables
        let boardVariables = K.BoardAndPieces.calculateBoardVariables(gameAreaView.frame)
        
        // Assign computed variables to their local. This could have been skipped but boardVariables was created well after the game variables used here. A refactor is needed to remove these
        gameHeight = boardVariables.gameHeight
        gameWidth = boardVariables.gameWidth
        columnWidth = boardVariables.columnWidth
        pieceDiameter = boardVariables.pieceDiameter
        dropVarience = boardVariables.dropVarience
        dropYLocation = boardVariables.dropYLocation

        // Assign the array variables
        barrierColumnPoints = boardVariables.barrierColumnPoints
        xLocations = boardVariables.xLocations
        yLocations = boardVariables.yLocations
        
        // Add base to the colider. This is the bottom of the game board
        collider.addBoundary(withIdentifier: "base" as NSCopying, from: CGPoint(x: gameAreaView.frame.minX, y: gameAreaView.frame.maxY), to: CGPoint(x: gameAreaView.frame.maxX, y: gameAreaView.frame.maxY))

        // Create valiable to name the verticle bountried (V0, V1, V2, ..., V7)
        let name = "V"

        // Create verticle boundries
        for num in 0...7 {
            collider.addBoundary(withIdentifier: "\(name)\(num)" as NSCopying, from: CGPoint(x: barrierColumnPoints[num], y: gameAreaView.frame.maxY), to: CGPoint(x: barrierColumnPoints[num], y: gameAreaView.frame.minY))
        }
        
        // Ensure that the boardView subview is alwasy on top of the pieces
        boardView.layer.zPosition = CGFloat.greatestFiniteMagnitude
        boardView.setPath(gameWidth: boardVariables.gameWidth, gameHeight: boardVariables.gameHeight, columnWidth: boardVariables.columnWidth, gameBoard: boardView.bounds, pieceDiameter: boardVariables.pieceDiameter)
    }

    // Method to get the column number for the piece to be dropped in by the user on tap
    private func getColumnNumber(_ currentXPoint: CGFloat) -> Int {
        
        // Check the passed coordinate against the array of drop points. If the drop point is higher than the passed coordinate return the previous columns number
        for i in 1...6 {
            if currentXPoint <= xLocations[i] {
                return i-1
            }
        }
        // Return the final column as all other columns have been checked
        return 6
    }
    
    // Method to create a piece and place/drop it. Optional arguements used depending on the context using this method
    private func createPiece(xPosition: CGFloat, colour: UIColor, location: (row: Int, column: Int) = (8,8), yPosition: CGFloat = 0, isWhite: Bool = false) {
        
        // Create the pieces frame
        var frame = CGRect()
        frame.size = CGSize(width: pieceDiameter, height: pieceDiameter)
        
        
        if dontAnimate {
            // If don't animate is active set the origin to the board position so the piece spans in its final position
            frame.origin = CGPoint(x: (xPosition), y: yPosition)
        } else {
            // Otherise set span location to the top of the screen. Drop varience creates a visual wobble so pieces don't always drop straight down
            frame.origin = CGPoint(x: (xPosition + CGFloat.random(in: -(dropVarience)...dropVarience)), y: dropYLocation)
        }
        
        // Create piece
        let piece = PieceView(frame: frame)
        
        // Create number label and set its size and location
        let numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: piece.bounds.width, height: piece.bounds.height))
        numberLabel.font = UIFont.systemFont(ofSize: 30)
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.center = CGPoint(x: piece.bounds.midX, y: piece.bounds.midY)
        numberLabel.textAlignment = .center
        
        // If in demo mode set the text to a random emoji from the array. Otherwise set it to the piece's number and increment the tracking variable
        if demoMode {
            numberLabel.text = K.BoardAndPieces.demoEmojis[Int.random(in: 0..<K.BoardAndPieces.demoEmojis.count)]
        } else {
            numberLabel.text = "\(pieceNumber)"
            pieceNumber += 1
        }
        
        // Set the standard label and background colour
        numberLabel.textColor = .black
        piece.backgroundColor = colour
        
        // Set parameeters based on the views mode
        if currentGame || newGame {
            numberLabel.alpha = 0
        } else if historicGame && isWhite {
            numberLabel.textColor = colour
            piece.backgroundColor = .white
        }
        
        // Add piece to subview
        piece.addSubview(numberLabel)
        
        // Store its location on the board in the piece
        piece.location = location
        
        // Add piece to piece tracking array
        pieces.append(piece)
        
        // Hide the piece, add to superview, and animate its appearence
        piece.alpha = 0
        gameAreaView.addSubview(piece)
        UIView.animate(withDuration: 0.5) {
            piece.alpha = 1
        }
        
        // Give piece collision and gravity
        collider.addItem(piece)
        gravity.addItem(piece)
        
    }
    
    // Method to flash the game board so the user can see all the positions. Option argument used as the flash is longer when the game ends
    private func flashColour(_ colour: UIColor, _ duraction: TimeInterval = 1.5 ) {
        
        // Async so the user can still interact and place pieces
        DispatchQueue.main.async {
            
            // Set the background colour to the users piece colour
            self.gameAreaView.backgroundColor = colour
            
            // Animate the return to the black background colour so the users colour fades creating a light flash effect
            UIView.animate(withDuration: duraction) {
                self.gameAreaView.backgroundColor = .black
            }
        }
    }
    
    
    // MARK: - User Interaction
    
    // Method for when the repeat button is tapped
    @IBAction func repeatButtonPressed(_ sender: UIButton) {
        
        // Reset piece numbers and deactivate collider
        pieceNumber = 1
        animator?.removeBehavior(collider)
        
        // Hide repeat button with animation
        UIView.animate(withDuration: 2) {
            self.repeatButton.alpha = 0
        }
        
        // After 3 seconds add collider behaviour and call the historic mode method
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.animator?.addBehavior(self.collider)
            self.historicModeActive()
        }
    }
    
    // Method for when the user swipes to clear the board
    @IBAction func swipeToClear(_ sender: UISwipeGestureRecognizer) {
        
        // Deactivate various user interactions
        tapGameArea.isEnabled = false
        tapFlashArea.isEnabled = false
        swipeGesture.isEnabled = false
        otherSwipteGesture.isEnabled = false
            
        // Remove the collider to clear the board
        animator?.removeBehavior(collider)
        
        // Clear the current games dataString and clear user defaults too
        dataString = ""
        K.Data.defaults.set("\(dataString)", forKey: K.Data.dataString)
        
        // After 3 seconds add collider behaviour and show the choose position buttons to start a new game
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.animator?.addBehavior(self.collider)
            self.showPositionButtons()
        }
    }
    
    // Method for when the user taps the game area to drop a disc
    @IBAction func gameAreaTapped(_ sender: UITapGestureRecognizer) {
    
        // Get the touch point location and call method get the relevent collumn x drop point
        let touchPoint = sender.location(in: boardView)
        let column: Int = getColumnNumber(touchPoint.x)+1
        
        // If the move is valid drop the piece
        if gameSession.isValidMove(column) {
            gameSession.dropDiscAt(column)
        } else {
            print("invalid")
        }
    }
    
    // Method for when the user taps outside the game area
    @IBAction func flashAreaTapped(_ sender: UITapGestureRecognizer) {
        // Call method to flash the users colour on the empty areas of the game baord
        flashColour(userColour)
    }
    
    // Method for then the user has tapped a position button
    @IBAction func chosenPositionButton(_ sender: UIButton) {
        
        // Check the buttons tag and assign variables appropiatly for user or bot first
        if sender.tag == 2 {
            isBotFirst = true
            playersTurn = false
            botIsFirstString = "1"
        } else {
            isBotFirst = false
            playersTurn = true
            botIsFirstString = "0"
        }
        
        // Call method to show colour buttons and hide position buttons
        showColourButtons()
        
    }
    
    // Method for when the user has tapped a colour button
    @IBAction func chosenColourButton(_ sender: UIButton) {
        
        // Save the button tint colour
        userColour = sender.tintColor
        
        // Randomly pick a colour for the bot. Repeat if same colour is chosen
        repeat {
            self.botColour = K.BoardAndPieces.pieceColours[Int.random(in: 0...5)]
        } while botColour == userColour
        
        // Set core data variables based on if the user or the bot is first
        if isBotFirst {
            firstColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: botColour)!)
            secondColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: userColour)!)
        } else {
            firstColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: userColour)!)
            secondColour = Int16(K.BoardAndPieces.pieceColours.firstIndex(of: botColour)!)
        }
        
        // Save user and bot colours
        playerColourString = "\(K.BoardAndPieces.pieceColours.firstIndex(of: userColour)!)"
        botColourString = "\(K.BoardAndPieces.pieceColours.firstIndex(of: botColour)!)"
        
        // Set initial datastring
        dataString = "\(botIsFirstString)\(playerColourString)\(botColourString)"
        
        // Hide colour buttons and label
        hideColourButtons()
        
        // Enable interaction with the game area and start a new game session with no initial moves
        tapGameArea.isEnabled = true
        newGameSession()
    }
}


// MARK: - GameSessionProtocol

extension ViewController: GameSessionProtocol
{
    // GameSessionProtocol update for game state changes
    func stateChanged(_ gameSession: GameSession, state: SessionState, for playerTurn: DiscColor, textLog: String) {
        
        // Handle state transition
        switch state
        {
            
        // Inital state
        case .cleared:
            // Enable button if player turn is user
            let isUserTurn = (playerTurn != botColor)
            tapGameArea.isEnabled = isUserTurn
            
        // Player evaluating position to play
        case .thinking(_):
            // Disable button while thinking
            tapGameArea.isEnabled = false
            
        // Waiting for player to play
        case .idle(let color):
            
            // If bot's turn disable users ability to tap the game board and drop a piece. Otherwise enable users ability to interact with board. 1 second delay to prevent pieces being dropped and hitting off preceeding piece due to a wide drop varience
            if color == botColor {
                tapGameArea.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    gameSession.dropDisc()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.tapGameArea.isEnabled = true
                }
            }
            
        // End of game.
        case .ended(let outcome):
            
            // Disable user's interaction with the game board
            tapGameArea.isEnabled = false
            
            // Create game result string
            var gameResult = String()
    
            // Remove the last item from the musicString as the ending melody will be replacing it
            musicString.removeLast()
            
            // Actions based on game outcome
            switch outcome {
                
            // If bot won
            case botColor:
                
                // Set the gameResult's text
                gameResult = "You loose! 😟"
                
                // Flash the bot's piece colour
                flashColour(self.botColour, 5)
                
                // Set bool variables for core data to use
                botWon = true
                userWon = false
                
                // Add loosing melody to the musicString and play it
                musicString += "5"
                Music.playMusic("Bad")

                
            // If user won
            case !botColor:
                
                // Set the gameResult's text
                gameResult = "You win! 😊"
                
                // Flash the user's piece colour
                flashColour(self.userColour, 5)
                
                // Set bool variables for core data to use
                botWon = false
                userWon = true
                
                // Add winning melody to the musicString and play it
                musicString += "6"
                Music.playMusic("Good")
                
                
            // If draw
            default:
                
                // Set the gameResult's text
                gameResult = "Draw! 😐"
                
                // No flash as all spaces used
                
                // Set bool variables for core data to use
                botWon = false
                userWon = false
                
                // Add draw melody to the musicString and play it
                musicString += "7"
                Music.playMusic("Draw")
                
            }
            
            // Display gameResult to user
            self.resultLabel.text = "\(gameResult)\nStarting new game"
            
            // After set amount of time
            Task {
                try await Task.sleep(nanoseconds: 5_000_000_000)
                await MainActor.run {
                    
                    // Remove collider behaviour so pieces leave the board
                    animator?.removeBehavior(collider)
                    
                    // Animate appearence of the result label
                    UIView.animate(withDuration: 2) {
                        self.resultLabel.alpha = 1
                    }
                    
                    // After 3 seconds readd collider behaviour and show the position buttons to initiaite a new game
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                        self.animator?.addBehavior(self.collider)
                        self.showPositionButtons()
                    }
                }
            }
            
        // Unknown case
        @unknown default:
            break
        }
    }
    
    
    // GameSessionProtocol notifying of the result of a player action
    // textLog provides some string visualization of the game board for debug purposes
    func didDropDisc(_ gameSession: GameSession, color: DiscColor, at location: (row: Int, column: Int), index: Int, textLog: String) {
        
        if isFirstMove {
            // If it is the first move of the game play the note C and add it to the string. Toggle isFirstMove as it is no longer the first move
            Music.playMusic("C")
            musicString = "0"
            isFirstMove.toggle()
        } else {
            // Create var to hold the next notes number
            var noteNumber = Int()
            
            // Randomly pick a note until one is picked that is not the previous note
            repeat {
                noteNumber = Int.random(in: 0...4)
            } while "\(noteNumber)" == "\(musicString.last!)"
            
            // Add the note to the musicString and play the note
            musicString += "\(noteNumber)"
            Music.playMusic(Music.musicNotes[noteNumber])
        }
        
        // Actions to take based on whos turn it is
        if playersTurn{
            // Player turn. Create player's piece and toggle whos turn it is
            createPiece(xPosition: xLocations[(location.1)-1], colour: userColour, location: location)
            playersTurn.toggle()
            
            // Add location to dataString
            dataString += "\(location.row)\(location.column)"
            
            // Add location to movesArray
            movesArray.append(location)
            
            // Update lastUsedColour
            lastUsedColour = userColour
        } else {
            // Bot turn. Create bot's piece and toggle whos turn it is
            createPiece(xPosition: xLocations[(location.1)-1], colour: botColour, location: location)
            playersTurn.toggle()
            
            // Add location to dataString
            dataString += "\(location.row)\(location.column)"
            
            // Update user defaults for both the dataString and the musicString
            K.Data.defaults.set("\(dataString)", forKey: K.Data.dataString)
            K.Data.defaults.set("\(musicString)", forKey: K.Data.musicString)
            
            // Add location to movesArray
            movesArray.append(location)
            
            // Update lastUsedColour
            lastUsedColour = botColour
        }
    }

    
    // GameSessionProtocol notification of next player to play
    func turnToPlay(_ gameSession: GameSession, color: DiscColor) {
        // Not used.
    }

    
    // GameSessionProtocol notification of end of game
    func didEnd(_ gameSession: GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)]) {
        
        // Disable interaction
        tapFlashArea.isEnabled = false
        swipeGesture.isEnabled = false
        otherSwipteGesture.isEnabled = false
        
        // Empty datastring and clear user defaults
        dataString = ""
        K.Data.defaults.set("\(dataString)", forKey: K.Data.dataString)
        
        // Readd first three items to datastring
        dataString = "\(botIsFirstString)\(playerColourString)\(botColourString)"
        
        // Animate the appearence of each pieces number and if the disc is a winner, change its background colour to white
        for disc in pieces {
            for subview in disc.subviews {
                UIView.animate(withDuration: 3) {
                    subview.alpha = 1
                }
            }
            for winner in winningActions {
                if winner == disc.location {
                    disc.backgroundColor = .white
                }
            }
        }
        
        // Var to track if a piece was found in the winner array
        var notFound = true
        
        // Add each piece to the dataString and, if it was a winner, add the flag 8 before its location
        for location in movesArray {
            for winner in winningActions {
                if winner == location {
                    dataString = "\(dataString)8\(location.row)\(location.column)"
                    notFound = false
                    // Break here as a winning piece has been found and
                    break
                }
            }
            
            if notFound {
                dataString = "\(dataString)\(location.row)\(location.column)"
            }
            notFound = true
        }
        
        // Games context variable
        let gameSave = Games(context: K.Data.context)
        
        // Adjust context for items in the database
        gameSave.gameString = dataString
        gameSave.firstColour = firstColour
        gameSave.secondColour = secondColour
        gameSave.dateCreated = Date.now
        if dataString.first == "1" {
            gameSave.botFirst = true
        } else {
            gameSave.botFirst = false
        }
        gameSave.botWon = botWon
        gameSave.userWon = userWon
        gameSave.musicString = musicString
        gameSave.winnerColour = Int16(K.BoardAndPieces.pieceColours.lastIndex(of: lastUsedColour)!)

        // Save game to core data
        do {
            try K.Data.context.save()
            print("saving")
        } catch {
            print("issue")
        }
        
        // Prepare for a new game by clearing the music string and removing it from user defautls, resetting the isFirstMoce boolean,clearing the dataString, and resetting piece numbers
        musicString = ""
        K.Data.defaults.set("", forKey: K.Data.musicString)
        dataString = ""
        pieceNumber = 1
        isFirstMove.toggle()
    }
}
