//
//  LocationManager.swift
//  Zoo Finder
//
//  Created by Student on 4/21/21.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    override init() {
           super.init()
           locationManager.delegate = self
           locationManager.requestWhenInUseAuthorization()
           locationManager.startUpdatingLocation()
       }

    var locationManager = CLLocationManager()
    
}
