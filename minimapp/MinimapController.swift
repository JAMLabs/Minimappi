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

class MinimapController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var searchBar = UISearchBar(frame: CGRectMake(-5.0, 0.0, 320.0, 44.0))
    
    var boundingRegion : MKCoordinateRegion = MKCoordinateRegion()
    var localSearch : MKLocalSearch = MKLocalSearch()
    var locationManager : CLLocationManager = CLLocationManager()
    var userLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        mapView.layer.cornerRadius = 140.0
        

        searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        var searchBarView = UIView(frame: CGRectMake(0.0, 0.0, 340.0, 44.0))
        searchBarView.autoresizingMask = UIViewAutoresizing.allZeros
        searchBar.delegate = self
        searchBarView.addSubview(searchBar)
        self.navigationItem.titleView = searchBarView;
        
        var tapGest = UITapGestureRecognizer(target: self, action: "hideSearchBar")
        self.view.addGestureRecognizer(tapGest)
        
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func hideSearchBar(){
        searchBar.resignFirstResponder()
    }
    
}

