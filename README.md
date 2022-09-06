# iOS-Connect-4-Project
iOS Connect 4 app

The repo contains my Connect 4 game project created for my iOS module at UCD. Please note that the folder Alpha0C4 and its content, the game's AI, are not mine and were provided by my lecturer. 

The app allows users to play Connect 4 against an AI. They may choose from multiple piece colours, expanded from the number the AI is designed to work with, and games are saved using user defaults after each turn. Core data is used to store completed games and the user can choose them from the main menu to replay. 

Within core data and user defaults the pieces are stored as a sequence of numbers representing the pieces location on the board, with flags to indicated the players colour, AI's colour, who went first, and if a piece is a winning piece. A method in the constants.swift file is able to decypher these  reguardless of the source. 

A unique feature is that each game generates its own unique melody as the user plays. This is through the use of the pentatonic scale, with a handful of limitations. This is also stored with the games so the menlody can be played back with the replayed game. These notes are stored as a string of numbers, with each number representing a sound file.

Additional details on how the app works can be found in the ReadMeReport.pdf file. 

There are two known issues with the app. The app does not handle rotation well, only being able to reliably do so when not in a game, such as the menus. Solutions to this were identified, and are mentioned in the report, but this repo containes the app as origionally submitted. The second issue is that the demo mode can cause issues if left running as the app does not correctly despawn these pieces. Once again, an easy solution would be to no despawn the pieces, but move them to above the view so they are reused. Once again, this could not be implemented before the apps submission, so the solution has not been implemented here.  

Thank you for taking the time to look over my repository. 
Eoin
