//
//  HistoryVC.swift
//  Connect4
//
//  Created by Eoin Ó'hAnnagáin on 01/04/2022.
//

import UIKit

class HistoryTVC: UITableViewController {
    
    // MARK: - Initial Variables and Setup
    
    // Variables used for passing data into the secondary view
    var chosenInformation = String()
    var chosenMusicString = String()
    
   // Buttong to delete all entries in core data
    @IBOutlet weak var deleteAllButton: UIButton!
    
    // Array of games from core data
    var gameList = [Games]()
    
    // viewWillAppear used as UIView sizes not finalised during viewDidLoad
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            // Fetch Games data from core data and sort by date so the most recent is displayed at the top
            gameList = try K.Data.context.fetch(Games.fetchRequest()).sorted { itemOne, itemTwo in
                itemOne.dateCreated! > itemTwo.dateCreated!
            }
            
            /* After adding Boolean values to the loading from core data would result in an extra entry being returned with its values set to false and nil.
             This next section checks for these and removes them.
             Issue was resolved as it was caused by the context being set up in the secondary view too early. Check remains as a precaution against a repeat of the error.
             */
            for game in gameList {
                if game.gameString == nil {
                    print("NILL FOUND")
                    gameList.remove(at: gameList.firstIndex(of: game)!)
                }
            }
            
        } catch {
            print("There was an issue retreiving from core data: \(error.localizedDescription)")
        }
        
        // Set deletion button status based on games in core data. Both states set as returning from a game may need to alter this.
        if gameList.isEmpty {
            deleteAllButton.isHidden = true
        } else {
            deleteAllButton.isHidden = false
        }
        
        // Reload the tableView's data
        tableView.reloadData()
    }
    
    
    // MARK: - User Interactions
    
    // Action to take if delete button is pressed
    @IBAction func deleteAll(_ sender: UIButton) {
        showDeletionAlert()
    }

    
    // MARK: - Table View Set Up

    
    // Set number of sections (always 2)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Name sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Previous Games"
        } else {
            return "Play Options"
        }
    }

    // Set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            // Always 2
            return 2
            
        } else {
            // Number of rows based on number of games retrieved from core data
            return gameList.count
        }
    }

    // Method to set the contens for cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Cells in First Section
        if indexPath[0] == 0 {
            
            // Create standard cell and set its background and text colours
            let cell = tableView.dequeueReusableCell(withIdentifier: K.SeguesAndCells.playOptionCell, for: indexPath)
            cell.backgroundColor = .purple
            cell.textLabel?.textColor = .white
            
            
            
            if indexPath[1] == 0 {
                // Set text for the New Game cell
                cell.textLabel?.text = "New Game"
            } else {
                // Set text for Current Game cell and take further actions
                cell.textLabel?.text = "Current Game"
                
                // Retrive dataString for current game form user defaults
                if let data = K.Data.defaults.object(forKey: K.Data.dataString) {
                    // If the data string is empty gray out the cell
                    if data as! String == "" {
                        cell.backgroundColor = .darkGray
                        cell.textLabel?.textColor = .black
                    }
                } else {
                    // If the dataString cannot be retrieved print a message and gray out the string
                    print("Error retrieving current dataString")
                    cell.backgroundColor = .darkGray
                    cell.textLabel?.textColor = .black
                }
            }
            // Return the cell
            return cell
            
        // Cells in second section
        } else {
            
            // Dequeue a historicCell
            let cell = tableView.dequeueReusableCell(withIdentifier: K.SeguesAndCells.historicCell, for: indexPath) as! HistoryTVCell
            
            // Pass variables to historicCell
            cell.saveString = "\(gameList[indexPath.row].gameString!)"
            cell.piecesArray = K.Data.decodeSave(gameList[indexPath.row].gameString!).3
            cell.firstColour = K.BoardAndPieces.pieceColours[Int(gameList[indexPath.row].firstColour)]
            cell.secondColour = K.BoardAndPieces.pieceColours[Int(gameList[indexPath.row].secondColour)]
            
            // Set colour for text labels
            cell.firstPlayerLabel.textColor = K.BoardAndPieces.pieceColours[Int(gameList[indexPath.row].firstColour)]
            cell.winnerLabel.textColor = K.BoardAndPieces.pieceColours[Int(gameList[indexPath.row].winnerColour)]
            
            // Set label based on who played first
            if gameList[indexPath.row].botFirst {
                cell.firstPlayerLabel.text = "Bot Started"
            } else {
                cell.firstPlayerLabel.text = "User Started"
            }
            
            // Set label based on who won the game
            if gameList[indexPath.row].userWon && !(gameList[indexPath.row].botWon) {
                cell.winnerLabel.text = "User Won"
            } else if !(gameList[indexPath.row].userWon) && gameList[indexPath.row].botWon {
                cell.winnerLabel.text = "Bot Won"
            } else {
                cell.winnerLabel.text = "Draw"
            }
            
            cell.firstPlayerLabel.adjustsFontSizeToFitWidth = true
            cell.winnerLabel.adjustsFontSizeToFitWidth = true
            
            // Return the cell
            return cell
        }
    }
    
    
    // MARK: - Table View Interaction and Segue
    
    
    // Method for when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenCell = tableView.cellForRow(at: indexPath)
        
        // Data to set to segue variables depending on the chosen row's section
        if indexPath.section == 0 {
            // Set the segue variable to the cells text label
            chosenInformation = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
        } else {
            // Set both segue variables
            chosenInformation = gameList[indexPath.row].gameString!
            chosenMusicString = gameList[indexPath.row].musicString!
        }
        
        // Show an alert if the Current Game row was selected, otherwise perform segue. Deselect row regardless.
        if chosenCell?.backgroundColor == .darkGray {
            tableView.deselectRow(at: indexPath, animated: false)
            showCurrentAlert()
        } else {
            performSegue(withIdentifier: K.SeguesAndCells.toSecondary, sender: self)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }


    // Segue preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Manage segue due to presence of navigation controllers
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController {
            destinationVC = navigationVC.visibleViewController!
        }
        
        // Check segue identifer. Origionally more segues were planned but they proved unnecessary. Leaving in the check futureproofs against future segue options.
        if segue.identifier == K.SeguesAndCells.toSecondary {
            let nextVC = destinationVC as! ViewController
            // Pass segue variables onto the next view controller
            nextVC.passedInput = chosenInformation
            nextVC.musicString = chosenMusicString
        }
    }
    
    
    // MARK: - Single Deletion
    
    // Set the editing style for all rows to delete
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // Method to make action based on editing style
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // If the style is delete (currently only option but futureproofs incase more are added)
        if editingStyle == .delete{
            
            // Begin updates
            tableView.beginUpdates()

            // Add games deletion to core data context
            K.Data.context.delete(gameList[indexPath.row])

            // Delete game from core data
            do {
                try K.Data.context.save()
                
                // Remove the game from the games list and delete its row if deletion was successful
                gameList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .top)
            } catch {
                print("Failed to delete: \(error.localizedDescription)")
            }

            // End updates. The number of games should at this point equal the number of rows otherwise the app will crash
            tableView.endUpdates()
            
            // Check the number of games and hide the delete all button if needed
            if gameList.count == 0 {
                deleteAllButton.isHidden = true
            }
        }
    }
    
    
}


// MARK: - Alerts

extension HistoryTVC {
    
    private func showCurrentAlert() {
        
        // Create alert
        let alert = UIAlertController(title: "No Current Game", message: "There is currently no active game", preferredStyle: .alert)
        
        // Create button for alert. Set handler to nil as there is no action to take
        alert.addAction(UIAlertAction(title: "Acknowledge", style: .cancel, handler: nil))
        
        // Generate alert
        present(alert, animated: true)
        
    }
    
    private func showDeletionAlert() {
        
        // Create alert
        let alert = UIAlertController(title: "Delete all Historic Games", message: "Are you sure you want to delete all \(gameList.count) historic games. This action cannot be undone", preferredStyle: .alert)
        
        // Create cancel button for alert. Set handler to nil as there is no additional action to take
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Create delete button for alert and the code to run if selected
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: { _ in

            // Create a variable to hold the array of all index paths to delete
            var indexPathsToDelete = [IndexPath]()
            
            // Add each games index path to the array and set it to be deleted in the core data context
            for i in 0..<self.gameList.count {
                indexPathsToDelete.append([1, i])
                let game = self.gameList[i]
                K.Data.context.delete(game)
            }

            // Attempt to delete from core data
            do {
                try K.Data.context.save()
                
                // If successful remove all from gameList, hide deleteAllButton, and delete all rows
                self.gameList.removeAll()
                self.deleteAllButton.isHidden = true
                self.tableView.deleteRows(at: indexPathsToDelete, with: UITableView.RowAnimation.top)
                
            } catch {
                print("Failed to delete all: \(error.localizedDescription)")
            }
        }))

        // Generate alert
        present(alert, animated: true)
        
    }
}
