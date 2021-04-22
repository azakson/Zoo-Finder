//
//  ContentView.swift
//  Zoo Finder
//
//  Created by Avery Zakson and Matt Imdad on 4/15/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var places = [Place]()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 41.8781, longitude: -87.6298),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var body: some View {
        Map(
            coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode,
            annotationItems: places) { place in
            MapAnnotation(coordinate: place.annotation.coordinate) {
                Marker(mapItem: place.mapItem)
            }
        }
        .onAppear(perform: {
            performSearch(item: "Zoo")
        })
    }
    
    func performSearch(item: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = item
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        search.start { (responce, error) in
            if let responce = responce {
                for mapItem in responce.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    places.append(Place(annotation: annotation, mapItem: mapItem))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Place: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
    let mapItem: MKMapItem
}

struct Marker: View {
    var mapItem: MKMapItem
    var body: some View {
        if let url = mapItem.url {
            Link(destination: url, label: {
                Image("monke")
            })
        }
    }
}



