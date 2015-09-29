import UIKit
import MapKit

class SimplePolylineViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var map : MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTestPolyLine()
    }

    func createTestPolyLine(){
        let locations = [
        CLLocation(latitude: 32.7767, longitude: -96.7970),         /* San Francisco, CA */
        CLLocation(latitude: 37.7833, longitude: -122.4167),        /* Dallas, TX */
        CLLocation(latitude: 42.2814, longitude: -83.7483),         /* Ann Arbor, MI */
        CLLocation(latitude: 32.7767, longitude: -96.7970)          /* San Francisco, CA */
        ]
        
        addPolyLineToMap(locations)
    }
    
    func addPolyLineToMap(locations: [CLLocation!])
    {
        //var locations = [CLLocation(latitude: -84.0, longitude: 125.0), CLLocation(latitude: -84.0, longitude: 125.0), CLLocation(latitude: -84.0, longitude: 125.0)]
        
        var coordinates = locations.map({ (location: CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        self.map.addOverlay(polyline)
    }

    func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.5);
            pr.lineWidth = 5;
            return pr;
        }
        
        return nil
    }
}
