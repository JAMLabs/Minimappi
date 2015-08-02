//
//  DrawingView.swift
//  minimapp
//
//  Created by Austin Riopelle on 8/2/15.
//  Copyright (c) 2015 acerio. All rights reserved.
//

import Foundation
import UIKit

class DrawingView: UIView {
    
    var dotArray = [[CGFloat]]()
    var imgArray = [UIImage]()
    var toDraw = false
    
    override func drawRect(rect: CGRect) {
        UIColor.clearColor().setFill()
        UIRectFill(rect)
        if toDraw{
            println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
            for(var i = 0; i < dotArray.count; i++){
                imgArray[i].drawInRect(CGRectMake(dotArray[i][0]-10.0, dotArray[i][1]-10.0, 40.0, 40.0))
            }
            dotArray.removeAll(keepCapacity: false)
        }
    }
}