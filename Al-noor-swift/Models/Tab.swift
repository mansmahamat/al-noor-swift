//
//  Tab.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//


import SwiftUI

enum Tab: String {
    case home = "Home"
    case qibla = "Qibla"
    case quran = "QuranView"
    case settings = "Settings"
    
    @ViewBuilder
    var tabContent:some View {
        switch self {
        case .home:
            Image(systemName: "calendar")
            Text(self.rawValue)
        case .qibla:
            Image(systemName: "safari")
            Text(self.rawValue)
        case .quran:
            Image(systemName: "book")
            Text(self.rawValue)
        case .settings:
            Image(systemName: "gearshape")
            Text(self.rawValue)
        }
    }
}
