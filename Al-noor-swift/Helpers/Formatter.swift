//
//  Formatter.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 29/04/2024.
//

import Foundation


func capitalizeFirstLetter(_ str: String) -> String {
    guard let firstChar = str.first else { return str }
    return String(firstChar).uppercased() + String(str.dropFirst())
}

func formatCountdownTime(from date: Date) -> String {
    // Get current date and time
    let currentDate = Date()
    
    // Calculate time interval between current date/time and the target date/time
    let timeDifference = date.timeIntervalSince(currentDate)
    
    // Calculate remaining hours and minutes
    let hours = Int(timeDifference / 3600)
    let minutes = Int((timeDifference / 60).truncatingRemainder(dividingBy: 60))
    
    // Construct the formatted string
    var formattedString = ""
    if hours > 0 {
        formattedString += "\(hours)h"
    }
    if minutes > 0 {
        formattedString += "\(minutes)"
    }
    
    return formattedString
}

