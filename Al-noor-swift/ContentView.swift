//
//  ContentView.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//

import SwiftUI


struct ContentView: View {
    
    @State private var activeTab: Tab = .home
    
    var body: some View {
        TabView(selection: $activeTab) {
                       Home()
                           .tag(Tab.home)
                           .tabItem { Tab.home.tabContent }
                       Qibla()
                           .tag(Tab.qibla)
                           .tabItem { Tab.qibla.tabContent }
                       QuranView()
                           .tag(Tab.quran)
                           .tabItem { Tab.quran.tabContent }
//                       Settings()
//                           .tag(Tab.settings)
//                           .tabItem { Tab.settings.tabContent }
                   }
        
    }
}

#Preview {
    ContentView()
}
