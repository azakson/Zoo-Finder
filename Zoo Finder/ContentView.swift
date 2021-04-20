//
//  ContentView.swift
//  Zoo Finder
//
//  Created by Avery Zakson on 4/15/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var region = MKCoordinateRegion(

            center: CLLocationCoordinate2D(

                latitude: 41.8781,

                longitude: -87.6298),

            span: MKCoordinateSpan(

                latitudeDelta: 0.05,

                longitudeDelta: 0.05)

        )
    var body: some View {
        Map(
            coordinateRegion: $region
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


