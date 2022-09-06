//
//  Music.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 14/04/2022.
//

import Foundation
import AVFoundation

struct Music {
    
    // Array of the names of the note files
    static let musicNotes = ["C", "D", "E", "G", "A", "Bad", "Good", "Draw"]
    
    // Audio Player
    static var musicPlayer = AVAudioPlayer()
    
    
    // Method to play the passed note
    static func playMusic(_ note: String) {
        
        // Retrieve and prepare file for playing
        let file = Bundle.main.url(forResource: note, withExtension: "wav")
        musicPlayer = try! AVAudioPlayer(contentsOf: file!)
        
        // Play audio file
        musicPlayer.play()
        
    }
}
