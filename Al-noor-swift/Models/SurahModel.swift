//
//  SurahModel.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//

import Foundation
import SwiftUI

struct Surah : Codable{
    var data : [Data]
}


struct Data : Codable, Identifiable{
    var number : Int
    var name : String
    var englishName : String
    var englishNameTranslation : String
    var numberOfAyahs : Int
    var revelationType : String
    var id :Int {number}
    
}
