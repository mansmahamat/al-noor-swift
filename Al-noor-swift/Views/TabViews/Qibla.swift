//
//  Qibla.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//

import SwiftUI
import WebKit
import Adhan
import Combine
import CoreLocation
import UserNotifications

struct Qibla: View {
    
    @ObservedObject var compassHeading = CompassHeading()
    
    var body: some View {
        GeometryReader { geometry in
                                   NavigationView{
                                       List{
                                           Section{
                                               VStack {
                                                   Capsule()
                                                       .frame(width: 5, height: 30)
                                                       .offset(y: -20)
                                                   ZStack {
                                                       ForEach(Marker.markers(), id: \.self) { marker in
                                                           CompassMarkerView(marker: marker,
                                                                             compassDegress: 0)
                                                       }
                                                   }
                                                   
                                                   .rotationEffect(Angle(degrees: self.compassHeading.degrees))
                                               }
                                               .padding(.bottom, 20)
                                               .padding(.top, 25)
                                               .offset(x: geometry.size.width/2.5)
                                           }
                                           .environment(\.defaultMinListRowHeight, 300)
                                           .navigationTitle(Text("Qibla Direction"))
                                           Section{
                                               Text("How To Use:")
                                           }
                                           Section{
                                               Text("1) Place flat on a non-metal surface.").font(.system(size: 14))
                                               Text("2) Allow a few seconds for compass to adjust.").font(.system(size: 14))
                                               Text("3) Rotate phone until the red capsule is in line.").font(.system(size: 14))
                                           }
                                           .environment(\.defaultMinListRowHeight, 10)
                                           .listStyle(InsetGroupedListStyle()) // this has been renamed in iOS 14.*, as mentioned by @Elijah Yap
                                           .environment(\.horizontalSizeClass, .regular)
                                           .listRowSeparator(.hidden)
                                       }
                                   }
                                   .offset(y: -40)
                                   .disabled(true)
                               }
                           }
    }


class CompassHeading: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    var degrees: Double = .zero {
        didSet{
            objectWillChange.send()
        }
    }
    
    private var bearingOfKabah = Double()
    private let locationManager = CLLocationManager()
    private let locationOfKabah = CLLocation(latitude: 21.4225, longitude: 39.8262)
    
    override init() {
        super.init()
        self.setup()
    }
    
    private func setup() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.headingAvailable() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let north = -1 * newHeading.magneticHeading * Double.pi / 180
        let directionOfKabah = bearingOfKabah * Double.pi / 180 + north
        self.degrees = radiansToDegrees(directionOfKabah)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            bearingOfKabah = getBearingOfKabah(currentLocation: location, locationOfKabah: locationOfKabah)
        }
    }
    
    private func degreesToRadians(_ deg: Double) -> Double {
        return deg * Double.pi / 180
    }
    
    private func radiansToDegrees(_ rad: Double) -> Double {
        return rad * 180 / Double.pi
    }
    
    private func getBearingOfKabah(currentLocation: CLLocation, locationOfKabah: CLLocation) -> Double {
        let currentLatitude = degreesToRadians(currentLocation.coordinate.latitude)
        let currentLongitude = degreesToRadians(currentLocation.coordinate.longitude)
        
        let latitudeOfKabah = degreesToRadians(locationOfKabah.coordinate.latitude)
        let longitudeOfKabah = degreesToRadians(locationOfKabah.coordinate.longitude)
        
        let dLongitude = longitudeOfKabah - currentLongitude
        
        let y = sin(dLongitude) * cos(latitudeOfKabah)
        let x = cos(currentLatitude) - sin(latitudeOfKabah) - sin(currentLatitude) * cos(latitudeOfKabah) - cos(dLongitude)
        
        var radiansBearing = atan2(y, x)
        
        if radiansBearing < 0.0 {
            radiansBearing += 2 * Double.pi
        }
        
        return radiansToDegrees(radiansBearing)
    }
}

#Preview {
    Qibla()
}
