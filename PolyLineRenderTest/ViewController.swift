//
//  ViewController.swift
//  PolyLineRenderTest
//
//  Created by Rob Kerr on 2/22/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, NSURLConnectionDataDelegate, MKMapViewDelegate {

    @IBOutlet var map : MKMapView!
    
    var data = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
/*
    func testPolygon(){
        var locations = [
            CLLocation(latitude: 32.7767, longitude: -96.7970),
            CLLocation(latitude: 37.7833, longitude: -122.4167),
            CLLocation(latitude: 42.2814, longitude: -83.7483),
            CLLocation(latitude: 32.7767, longitude: -96.7970)
        ]
        
        addPolyLineToMap(locations)
    }
*/
    override func viewWillAppear(animated: Bool) {
        map.setRegion(MKCoordinateRegionMakeWithDistance(CLLocation(latitude: 40.7127, longitude: -74.0059).coordinate, 20000, 20000), animated: true)
        map.mapType = .Hybrid
        startConnection()
    }
    
    //****************************************************************************************
    //
    //       Function: viewForOverlay
    //    Description: Delegate callback that returns a MapOverlayRenderer for a polyline
    //
    //****************************************************************************************
    func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        print("rendererForOverlay called");
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.5);
            pr.lineWidth = 12;
            return pr;
        }
        
        return nil
    }
    
    //****************************************************************************************
    //
    //       Function: startConnection
    //    Description: Opens a connection to the web service to initiate a transfer of GeoJSON
    //
    //****************************************************************************************
    func startConnection(){
        
        print("Starting connection")
        
        let urlPath: String = "http://10.1.10.28:8888/getcityboundary.php?city=New York&state=NY".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
        
    }
    
    //****************************************************************************************
    //
    //       Function: didReceiveData
    //    Description: called each time a bit of data comes down from the web connection
    //
    //****************************************************************************************
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        self.data.appendData(data)
    }
    
    //****************************************************************************************
    //
    //       Function: addPolyLineToMap
    //    Description: Accepts an array of CLLocation, converts it
    //
    //****************************************************************************************
    func addPolyLineToMap(locations: [CLLocation!])
    {
        //var locations = [CLLocation(latitude: -84.0, longitude: 125.0), CLLocation(latitude: -84.0, longitude: 125.0), CLLocation(latitude: -84.0, longitude: 125.0)]
        
        var coordinates = locations.map({ (location: CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        self.map.addOverlay(polyline)
    }

    //****************************************************************************************
    //
    //       Function: connectionDidFinishLoading
    //    Description: called when the GeoJSON result is competely returned
    //
    //****************************************************************************************
func connectionDidFinishLoading(connection: NSURLConnection) {
    
    if let jsonResult: AnyObject =
        try? NSJSONSerialization.JSONObjectWithData(data,options:[]) {
        if jsonResult is NSDictionary {
            let myDict: NSDictionary = jsonResult as! NSDictionary
            
            if myDict["coordinates"] != nil
                && (myDict["type"] as! String) == "MultiPolygon" {
                
                // it's a MultiPolygon type, which is an array of polygons
                let multiPolygon = myDict["coordinates"] as! NSArray
                for (polygonOuter) in multiPolygon {
                    for (polygon) in (polygonOuter as! NSArray) {
                        // Start accumulating a polygon from the MultiPolygon collection
                        var locations : [CLLocation] = []

                        // Create a CLLocation for each lat/long received
                        for (latlong) in (polygon as! NSArray) {
                            let loc = CLLocation(latitude: (latlong[1] as! Double), longitude: (latlong[0] as! Double))
                            print("coordinate item:\(loc.coordinate.latitude) | \(loc.coordinate.longitude)")
                           locations.append(loc)
                        }
                        // Call routine to add the polygon to the map
                        addPolyLineToMap(locations)
                    }
                }
            } // If result is a MultiPolygon
        }  // if result is a Dictionary
    } // if object returned from HTTP call
} // func
}

