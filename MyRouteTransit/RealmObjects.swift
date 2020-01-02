//
//  RealmObjects.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2019/12/31.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class RouteShape:Object{
    @objc dynamic var id = 0
    @objc dynamic var depatureTime = 0
    @objc dynamic var arrivalTime = 0
    @objc dynamic var originStationCode = ""
    @objc dynamic var destinationStationCode = ""
    @objc dynamic var routeShapeJsonString = ""
}

class TransportOperator:Object {
    @objc dynamic var operatorCode:String = ""
    @objc dynamic var operatorName:String = ""
}
