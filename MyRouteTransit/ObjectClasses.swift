//
//  ObjectClasses.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/01.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import Foundation

class RouteShapeBase {
    var railwayCode:String = ""
    var originStationCode:String = ""
    var destinationStationCode:String = ""
    var originStationDepartureTime:Date!
    var destinationStationAriivalTime:Date!
    var isFinal:Bool = false
}


class RailwayLine {
    var railwayOperator: TransportOperator!
    var railwayCode:String = ""
    var railwayName:String = ""
    var availableDirections:[RailDirection] = [RailDirection]()
}

class Station {
    var railwayOperator:TransportOperator!
    var railwayLine:RailwayLine!
    var stationCode:String = ""
    var stationName:String = ""
    var stationIndex:Int = 0
}

class RailDirection {
    var directionCode:String = ""
    var directionTitle:String = ""
}
