//
//  HMapView.swift
//  RunLog
//
//  Created by Alex N on 2/28/21.
//

import SwiftUI
import MapKit
import CoreLocation

struct HMapView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    
//    @FetchRequest(
//        entity: Run.entity(),
//        
//        sortDescriptors: [
//            
//        ]
//    ) var runs: FetchedResults
    let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
        timer in
        
    }
    var locationManager = CLLocationManager()
    
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    func makeUIView(context: UIViewRepresentableContext<HMapView>) -> MKMapView {
            setupManager()
            let mapView = MKMapView(frame: UIScreen.main.bounds)
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            return mapView
    }
        
    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<HMapView>) {
        
    }
    
    func drawPolyLine() {
        
    }
    
}

class Locations: ObservableObject {
    var locations = [CLLocationCoordinate2D]()
    
    func load() {
        
    }
}

struct HMapView_Previews: PreviewProvider {
    static var previews: some View {
        HMapView()
    }
}
