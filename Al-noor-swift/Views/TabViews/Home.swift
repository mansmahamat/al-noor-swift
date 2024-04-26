//
//  Home.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//

import SwiftUI
import Adhan
import CoreLocation
import UserNotifications


struct Home: View {
    @StateObject private var locationManager = LocationManager()
    @State private var prayerTimes: PrayerTimes?
    @State private var currentTimeZone: TimeZone = TimeZone.current
    @State private var nextFajrTime: Date?
    @State private var currentPrayerName: String = ""
       @State private var nextPrayerName: String = ""
       @State private var timeUntilNextPrayer: String = ""
    
    @State private var city: String = ""
    
    var body: some View {
       
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 15) {
                    ZStack(alignment: .topLeading) {
                        
                        // Banner Image
                        GeometryReader{proxy in
                            let size = proxy.size
                            
                            Image("mosque")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(CustomCorner(corners: [.topLeft,.topRight], radius: 15))
                        }
                        .frame(height: 300)
                        
                        LinearGradient(colors: [
                            
                            .black.opacity(0.5),
                            .black.opacity(0.2),
                            .clear
                        ], startPoint: .top, endPoint: .bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Prayer")
                                .font(.callout)
                                .fontWeight(.semibold)
                            
                            Text(currentPrayerName)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundColor(.primary)
                        .padding()
                        //                    .offset(y: currentItem?.id == item.id && animateView ? safeArea().top : 0)
                    }
                    
                    HStack(spacing: 12){
                        
                        getCurrentPrayerIcon()
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        
                       
                          
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next Prayer")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(timeUntilNextPrayer)
                                .font(.callout)
                                .fontWeight(.bold)
                            
                            Text(nextPrayerName)
                                .font(.callout)
                                .fontWeight(.bold)
                               
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        
//                        Button {
//                            
//                        } label: {
//                            
//                            Text(city)
//                                .fontWeight(.bold)
//                                .foregroundColor(.blue)
//                                .padding(.vertical,8)
//                                .padding(.horizontal,20)
//                                .background{
//                                    Capsule()
//                                        .fill(.ultraThinMaterial)
//                                }
//                        }
                        
                        Button(action: {
                                       scheduleTestNotification()
                                   }) {
                                       Text(city)
                                           .fontWeight(.bold)
                                           .foregroundColor(.blue)
                                           .padding(.vertical,8)
                                           .padding(.horizontal,20)
                                           .background{
                                               Capsule()
                                                   .fill(.ultraThinMaterial)
                                           }
                                   }
                                
                        
                    }
                    .padding([.horizontal,.bottom])
                }
                
                //            .matchedGeometryEffect(id: item.id, in: animation)
                
                NavigationView {
                    List {
                        // Display prayer times
                        Section() {
                            if let times = prayerTimes {
                                ForEach(prayerTimeEntries(from: times), id: \.prayerName) { entry in
                                    PrayerTimeRow(prayerName: entry.prayerName, time: formattedTime(entry.time))
                                }
                            
                        }
                    }
                    
                }
                .onAppear {
                    requestNotificationAuthorization()
                    locationManager.requestLocation()
                }
            }
        }
        .padding()
        
        .onReceive(locationManager.$prayerTimes) { times in
            // Retrieve the location
            guard let location = locationManager.lastKnownLocation else {
                // Handle the case where location is not available
                return
            }

            // Call the asynchronous function to get the time zone and city
            getTimeZoneAndCity(for: location) { timeZone, city in
        
                // Update the current time zone
                if let timeZone = timeZone {
                    print("timeZone: \(timeZone)")
                    self.currentTimeZone = timeZone
                }
                
                // Update the prayer times
                self.prayerTimes = times

                // Update the prayer info
                updatePrayerInfo()
                
                // Optionally, you can use the city here
                if let city = city {
                   
                }
                
                // Schedule notifications for each prayer time
                                if let prayerTimes = self.prayerTimes {
                                    scheduleNotifications(for: prayerTimes)
                                }
            }
        }

    }
    
    func getNextFajrTime(from times: PrayerTimes) -> Date? {
        // Iterate through the prayer times and find the Fajr time for the next day
        for entry in prayerTimeEntries(from: times) {
            if entry.prayerName == "Fajr" {
                return entry.time
            }
        }
        return nil
    }
    
    private func requestNotificationAuthorization() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
                if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                } else if success {
                    print("Notification authorization granted.")
                } else {
                    print("Notification authorization denied.")
                }
            }
        }
    
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification."
        content.sound = UNNotificationSound.default
        
        // Create a trigger to display the notification after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully.")
            }
        }
    }

    
    private func updatePrayerInfo() {
           guard let times = prayerTimes else { return }
           
           let currentPrayer = getCurrentPrayer(times)
           let nextPrayer = getNextPrayer(times)
           
           currentPrayerName = currentPrayer.prayerName
           nextPrayerName = nextPrayer.prayerName
           
           let timeUntilNext = nextPrayer.time.timeIntervalSinceNow
        timeUntilNextPrayer = formattedTimeUntilNext(timeUntilNext, nextFajrTime: nextFajrTime)
        
        if currentPrayer.prayerName == "Isha" {
          
                nextFajrTime = getNextFajrTime(from: times)
            }
       }
    
    private func getCurrentPrayer(_ times: PrayerTimes) -> (prayerName: String, time: Date) {
        let currentTime = Date()
        let localCurrentTime = currentTime.addingTimeInterval(TimeInterval(currentTimeZone.secondsFromGMT()))
        
        // Iterate through prayer times to find the current prayer
        for entry in prayerTimeEntries(from: times) {
            // If the prayer time is after the current time, it's the current prayer
            if entry.time > localCurrentTime {
                return entry
            }
        }
        
        // If no prayer time is found after the current time, return the last prayer of the day
        return prayerTimeEntries(from: times).last!
    }
        
        private func getNextPrayer(_ times: PrayerTimes) -> (prayerName: String, time: Date) {
            let currentTime = Date()
            let localCurrentTime = currentTime.addingTimeInterval(TimeInterval(currentTimeZone.secondsFromGMT()))
            
            print("localCurrentTime: \(localCurrentTime)")
            for entry in prayerTimeEntries(from: times) {
                if entry.time > currentTime {
                    return entry
                }
            }
            
            return prayerTimeEntries(from: times).first!
        }
    private func formattedTimeUntilNext(_ timeInterval: TimeInterval, nextFajrTime: Date?) -> String {
        let minutes = Int(abs(timeInterval) / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        // If timeInterval is positive, it means there is time until the next prayer
        if timeInterval >= 0 {
            if hours > 0 {
                return "\(hours) h \(remainingMinutes) mins"
            } else {
                return "\(remainingMinutes) mins"
            }
        } else if let nextFajr = nextFajrTime {
            // If the current prayer is Isha, display the next Fajr time
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.timeZone = currentTimeZone
            
            return formatter.string(from: nextFajr)
        } else  {
            return "" // Return an empty string if next Fajr time is not available
        }
    }

    private func getCurrentPrayerIcon() -> Image {
        guard let currentPrayer = prayerTimes.flatMap(getCurrentPrayer) else {
            // Return a default image if the current prayer is not available
            return Image(systemName: "questionmark.square.fill")
        }
        
        switch currentPrayer.prayerName {
        case "Fajr":
            return Image(systemName: "sun.haze.fill")
        case "Sunrise":
            return Image(systemName: "sunrise.fill")
        case "Dhuhr":
            return Image(systemName: "sun.max.fill")
        case "Asr":
            return Image(systemName: "sun.min.fill")
        case "Maghrib":
            return Image(systemName: "sunset.fill")
        case "Isha":
            return Image(systemName: "moon.stars.fill")
        default:
            return Image(systemName: "questionmark.square.fill")
        }
    }

    
 
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Format as "3:59 AM"
        formatter.timeZone = currentTimeZone // Use current dynamic time zone
        
        return formatter.string(from: date)
    }
    
    private func prayerTimeEntries(from times: PrayerTimes) -> [(prayerName: String, time: Date)] {
        return [
            ("Fajr", times.fajr),
            ("Sunrise", times.sunrise),
            ("Dhuhr", times.dhuhr),
            ("Asr", times.asr),
            ("Maghrib", times.maghrib),
            ("Isha", times.isha)
        ]
    }
    
    private func scheduleNotifications(for times: PrayerTimes) {
            // Cancel previously scheduled notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Schedule notifications for each prayer time
            for entry in prayerTimeEntries(from: times) {
                scheduleNotification(for: entry)
            }
        }
    
    private func scheduleNotification(for entry: (prayerName: String, time: Date)) {
        let content = UNMutableNotificationContent()
        content.title = "Prayer Reminder"
        content.body = "It's time for \(entry.prayerName) prayer."
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: entry.time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(entry.prayerName) prayer.")
            }
        }
    }

    
    private func getTimeZoneAndCity(for location: CLLocation?, completion: @escaping (TimeZone?, String?) -> Void) {
        guard let location = location else {
            completion(nil, nil)
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                completion(nil, nil)
            } else if let placemark = placemarks?.first {
                let timeZone = placemark.timeZone
                let city = placemark.locality ?? "" // You can access the city name from the placemark
                self.city = city
                completion(timeZone, city)
            } else {
                completion(nil, nil)
            }
        }
    }
}

// View for displaying prayer time row
struct PrayerTimeRow: View {
    let prayerName: String
    let time: String

    var body: some View {
        HStack {
            Text(prayerName)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text(time)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
    }
}



class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var prayerTimes: PrayerTimes?
    @Published var lastKnownLocation: CLLocation?
    
    private var locationManager = CLLocationManager()
    
    
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location
        
        let cal = Calendar(identifier: .gregorian)
        // Current date
        let currentDate = cal.dateComponents([.year, .month, .day], from: Date())
        
        // Next day
        var nextDateComponents = currentDate
        nextDateComponents.day! += 1 // Increment day by 1 to get the next day
        
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = .shafi
        params.adjustments.fajr = 0
        params.adjustments.sunrise = 0
        params.adjustments.dhuhr = 5
        params.adjustments.maghrib = 0
        params.adjustments.asr = 3
        params.adjustments.isha = 0
        params.fajrAngle = 18
        
        if let times = PrayerTimes(coordinates: Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
//                                                                    59.3607, longitude: 18.0000),
        
        
        //                                   let coordinates = Coordinates(latitude: 59.3607, longitude: 18.0000)
                                           date: currentDate,
                                           calculationParameters: params) {
                    DispatchQueue.main.async {
                        self.prayerTimes = times
                    }
                    
              
                }
        
        
        if let coordinates = manager.location?.coordinate {
               if let currentTimes = PrayerTimes(coordinates: Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude),
                                                 date: currentDate,
                                                 calculationParameters: params),
                  let nextDayTimes = PrayerTimes(coordinates: Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude),
                                                 date: nextDateComponents,
                                                 calculationParameters: params) {
//                   DispatchQueue.main.async {
//                       self.prayerTimes = (currentTimes, nextDayTimes)
//                   }
                  
               }
            
           
           }
           
       
    
        
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
