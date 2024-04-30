//
//  Al_noor_widget.swift
//  Al-noor-widget
//
//  Created by Mansour Mahamat-salle on 30/04/2024.
//

import WidgetKit
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct Al_noor_widgetEntryView : View {
    var entry: Provider.Entry
    //    let encodedData  = UserDefaults(suiteName: "group.al-noor-swift")!.object(forKey: "currentPrayer") as? Data
    //
    @State private var currentPrayer: String = ""
    @State private var currentTimePrayerTimeFormatted: String = ""
    
    
    func retrieveValuesFromUserDefaults() {
        if let suiteUserDefaults = UserDefaults(suiteName: "group.al-noor-swift") {
            
            self.currentPrayer = suiteUserDefaults.string(forKey: "currentPrayer") ?? ""
            
            self.currentTimePrayerTimeFormatted  = suiteUserDefaults.string(forKey: "currentTimePrayerTimeFormatted") ?? ""
            
        }
    }
    
    var body: some View {
        VStack {
            
            ZStack {
                Color(hex: "4c6c53").ignoresSafeArea()
                VStack {
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Text("🕋")
                            .font(.title2)
                        Spacer()
                        Text(currentPrayer)
                            .font(.system(size: 18, weight: .black))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle( .white)
                            .padding(.top,  0)
                        Spacer()
                    }
                    //animate VStack
                    .id(entry.date)
                    .transition(.push(from: .trailing))
                    .animation(.bouncy, value: entry.date)
                    Spacer()
                    Text(currentTimePrayerTimeFormatted)
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle( .white)
                    //animate number change
                        .contentTransition(.numericText())
                    
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
       
       
        .onAppear {
                       // Retrieve values from UserDefaults when the view appears
                       retrieveValuesFromUserDefaults()
                   }
        
    }
        
    
                           
    }
        


struct Al_noor_widget: Widget {
    let kind: String = "Al_noor_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Al_noor_widgetEntryView(entry: entry)
                .containerBackground(Color(hex: "4c6c53"), for: .widget)
        }
        .supportedFamilies([.systemSmall])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    Al_noor_widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
//    SimpleEntry(date: .now, configuration: .starEyes)
}
