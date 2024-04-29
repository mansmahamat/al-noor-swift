//
//  Settings.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 28/04/2024.
//

import SwiftUI
import Adhan



struct Settings: View {
    
    @State private var showingSheet: Bool = false
    @AppStorage("methodCalculationPrayer") private var methodCalculationPrayer = CalculationMethod.muslimWorldLeague.rawValue
    @AppStorage("madhabCalculationPrayer") private var madhabCalculationPrayer = "shafi"
   
    var body: some View {
        NavigationView{
                                       List{
                                           Section{
                                               Button("Schedule Notification") {
                                                   let content = UNMutableNotificationContent()
                                                   content.title = "Fajr is at "
                                                   content.subtitle = "Time to pray"
                                                   content.sound = UNNotificationSound.default

                                                   // show this notification five seconds from now
                                                   let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                                                   // choose a random identifier
                                                   let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                                                   // add our notification request
                                                   UNUserNotificationCenter.current().add(request)
                                               }
                                           }
                                           .listRowSeparator(.hidden)
                                           
                                           Button(action: {
                                               showingSheet = true
                                           }) {
                                               HStack(spacing: 10) {
                                                               Image(systemName: "book.pages") // Icon before text
                                                                   .foregroundColor(.primary) // Icon color
                                                                   .font(.system(size: 15)) // Icon size
                                                               
                                                               Text(madhabCalculationPrayer)
//                                                                   .fontWeight(.bold) // Text font weight
                                                                   .foregroundColor(.primary) // Text color
                                                           }
                                           }
                                           .listRowSeparator(.hidden)
                                           .sheet(isPresented: $showingSheet) {
                                               // Code
                                               Form {
                                                   Section(header: Text("Parameters")) {
                                                       Section() {
                                                                                                              Picker("Method", selection: $methodCalculationPrayer) {
                                                                                                                  Text("muslimWorldLeague").tag("muslimWorldLeague")
                                                                                                                  Text("egyptian").tag("egyptian")
                                                                                                                                       Text("karachi").tag("karachi")
                                                                                                                  Text("ummAlQura").tag("ummAlQura")
                                                                                                                  Text("dubai").tag("dubai")
                                                                                                                  Text("qatar").tag("qatar")
                                                                                                                  Text("kuwait").tag("kuwait")
                                                                                                                  Text("moonsightingCommittee").tag("moonsightingCommittee")
                                                                                                                  Text("singapore").tag("singapore")
                                                                                                                  Text("turkey").tag("turkey")
                                                                                                                  Text("tehran").tag("tehran")
                                                                                                                  Text("northAmerica").tag("northAmerica")
                                                                                                                  Text("other").tag("other")
                                                                                                              }
                                                         
                                                           
                                                                                                          }


//                                                   Section(header: Text("User Profiles")) {
//                                                       Picker("Profile Image Size", selection: $profileImageSize) {
//                                                           Text("Large").tag(ProfileImageSize.large)
//                                                           Text("Medium").tag(ProfileImageSize.medium)
//                                                           Text("Small").tag(ProfileImageSize.small)
//                                                       }.pickerStyle(.navigationLink)
                                                       Picker("Madhab", selection: $madhabCalculationPrayer) {
                                                           Text("shafi").tag("shafi")
                                                           Text("hanafi").tag("hanafi")
                                                          
                                                       }
  
    
                                                   }

                                                   }
                                               
                                           }
                                          
                                           
                                           Section{
                                               Link("\(Image(systemName: "link")) Donate to Harrow Mosque  ", destination: URL(string: "https://paypal.com/donate/?hosted_button_id=FF9AN9AKM8BXS&source=url")!)
                                                   .foregroundColor(.primary)
                                               Link("\(Image(systemName: "link")) Find out more about me!  ", destination: URL(string: "https://babyyoda777.github.io")!)
                                                   .foregroundColor(.primary)
                                           }.listRowSeparator(.hidden)
                                           Section{
                                               Link("\(Image(systemName: "play.rectangle.fill"))    YouTube ", destination: URL(string: "https://www.youtube.com/user/harrowmosque/videos")!)
                                                   .foregroundColor(.primary)
                                           }.listRowSeparator(.hidden)
                                           Section{
                                               Link("\(Image(systemName: "camera.metering.center.weighted"))   Instagram ", destination: URL(string: "https://www.instagram.com/harrowmosque/")!)
                                                   .foregroundColor(.primary)
                                           }.listRowSeparator(.hidden)
                                           Section{
                                               Link("\(Text("f").fontWeight(.bold).font(.system(size: 30)))      FaceBook ", destination: URL(string: "https://www.facebook.com/HarrowMosque")!)
                                                   .foregroundColor(.primary)
                                           }.listRowSeparator(.hidden)
                                       }
                                       .listStyle(InsetGroupedListStyle()) // this has been renamed in iOS 14.*, as mentioned by @Elijah Yap
                                       .environment(\.horizontalSizeClass, .regular)
                                       .navigationTitle("Contact Us")
                                   }
                               }
    
    
    }


#Preview {
    Settings()
}
