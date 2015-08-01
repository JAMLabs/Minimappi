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

class MinimapController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        mapView.layer.cornerRadius = 140.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

