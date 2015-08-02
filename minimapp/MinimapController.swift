//
//  ViewController.swift
//  minimapp
//
//  Created by Austin Riopelle on 8/1/15.
//  Copyright (c) 2015 acerio. All rights reserved.
//

import UIKit
import MapKit
import QuartzCore
import Alamofire

class MinimapController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate{
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    var searchBar = UISearchBar(frame: CGRectMake(0.0, 0.0, 350.0, 44.0))
    let kCellIdentifier = "cellIdentifier"
    var boundingRegion : MKCoordinateRegion = MKCoordinateRegion()
    var localSearch : MKLocalSearch? = nil
    var locationManager : CLLocationManager? = CLLocationManager()
    var userLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    var places = [MKMapItem]()
    var mapItemList = [MKMapItem]()
    var tempAnnot : Annotation? = nil
    
    @IBOutlet weak var drawingView: DrawingView!
    
    var targetList = [Annotation]()
    var targetIconList = ["red_dot", "orange_dot", "yellow_dot", "green_dot", "cyan_dot", "purple_dot", "white_dot", "black_dot"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        mapView.layer.cornerRadius = 140.0
        
        searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        var searchBarView = UIView(frame: CGRectMake(0.0, 0.0, 340.0, 44.0))
        searchBarView.autoresizingMask = UIViewAutoresizing.allZeros
        searchBar.delegate = self
        searchBarView.addSubview(searchBar)
        searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBarView;
        
//        var tapGest = UITapGestureRecognizer(target: self, action: "hideSearchBar")
//        self.view.addGestureRecognizer(tapGest)
        
        locationManager?.requestAlwaysAuthorization()
        
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager!.distanceFilter = 100

        mapView.delegate = self
        
        var authorizationStatus = CLLocationManager.authorizationStatus()
        println(authorizationStatus == CLAuthorizationStatus.AuthorizedAlways)
        println(authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse)
        println(authorizationStatus == CLAuthorizationStatus.Denied)
        println(authorizationStatus == CLAuthorizationStatus.NotDetermined)
        println(authorizationStatus == CLAuthorizationStatus.Restricted)
        
        
        if (authorizationStatus == CLAuthorizationStatus.AuthorizedAlways ||
            authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
            println("yeyseysyeysy")
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
            locationManager!.startUpdatingLocation()
            locationManager!.startUpdatingHeading()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchTableView.hidden = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTableView.hidden = true
        println("cancel!")
    }
    
    func hideSearchBar(){
        searchBar.resignFirstResponder()
        searchTableView.hidden = true
        searchBar.text = ""
    }
    
    //---------------------------------------
    //---------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        var mapItem : MKMapItem = self.places[indexPath.row]
        println("\(mapItem)")
        println("-----------------------------------------------------------")
        var placeStr = "\(mapItem.placemark)"
        var range = Range(start: placeStr.startIndex,
            end: placeStr.rangeOfString("@")!.startIndex)
        placeStr = placeStr.substringWithRange(range)
        cell.textLabel!.text = placeStr
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedItem : NSIndexPath = searchTableView.indexPathForSelectedRow()!
        var selectedMapItem = self.places[selectedItem.row]
        println("fhdksfhlh")
        searchBar.resignFirstResponder()
        searchTableView.hidden = true
        
        // add the single annotation to our map
        var annotation = Annotation()
        annotation.coordinate = selectedMapItem.placemark.location.coordinate
        annotation.title = selectedMapItem.name
        self.mapView.addAnnotation(annotation)
        
        // we have only one annotation, select it's callout
        self.mapView.selectAnnotation(annotation, animated: true)
        
        // center the region around this map item's coordinate
        self.mapView.centerCoordinate = selectedMapItem.placemark.coordinate
        println("\(selectedMapItem.placemark.coordinate.latitude) \(selectedMapItem.placemark.coordinate.longitude)")
        
        addButton.hidden = false
        tempAnnot = annotation
        print("SET ANNOT")
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        targetList.append(tempAnnot!)
        updateTargets()
        addButton.hidden = true
        tempAnnot = nil
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
    }
    
    func startSearch(searchString: String){
        if(self.localSearch != nil && self.localSearch!.searching){
            self.localSearch!.cancel()
        }
        
        var newRegion = MKCoordinateRegion()
        newRegion.center.latitude = self.userLocation.latitude
        newRegion.center.longitude = self.userLocation.longitude
        
        newRegion.span.latitudeDelta = 0.112872
        newRegion.span.longitudeDelta = 0.109863
        
        var request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchString
        request.region = newRegion
        println("\(newRegion.center.latitude), \(newRegion.center.longitude)")
        
        var completionHandler : MKLocalSearchCompletionHandler = { (response: MKLocalSearchResponse?, error : NSError?) in
            if( error != nil ){
                var errorStr: AnyObject? = error!.userInfo?[NSLocalizedDescriptionKey]
                var alert = UIAlertView(title: "Could not find places", message: errorStr as? String, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else{
                self.places = response?.mapItems as! [MKMapItem]
                self.boundingRegion = response!.boundingRegion
                self.searchTableView.reloadData()
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        if(self.localSearch != nil){
            self.locationManager = nil
        }
        self.localSearch = MKLocalSearch(request: request)
        self.localSearch!.startWithCompletionHandler(completionHandler)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        var causeStr : String? = nil
        if(CLLocationManager.locationServicesEnabled() == false){
            causeStr = "device"
        }
        else if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied){
            causeStr = "app"
        }
        else{
            self.startSearch(searchBar.text)
        }
        
        if(causeStr != nil){
            var alertMessage = NSString(format: "You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr!)
            var servicesDisabledAlert = UIAlertView(title: "Location Services Disabled", message: alertMessage as String, delegate: nil, cancelButtonTitle: "OK")
            servicesDisabledAlert.show()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.userLocation = newLocation.coordinate
        manager.stopUpdatingLocation()
        manager.delegate = nil
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
            // report any errors returned back from Location Services
        print(NSError)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.userLocation = (locations[0] as! CLLocation).coordinate
        print("\(self.userLocation.latitude), \(self.userLocation.longitude)")
        
        var locDictStr = "{\"X\":\(self.userLocation.latitude),\"Y\":\(self.userLocation.longitude)}"
        Alamofire.request(.GET, "http://10.180.0.129:8080/push", parameters: ["location":locDictStr,"ID":"4834"]).response({ request, response, data, error in
            println("Alamofire: \(request)")
            println("Alamofire: \(response)")
            println("Alamofire: \(error)")
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        updateTargets()
    }
    
    func updateTargets(){
        let centerX = mapView.frame.width/2 + mapView.frame.origin.x
        let centerY = mapView.frame.height/2 + mapView.frame.origin.y
        let radius = mapView.frame.width/2
        println("into FOR")
        for annot in targetList{
            //        println("Heading: \(locationManager?.heading.trueHeading)")
            var latDiff = annot.coordinate.latitude-self.userLocation.latitude
            var longDiff = annot.coordinate.longitude-self.userLocation.longitude
            //            println("LatDiff: \(latDiff)  LongDiff: \(longDiff)")
            var angleFromHorizToTarget = atan(latDiff/longDiff) * (180.0/M_PI)
            //            println("TargetHeading: \(angleFromHorizToTarget)")
            
            var realAngleFromNorthToTarget = 0.0
            if(longDiff>0){
                realAngleFromNorthToTarget = 90.0 - angleFromHorizToTarget
            }
            else{
                realAngleFromNorthToTarget = 270.0 - angleFromHorizToTarget
            }
            
            var relativeAngle = realAngleFromNorthToTarget - locationManager!.heading.trueHeading
            if relativeAngle < 0{
                relativeAngle += 360.0
            }
//                println("ANGLE:  \(relativeAngle)")
            var drawX = radius + radius * CGFloat(sin(relativeAngle * (M_PI / 180.0))) + 10.0
            var drawY = radius - radius * CGFloat(cos(relativeAngle * (M_PI / 180.0))) + 10.0
            println("\(drawX) \(drawY) || \(relativeAngle)")
            drawingView.dotArray.append([drawX, drawY])
            drawingView.toDraw = true
            drawingView.setNeedsDisplay()
        }
    }
    

}



