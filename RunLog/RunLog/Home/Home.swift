//
//  Home.swift
//  RunLog
//


import SwiftUI
import CoreMotion
import CoreLocation

struct Home: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var inRun = false
    @State var pauseRun = false
    @State private var distance = 0.0
    @State private var pace = 0.0
    @State private var avgPace = 0.0
    @State private var locations: [CLLocation] = []
    @State private var lastRec = Date()
    
    @ObservedObject var stopWatch = StopWatch()
  
    let pedometer = CMPedometer()
    let lengthFormatter = LengthFormatter()
    
    let locationManager = LocationManager()
    
    @State var isPresented = false

    
    var body: some View {
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
            timer in
            if inRun {
                recordLocations()
            }
        }
        
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: HistRunList()) {
                        Text("Run Log")
                    }
                    .padding(.leading, 25)
                    .onAppear {
                        self.locationManager.startUpdating()
                        print(self.locationManager.lastKnownLocation as Any)
                        avgPace = Double(locations.count + 1)
                    }
                    Spacer()
                }
                HMapView()
                HStack {
                    Group {
                        Text("Time")
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Text(self.stopWatch.stopWatchTime)
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Spacer()
                    }
                    Group {
                        Text("Distance")
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Text(String(format: "%.2f mi", distance))
                            //.font(.title)
                            .padding(.trailing, 15)
                            .padding(.top, 5)
                        Spacer()
                    }
                }
                HStack {
                    Group {
                        Text("Pace")
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Text(String(format: "%.2f mph", pace))
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Spacer()
                    }
                    Group {
                    
                        Text("Debug")
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Text(String(format: "%.2f mph", avgPace))
                            //.font(.title)
                            .padding(.leading, 15)
                            .padding(.top, 5)
                        Spacer()
                    }
                }
                HStack {
                    if inRun == false {
                        Button {
                            print("Start Run")
                            inRun.toggle()
                            self.stopWatch.start()
                            self.startPedometer()
                        } label: {
                            Text("Start Run")
                                .padding(20)
                        }
                        .contentShape(Rectangle())
                        
                    } else {
                        HStack {
                            Button {
                                print("Stop Run")
                                inRun.toggle()
                                self.stopWatch.pause()
                                self.isPresented.toggle()
                            } label: {
                                Text("Stop Run")
                                    .padding(20)
                            }
                            .contentShape(Rectangle())
                            if pauseRun == false {
                                Button {
                                    print("Pause Run")
                                    pauseRun.toggle()
                                    self.stopWatch.pause()
                                } label: {
                                    Text("Pause Run")
                                        .padding(20)
                                }
                                .contentShape(Rectangle())
                            } else {
                                Button {
                                    print("Resume Run")
                                    pauseRun.toggle()
                                    self.stopWatch.start()
                                } label: {
                                    Text("Resume Run")
                                        .padding(20)
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                AddRun { name, date in
                    //self.addRun(name: name, date: date)
                    self.isPresented = false
                    self.stopWatch.reset()
                    distance = 0.0
                    pace = 0.0
                    avgPace = 0.0
                }
            }
            .navigationTitle("New Run")
            .navigationBarHidden(true)
            
        }
    }
}

extension Home {
    func startPedometer() {
    if CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isDistanceAvailable() {
      pedometer.startUpdates(from: Date()) { (pedometerData, error) in
        guard let pedometerData = pedometerData, error == nil else { return }
        guard let pedometerDistance = pedometerData.distance else { return }
        let distanceInMeters = Measurement(value: Double(truncating: pedometerDistance), unit: UnitLength.meters)
        distance = distanceInMeters.converted(to: .miles).value
      }
    }

    }
    func recordLocations() {
        let diff = Calendar.current.dateComponents([.second], from: lastRec, to: Date()).second ?? 0
        if diff > 5 {
            locations.append(locationManager.lastKnownLocation!)
            let milliseconds = Double(self.stopWatch.counter)
            let paceCalc = distance/(milliseconds/3600000.0)
            pace = paceCalc.isNaN ? 0.0 : paceCalc
            avgPace = Double(locations.count)
            lastRec = Date()
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var lastKnownLocation: CLLocation?

    func startUpdating() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        lastKnownLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}
		
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home()
        }
    }
}
