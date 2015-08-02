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
    var currentlyAdding = false
    var peopleLogged = Dictionary<String, NSInteger?>()
    let uidString = UIDevice.currentDevice().identifierForVendor.UUIDString
    var uidInt : UInt = 0
    
    @IBOutlet weak var drawingView: DrawingView!
    
    @IBOutlet weak var leafButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var miscButton: UIButton!
    
    var targetList = [Annotation]()
    var targetIconList = ["red_dot", "orange_dot", "yellow_dot", "green_dot", "cyan_dot", "purple_dot", "white_dot", "black_dot"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var range = Range(start: uidString.rangeOfString("-", options:NSStringCompareOptions.BackwardsSearch)!.startIndex, end: uidString.endIndex)
        var newUidString = uidString.substringWithRange(range)
        newUidString = newUidString.substringFromIndex(advance(newUidString.startIndex, 1))
        print(newUidString)
        
        uidInt = strtoul(newUidString, nil, 16)
        print("LALALAL : \(uidInt)")
        
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
        
        searchBar.text = ""
        self.places.removeAll(keepCapacity: false)
        self.searchTableView.reloadData()
        
        addButton.hidden = false
        tempAnnot = annotation
        print("SET ANNOT, \(annotation.title)")
        currentlyAdding = true
        drawingView.toDraw = false
        drawingView.setNeedsDisplay()
        
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        let centerframe = CGRectMake(166.0, 560.0, 50.0, 50.0)
        let gotoCarFrame = carButton.frame
        let startCarFrame = centerframe
        carButton.frame = startCarFrame
        
        let gotoStarFrame = starButton.frame
        let startStarFrame = centerframe
        starButton.frame = startStarFrame
        
        let gotoMiscFrame = miscButton.frame
        let startMiscFrame = centerframe
        miscButton.frame = startMiscFrame
        
        let gotoFoodFrame = foodButton.frame
        let startFoodFrame = centerframe
        foodButton.frame = startFoodFrame
        
        let gotoLeafFrame = leafButton.frame
        let startLeafFrame = centerframe
        leafButton.frame = startLeafFrame
        
        let gotoShopFrame = shopButton.frame
        let startShopFrame = centerframe
        shopButton.frame = startShopFrame
        
        miscButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        starButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        carButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        foodButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        leafButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        shopButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        
        UIView.animateWithDuration(0.3, animations: {
            self.carButton.frame = gotoCarFrame
            self.carButton.hidden = false
            self.foodButton.frame = gotoFoodFrame
            self.foodButton.hidden = false
            self.leafButton.frame = gotoLeafFrame
            self.leafButton.hidden = false
            self.shopButton.frame = gotoShopFrame
            self.shopButton.hidden = false
            self.starButton.frame = gotoStarFrame
            self.starButton.hidden = false
            self.miscButton.frame = gotoMiscFrame
            self.miscButton.hidden = false
        })
        
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

        self.localSearch = MKLocalSearch(request: request)
        self.localSearch!.startWithCompletionHandler(completionHandler)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    @IBAction func iconButtonClicked(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3, animations: {
            self.carButton.hidden = true
            self.foodButton.hidden = true
            self.leafButton.hidden = true
            self.shopButton.hidden = true
            self.starButton.hidden = true
            self.miscButton.hidden = true
            (sender as! UIButton).transform = CGAffineTransformMakeScale(1.5,1.5);
        })
        
        if(sender as! UIButton == self.carButton){
            tempAnnot!.img = UIImage(named: "car_button")!
        }
        else if(sender as! UIButton == self.foodButton){
            tempAnnot!.img = UIImage(named: "food_button")!
        }
        else if(sender as! UIButton == self.starButton){
            tempAnnot!.img = UIImage(named: "star_button")!
        }
        else if(sender as! UIButton == self.leafButton){
            tempAnnot!.img = UIImage(named: "leaf_button")!
        }
        else if(sender as! UIButton == self.shopButton){
            tempAnnot!.img = UIImage(named: "shop_button")!
        }
        else{
            tempAnnot!.img = UIImage(named: "misc_button")!
        }
        
        self.mapView.removeAnnotation(tempAnnot)
        addButton.hidden = true
        currentlyAdding = false
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        
        targetList.append(tempAnnot!)
        tempAnnot = nil
        drawingView.toDraw = true
        drawingView.setNeedsDisplay()
        updateTargets()
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
        
        Alamofire.request(.GET, "http://10.180.0.129:8080/push", parameters: ["location":locDictStr,"ID":uidInt]).response({ request, response, data, error in
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
        
        drawingView.dotArray.removeAll(keepCapacity: false)
        drawingView.imgArray.removeAll(keepCapacity: false)
        
        Alamofire.request(.GET, "http://10.180.0.129:8080/get", parameters:nil).response({ request, response, data, error in

            let json = JSON(data: data!)
            
            for (userKey : String, subJSON: JSON) in json{
                var annotPerson = Annotation()
                annotPerson.coordinate = CLLocationCoordinate2DMake(subJSON["X"].double!, subJSON["Y"].double!)
                annotPerson.title = "Another User"
                annotPerson.img = UIImage(named:"person_icon")!
                println(userKey)
                if let val = self.peopleLogged[userKey]{
                    self.targetList[val!] = annotPerson
                }
                else{
                    print("===   \(userKey != String(self.uidInt))   ===")
                    if userKey != String(self.uidInt){
                        self.targetList.append(annotPerson)
                        self.peopleLogged[userKey] = self.targetList.count - 1
                    }
                }
            }
        })
        
        for annot in targetList{
            //        println("Heading: \(locationManager?.heading.trueHeading)")
//            print("\(annot.title) \(annot.coordinate.latitude) \(annot.coordinate.longitude) |u->| \(self.userLocation.latitude) \(self.userLocation.longitude)")
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
//            print("beforeunwrap")
            var relativeAngle = realAngleFromNorthToTarget - locationManager!.heading.trueHeading
            if relativeAngle < 0{
                relativeAngle += 360.0
            }
//            print("unwrap")
//                println("ANGLE:  \(relativeAngle)")
            
            var dist = sqrt(pow(latDiff,2) + pow(longDiff,2))
//            println(dist)
            
            var drawX : CGFloat = 0.0
            var drawY : CGFloat = 0.0
            
            let specialVal = 2.8 * 0.00215827429374711
            
            if(dist > specialVal){
                drawX = radius + radius * CGFloat(sin(relativeAngle * (M_PI / 180.0))) + 10.0
                drawY = radius - radius * CGFloat(cos(relativeAngle * (M_PI / 180.0))) + 10.0
            }
            else{
                drawX = radius + radius * CGFloat(dist/specialVal) * CGFloat(sin(relativeAngle * (M_PI / 180.0))) + 10.0
                drawY = radius - radius * CGFloat(dist/specialVal) * CGFloat(cos(relativeAngle * (M_PI / 180.0))) + 10.0
            }
            
//            println("\(drawX) \(drawY) || \(relativeAngle)")
            
            drawingView.dotArray.append([drawX, drawY])
            drawingView.imgArray.append(annot.img)
            if !currentlyAdding{
                drawingView.toDraw = true
                drawingView.setNeedsDisplay()
            }
        }
    }
    

}



