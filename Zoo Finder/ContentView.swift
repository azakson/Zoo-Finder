//
//  ContentView.swift
//  Zoo Finder
//
//  Created by Avery Zakson and Matt Imdad on 4/15/21.
//

import SwiftUI
import MapKit
import CoreLocation

extension ContentView {
        struct PickerValues {
                let mapType: MKMapType
            let description: String
        }
}

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var places = [Place]()
    @State private var region = CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298)
    @State private var regionViewed = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 41.8781, longitude: -87.6298),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var action: MapView.Action = .idle
    @State private var mapPickerSelection: Int = 0
    let pickerValues: [PickerValues] = [// [.standard, .hybrid, .satellite]
            PickerValues(mapType: .standard, description: "Standard"),
            PickerValues(mapType: .hybrid, description: "Hybrid"),
            PickerValues(mapType: .satellite, description: "Satellite"), ]
    
    var body: some View {
        let binding = Binding<Int>(
                get: { self.mapPickerSelection},
                set: { newValue in
                        self.action = .changeType(mapType: self.pickerValues[newValue].mapType)
                        self.mapPickerSelection = newValue
                }
        )
        
        VStack {
            
            Map(
                coordinateRegion: $regionViewed,
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
        MapView(centerCoordinate: self.$region, action: self.$action)
        Picker(selection: binding, label: Text("Map type")) {
                ForEach(self.pickerValues.indices) { index in
                        Text(self.pickerValues[index].description).tag(index)
                }
        }.pickerStyle(SegmentedPickerStyle())
    }
    
    func performSearch(item: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = item
        searchRequest.region = regionViewed
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
                    .resizable()
                    .frame(width: 50, height: 50)
            })
        }
    }
}

struct MapView: UIViewRepresentable {
        enum Action {
                case idle
                case reset(coordinate: CLLocationCoordinate2D)
                case changeType(mapType: MKMapType)
        }
        @Binding var centerCoordinate: CLLocationCoordinate2D
        @Binding var action: Action
        func makeUIView(context: Context) -> MKMapView {
                let mapView = MKMapView()
                mapView.delegate = context.coordinator
                mapView.centerCoordinate = self.centerCoordinate
                return mapView
        }
        func updateUIView(_ uiView: MKMapView, context: Context) {
                switch action {
                case .idle:
                        break
                case .reset(let newCoordinate):
                        uiView.delegate = nil
                        uiView.centerCoordinate = newCoordinate
                        DispatchQueue.main.async {
                                self.centerCoordinate = newCoordinate
                                self.action = .idle
                                uiView.delegate = context.coordinator
                        }
                case .changeType(let mapType):
                        uiView.mapType = mapType
                }
        }
        func makeCoordinator() -> Coordinator {
                Coordinator(self)
        }
        class Coordinator: NSObject, MKMapViewDelegate {
                var parent: MapView
                func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
                        parent.centerCoordinate = mapView.centerCoordinate
                }
                init(_ parent: MapView) {
                        self.parent = parent
                }
        }
}



