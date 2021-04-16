import UIKit
import MapKit

class RunDetailsViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  
  var run: Run!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configView()
  }
  
  private func configView() {
    let distance = Measurement(value: run.distance, unit: UnitLength.meters)
    let seconds = Int(run.duration)
    let formattedDistance = UnitFormat.distance(distance)
    let formattedDate = UnitFormat.date(run.timestamp)
    let formattedTime = UnitFormat.time(seconds)
    let formattedPace = UnitFormat.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
    distanceLabel.text = "Distance: \(formattedDistance)"
    dateLabel.text = formattedDate
    timeLabel.text = "Time: \(formattedTime)"
    paceLabel.text = "Pace: \(formattedPace)"
    
    loadMap()
  }
  
  private func mapRegion() -> MKCoordinateRegion? {
    guard
      let locations = run.locations,
      locations.count > 0
    else {
      return nil
    }
    
    let latitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.lat
    }
    
    let longitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.lon
    }
    
    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!
    
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                        longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                longitudeDelta: (maxLong - minLong) * 1.3)
    return MKCoordinateRegion(center: center, span: span)
  }
  
  private func polyLine() -> MKPolyline {
    guard let locations = run.locations else {
      return MKPolyline()
    }
    let coords: [CLLocationCoordinate2D] = locations.map { location in
      let location = location as! Location
      return CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
    }
    return MKPolyline(coordinates: coords, count: coords.count)
  }
  
  private func loadMap() {
    guard
      let locations = run.locations,
      locations.count > 0,
      let region = mapRegion()
    else {
      let alert = UIAlertController(title: "Error",
                                    message: "No locations for this run",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel))
      present(alert, animated: true)
      return
    }
    mapView.setRegion(region, animated: true)
    mapView.addOverlay(polyLine())
  }
}
extension RunDetailsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->
  MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .red
    renderer.lineWidth = 3
    return renderer
  }
}
